import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class Order {
  final String id, userId, status;
  final List<CartItem> items;
  final int total;
  final Timestamp createdAt;

  Order({ required this.id, required this.userId, required this.items,
    required this.total, required this.status, required this.createdAt });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return Order(
      id: doc.id,
      userId: d['userId'],
      items: (d['items'] as List)
          .map((e) => CartItem.fromJson(e)).toList(),
      total: d['total'],
      status: d['status'],
      createdAt: d['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'status': status,
    'createdAt': createdAt,
  };
}