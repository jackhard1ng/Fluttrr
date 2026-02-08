import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_endpoints.dart';
import 'token_manager.dart';

/// Connection status for socket
enum SocketStatus {
  connecting,
  connected,
  disconnected,
  error,
}

/// Socket service for real-time communication
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  StreamController<SocketStatus>? _statusController;
  StreamController<Map<String, dynamic>>? _messageController;
  StreamController<Map<String, dynamic>>? _typingController;
  StreamController<Map<String, dynamic>>? _onlineController;

  bool _isDisposed = false;
  bool _isInitializing = false;

  /// Ensure stream controllers are initialized (thread-safe)
  void _ensureControllersInitialized() {
    // Prevent re-initialization during dispose
    if (_isDisposed || _isInitializing) return;

    _isInitializing = true;
    try {
      _statusController ??= StreamController<SocketStatus>.broadcast();
      _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
      _typingController ??= StreamController<Map<String, dynamic>>.broadcast();
      _onlineController ??= StreamController<Map<String, dynamic>>.broadcast();
    } finally {
      _isInitializing = false;
    }
  }

  /// Safely add to stream controller
  void _safeAdd<T>(StreamController<T>? controller, T data) {
    if (controller != null && !controller.isClosed && !_isDisposed) {
      controller.add(data);
    }
  }

  /// Stream of connection status changes
  Stream<SocketStatus> get statusStream {
    _ensureControllersInitialized();
    return _statusController!.stream;
  }

  /// Stream of incoming messages
  Stream<Map<String, dynamic>> get messageStream {
    _ensureControllersInitialized();
    return _messageController!.stream;
  }

  /// Stream of typing indicators
  Stream<Map<String, dynamic>> get typingStream {
    _ensureControllersInitialized();
    return _typingController!.stream;
  }

  /// Stream of online status changes
  Stream<Map<String, dynamic>> get onlineStream {
    _ensureControllersInitialized();
    return _onlineController!.stream;
  }

  /// Current socket status
  SocketStatus _status = SocketStatus.disconnected;
  SocketStatus get status => _status;

  /// Check if socket is connected
  bool get isConnected => _socket?.connected ?? false;

  /// Initialize and connect socket
  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('Socket already connected');
      return;
    }

    // Ensure stream controllers are initialized before connecting
    _ensureControllersInitialized();

    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        debugPrint('No auth token available for socket connection');
        return;
      }

      _updateStatus(SocketStatus.connecting);

      _socket = io.io(
        ApiEndpoints.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .setAuth({'token': token})
            .build(),
      );

      _setupEventListeners();
      _socket!.connect();
    } catch (e) {
      debugPrint('Error connecting socket: $e');
      _updateStatus(SocketStatus.error);
    }
  }

  /// Set up socket event listeners
  void _setupEventListeners() {
    _socket?.onConnect((_) {
      debugPrint('Socket connected');
      _updateStatus(SocketStatus.connected);
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _updateStatus(SocketStatus.disconnected);
    });

    _socket?.onConnectError((error) {
      debugPrint('Socket connection error: $error');
      _updateStatus(SocketStatus.error);
    });

    _socket?.onError((error) {
      debugPrint('Socket error: $error');
      _updateStatus(SocketStatus.error);
    });

    _socket?.onReconnect((_) {
      debugPrint('Socket reconnected');
      _updateStatus(SocketStatus.connected);
    });

    _socket?.onReconnectAttempt((attemptNumber) {
      debugPrint('Socket reconnection attempt: $attemptNumber');
    });

    // Listen for new messages
    _socket?.on('new_message', (data) {
      debugPrint('New message received');
      if (data is Map<String, dynamic>) {
        _safeAdd(_messageController, data);
      }
    });

    // Listen for typing indicators
    _socket?.on('typing', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_typingController, data);
      }
    });

    _socket?.on('stop_typing', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_typingController, {...data, 'isTyping': false});
      }
    });

    // Listen for online status changes
    _socket?.on('user_online', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_onlineController, {...data, 'isOnline': true});
      }
    });

    _socket?.on('user_offline', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_onlineController, {...data, 'isOnline': false});
      }
    });

    // Listen for message read receipts
    _socket?.on('message_read', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_messageController, {...data, 'type': 'read_receipt'});
      }
    });

    // Listen for message deleted
    _socket?.on('message_deleted', (data) {
      if (data is Map<String, dynamic>) {
        _safeAdd(_messageController, {...data, 'type': 'deleted'});
      }
    });
  }

  /// Update status and notify listeners
  void _updateStatus(SocketStatus newStatus) {
    _status = newStatus;
    _safeAdd(_statusController, newStatus);
  }

  /// Disconnect socket
  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _updateStatus(SocketStatus.disconnected);
  }

  /// Join a chat room
  void joinRoom(String roomId) {
    _socket?.emit('join_room', {'roomId': roomId});
    debugPrint('Joined room: $roomId');
  }

  /// Leave a chat room
  void leaveRoom(String roomId) {
    _socket?.emit('leave_room', {'roomId': roomId});
    debugPrint('Left room: $roomId');
  }

  /// Send a message
  void sendMessage({
    required String roomId,
    required String content,
    required String receiverId,
    String? imageUrl,
  }) {
    _socket?.emit('send_message', {
      'roomId': roomId,
      'content': content,
      'receiverId': receiverId,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

  /// Send typing indicator
  void sendTyping({
    required String roomId,
    required String receiverId,
    required bool isTyping,
  }) {
    _socket?.emit(isTyping ? 'typing' : 'stop_typing', {
      'roomId': roomId,
      'receiverId': receiverId,
    });
  }

  /// Mark message as read
  void markAsRead({
    required String messageId,
    required String roomId,
  }) {
    _socket?.emit('mark_read', {
      'messageId': messageId,
      'roomId': roomId,
    });
  }

  /// Delete a message
  void deleteMessage({
    required String messageId,
    required String roomId,
  }) {
    _socket?.emit('delete_message', {
      'messageId': messageId,
      'roomId': roomId,
    });
  }

  /// Emit a custom event
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  /// Listen to a custom event
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Remove listener for a custom event
  void off(String event) {
    _socket?.off(event);
  }

  /// Dispose of the service
  void dispose() {
    _isDisposed = true;
    disconnect();

    // Close and nullify stream controllers
    if (_statusController != null && !_statusController!.isClosed) {
      _statusController!.close();
    }
    _statusController = null;

    if (_messageController != null && !_messageController!.isClosed) {
      _messageController!.close();
    }
    _messageController = null;

    if (_typingController != null && !_typingController!.isClosed) {
      _typingController!.close();
    }
    _typingController = null;

    if (_onlineController != null && !_onlineController!.isClosed) {
      _onlineController!.close();
    }
    _onlineController = null;
  }
}
