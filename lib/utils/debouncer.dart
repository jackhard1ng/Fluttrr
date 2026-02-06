import 'dart:async';

/// Debouncer utility for delaying operations
/// Commonly used for search input to avoid excessive API calls
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run the callback after the delay, cancelling any pending call
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler utility for rate-limiting operations
/// Ensures a function is called at most once per duration
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  /// Run the callback if not throttled
  void run(void Function() callback) {
    if (_isThrottled) return;

    callback();
    _isThrottled = true;

    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  /// Dispose the throttler
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }
}

/// Extension for easy debouncing on streams
extension StreamDebounce<T> on Stream<T> {
  /// Debounce the stream by the given duration
  Stream<T> debounce(Duration duration) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          Timer(duration, () => sink.add(data));
        },
      ),
    );
  }
}
