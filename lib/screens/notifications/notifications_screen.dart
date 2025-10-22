import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../services/supabase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: BatteColors.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Aucune notification'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final n = _items[i];
                    return ListTile(
                      tileColor: BatteColors.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Text(n['title'] ?? 'Notification'),
                      subtitle: Text(n['message'] ?? ''),
                      trailing: n['is_read'] == true
                          ? const Icon(Icons.done, color: Colors.green)
                          : TextButton(
                              onPressed: () async {
                                await SupabaseService.markNotificationAsRead(
                                  n['id'].toString(),
                                );
                                _load();
                              },
                              child: const Text('Marquer lu'),
                            ),
                    );
                  },
                ),
    );
  }
}


