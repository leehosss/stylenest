// lib/models/cart_item.dart
class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final int price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      name:       json['name']       as String,
      imageUrl:   json['imageUrl']   as String,
      price:      (json['price']     as num).toInt(),
      quantity:   (json['quantity']  as num).toInt(),
    );
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
    'quantity': quantity,
  };
}
