import 'package:hive_flutter/hive_flutter.dart';
import 'package:safeguardian_ci_new/data/models/item.dart';

class ItemRepository {
  static const String _boxName = 'items';

  /// Open the box lazily and reuse it
  Future<Box<ValuedItem>> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<ValuedItem>(_boxName);
    }
    return Hive.box<ValuedItem>(_boxName);
  }

  /// Get all items for a specific user
  Future<List<ValuedItem>> getItemsForUser(String userId) async {
    final box = await _getBox();
    return box.values.where((item) => item.userId == userId).toList();
  }

  /// Add a new item
  Future<void> addItem(ValuedItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  /// Update an existing item
  Future<void> updateItem(ValuedItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    final box = await _getBox();
    await box.delete(itemId);
  }

  /// Get a specific item by ID
  Future<ValuedItem?> getItemById(String itemId) async {
    final box = await _getBox();
    return box.get(itemId);
  }

  /// Get items by category
  Future<List<ValuedItem>> getItemsByCategory(
    String userId,
    String category,
  ) async {
    final box = await _getBox();
    return box.values
        .where(
          (item) => item.userId == userId && item.category.name == category,
        )
        .toList();
  }

  /// Search items by name or description
  Future<List<ValuedItem>> searchItems(String userId, String query) async {
    final box = await _getBox();
    final lowerQuery = query.toLowerCase();
    return box.values
        .where(
          (item) =>
              item.userId == userId &&
              (item.name.toLowerCase().contains(lowerQuery) ||
                  item.description.toLowerCase().contains(lowerQuery)),
        )
        .toList();
  }
}
