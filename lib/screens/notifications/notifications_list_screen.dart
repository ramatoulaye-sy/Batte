import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/helpers.dart';
import '../../services/supabase_service.dart';

/// Écran de liste des notifications avec badge
class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      final response = await SupabaseService.client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: BatteColors.primary,
        actions: [
          if (_notifications.any((n) => !n['is_read']))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Tout marquer comme lu',
                style: TextStyle(color: BatteColors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: BatteColors.mutedForeground,
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos notifications apparaîtront ici',
            style: TextStyle(
              color: BatteColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['is_read'] ?? false;
    final type = notification['type'] ?? 'info';
    
    IconData icon;
    Color color;
    
    switch (type) {
      case 'success':
        icon = Icons.check_circle;
        color = BatteColors.success;
        break;
      case 'warning':
        icon = Icons.warning;
        color = BatteColors.warning;
        break;
      case 'error':
        icon = Icons.error;
        color = BatteColors.destructive;
        break;
      default:
        icon = Icons.info;
        color = BatteColors.info;
    }

    return Dismissible(
      key: Key(notification['id']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteNotification(notification['id']),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: BatteColors.destructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: BatteColors.white),
      ),
      child: GestureDetector(
        onTap: () => _markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead ? BatteColors.white : color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isRead ? BatteColors.border : color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: BatteColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Helpers.formatDate(
                        DateTime.parse(notification['created_at']),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: BatteColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (notification['is_read']) return;

    try {
      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notification['id']);

      setState(() {
        notification['is_read'] = true;
      });
    } catch (e) {
      // Ignore silently
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;

      await SupabaseService.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
      });
    } catch (e) {
      // Ignore silently
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await SupabaseService.client
          .from('notifications')
          .delete()
          .eq('id', id);
    } catch (e) {
      // Ignore silently
    }
  }
}

