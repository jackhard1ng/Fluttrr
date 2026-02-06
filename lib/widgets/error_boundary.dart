import 'package:flutter/material.dart';

import '../constants/utils.dart';

/// Error boundary widget that catches and handles errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          ErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: _resetError,
          );
    }

    return ErrorCatcher(
      onError: (error, stackTrace) {
        widget.onError?.call(error, stackTrace);
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
        });
      },
      child: widget.child,
    );
  }
}

/// Widget that catches errors in the widget tree
class ErrorCatcher extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const ErrorCatcher({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<ErrorCatcher> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (FlutterErrorDetails details) {
      widget.onError(details.exception, details.stack);
    };
  }
}

/// Default error display widget
class ErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final String? title;
  final String? message;

  const ErrorWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 40,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              title ?? 'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message ?? 'An unexpected error occurred. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off,
                color: AppColors.warning,
                size: 40,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'No Internet Connection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message ?? 'Please check your internet connection and try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Timeout error widget
class TimeoutErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const TimeoutErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timeout icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_off,
                color: AppColors.info,
                size: 40,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Request Timed Out',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              'The server took too long to respond. Please try again later.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
