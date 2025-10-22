import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

/// Widget de chargement
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  
  const LoadingWidget({
    Key? key,
    this.message,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? BatteColors.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: BatteColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget d'erreur
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: BatteColors.destructive,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: BatteColors.foreground,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: BatteColors.primary,
                  foregroundColor: BatteColors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget vide
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  
  const EmptyWidget({
    Key? key,
    required this.message,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: BatteColors.mutedForeground,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: BatteColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

