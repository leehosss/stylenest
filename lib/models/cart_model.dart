// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  // key: "productId|size|color"
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalPrice =>
      _items.values
          .fold(0, (sum, item) => sum + item.price * item.quantity);

  void addItem({
    required String productId,
    required String name,
    required String imageUrl,
    required int price,
    required String size,
    required String color,
    int quantity = 1,
  }) {
    final key = _makeKey(productId, size, color);

    if (_items.containsKey(key)) {
      _items.update(
        key,
            (existing) =>
            existing.copyWith(quantity: existing.quantity + quantity),
      );
    } else {
      _items[key] = CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
        size: size,
        color: color,
      );
    }

    notifyListeners();
  }

  void updateQuantity(String productId, String size, String color,
      int quantity) {
    final key = _makeKey(productId, size, color);
    if (!_items.containsKey(key)) return;
    if (quantity <= 0) {
      _items.remove(key);
    } else {
      _items.update(
        key,
            (existing) => existing.copyWith(quantity: quantity),
      );
    }
    notifyListeners();
  }

  void increment(String productId, String size, String color) {
    final key = _makeKey(productId, size, color);
    if (!_items.containsKey(key)) return;
    final cur = _items[key]!;
    updateQuantity(productId, size, color, cur.quantity + 1);
  }

  void decrement(String productId, String size, String color) {
    final key = _makeKey(productId, size, color);
    if (!_items.containsKey(key)) return;
    final cur = _items[key]!;
    updateQuantity(productId, size, color, cur.quantity - 1);
  }

  void removeItem(String productId, String size, String color) {
    final key = _makeKey(productId, size, color);
    _items.remove(key);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  String _makeKey(String id, String size, String color) => '$id|$size|$color';
}
