import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service to monitor and check network connectivity
class ConnectivityService extends GetxService {
  final RxBool isConnected = true.obs;
  final RxBool isChecking = false.obs;

  Timer? _checkTimer;
  static const Duration _checkInterval = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    // Initial check
    checkConnectivity();
    // Periodic checks
    _startPeriodicCheck();
  }

  @override
  void onClose() {
    _checkTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicCheck() {
    _checkTimer = Timer.periodic(_checkInterval, (_) => checkConnectivity());
  }

  /// Check if device has internet connectivity
  Future<bool> checkConnectivity() async {
    if (isChecking.value) return isConnected.value;

    isChecking.value = true;

    try {
      // Try to lookup a well-known domain
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      isConnected.value = connected;
      isChecking.value = false;
      return connected;
    } on SocketException catch (_) {
      isConnected.value = false;
      isChecking.value = false;
      return false;
    } on TimeoutException catch (_) {
      isConnected.value = false;
      isChecking.value = false;
      return false;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      isConnected.value = false;
      isChecking.value = false;
      return false;
    }
  }

  /// Execute a function only if connected, otherwise show error
  Future<T?> executeIfConnected<T>({
    required Future<T> Function() action,
    String? errorMessage,
    VoidCallback? onNoConnection,
  }) async {
    final connected = await checkConnectivity();

    if (!connected) {
      onNoConnection?.call();
      if (errorMessage != null) {
        Get.snackbar(
          'No Connection',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return null;
    }

    return action();
  }

  /// Wait for connectivity with timeout
  Future<bool> waitForConnectivity({
    Duration timeout = const Duration(seconds: 30),
    Duration checkInterval = const Duration(seconds: 2),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      if (await checkConnectivity()) {
        return true;
      }
      await Future.delayed(checkInterval);
    }

    return false;
  }
}

/// Mixin for widgets that need connectivity awareness
mixin ConnectivityAware {
  ConnectivityService get connectivity => Get.find<ConnectivityService>();

  bool get isConnected => connectivity.isConnected.value;

  Future<bool> checkConnection() => connectivity.checkConnectivity();
}
