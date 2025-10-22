import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../core/constants/colors.dart';

class OfflineBadge extends StatefulWidget {
  const OfflineBadge({super.key});

  @override
  State<OfflineBadge> createState() => _OfflineBadgeState();
}

class _OfflineBadgeState extends State<OfflineBadge> {
  final ConnectivityService _connectivity = ConnectivityService();
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _online = _connectivity.isOnline;
    _connectivity.onStatusChange.listen((online) {
      if (mounted) {
        setState(() => _online = online);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_online) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: BatteColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, size: 14, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Hors ligne',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
