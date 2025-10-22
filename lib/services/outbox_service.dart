import 'package:hive/hive.dart';
import '../models/outbox_item.dart';

class OutboxService {
  static Box<OutboxItem>? _outboxBox;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(50)) {
      Hive.registerAdapter(OutboxItemAdapter());
    }
    _outboxBox = await Hive.openBox<OutboxItem>('outbox');
  }

  static Future<void> enqueue(OutboxItem item) async {
    await _outboxBox?.put(item.id, item);
  }

  static List<OutboxItem> getAll() {
    final items = _outboxBox?.values.toList() ?? [];
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  static Future<void> remove(String id) async {
    await _outboxBox?.delete(id);
  }

  static Future<void> update(OutboxItem item) async {
    await _outboxBox?.put(item.id, item);
  }

  static Future<void> clear() async {
    await _outboxBox?.clear();
  }
}
