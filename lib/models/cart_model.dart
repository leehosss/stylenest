// lib/models/cart_model.dart

import 'package:flutter/foundation.dart';
import 'cart_item.dart';

class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  /// 총 합계 가격
  int get totalPrice =>
      _items.values
          .fold(0, (sum, item) => sum + item.price * item.quantity);

  /// 장바구니에 담기
  void addItem({
    required String productId,
    required String name,
    required String imageUrl,
    required int price,
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
            (existing) =>
            existing.copyWith(quantity: existing.quantity + quantity),
      );
    } else {
      _items[productId] = CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// 수량 변경
  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items.update(
        productId,
            (existing) => existing.copyWith(quantity: quantity),
      );
    }
    notifyListeners();
  }

  /// 삭제
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// 비우기
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
