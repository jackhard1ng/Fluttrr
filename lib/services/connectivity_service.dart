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

  /// Domains to check for connectivity (tries multiple in case one is blocked)
  static const List<String> _connectivityDomains = [
    'cloudflare.com',    // Widely accessible globally
    '1.1.1.1',           // Cloudflare DNS
    'example.com',       // IANA example domain
  ];

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

  /// Check if device has internet connectivity.
  /// Tries multiple domains for reliability in different regions.
  /// Returns true when DNS check is inconclusive — the actual HTTP request
  /// is the real connectivity test. This only returns false when we have
  /// strong evidence of no connectivity (DNS failures update isConnected
  /// for UI hints, but don't block requests).
  Future<bool> checkConnectivity() async {
    // On web, dart:io DNS lookups aren't available - assume connected
    if (kIsWeb) {
      isConnected.value = true;
      return true;
    }

    if (isChecking.value) return isConnected.value;

    isChecking.value = true;

    try {
      // Try each domain until one succeeds
      for (final domain in _connectivityDomains) {
        try {
          final result = await InternetAddress.lookup(domain)
              .timeout(const Duration(seconds: 3));

          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            isConnected.value = true;
            isChecking.value = false;
            return true;
          }
        } catch (_) {
          // Try next domain
          continue;
        }
      }

      // All DNS lookups failed — update observable for UI hints,
      // but still return true so requests aren't blocked.
      // DNS can fail even with working internet (firewalls, emulators, etc).
      debugPrint('ConnectivityService: All DNS lookups failed, but allowing requests to proceed');
      isConnected.value = false;
      isChecking.value = false;
      return true;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      isChecking.value = false;
      return true;
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
