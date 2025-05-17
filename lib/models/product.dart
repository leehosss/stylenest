// lib/models/product.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final int stock;
  final String category;
  final String gender; // ← 새로 추가된 필드

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.gender, // ← 생성자에도 포함
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '이름 없음',
      description: data['description'] as String? ?? '',
      price: data['price'] is int
          ? data['price'] as int
          : int.tryParse(data['price'].toString()) ?? 0,
      imageUrl: data['imageUrl'] as String?
          ?? 'https://via.placeholder.com/150',
      stock: data['stock'] is int
          ? data['stock'] as int
          : int.tryParse(data['stock']?.toString() ?? '') ?? 0,
      category: data['category'] as String? ?? '전체',
      gender: data['gender'] as String? ?? '전체', // ← Firestore에서 읽어오기
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'stock': stock,
        'category': category,
        'gender': gender, // ← 저장할 때 포함
      };
}
