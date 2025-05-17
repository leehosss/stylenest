import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String productId;
  final String userId;
  final String userEmail;
  final String comment;
  final int rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userEmail,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory Review.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      productId: data['productId'],
      userId: data['userId'],
      userEmail: data['userEmail'],
      comment: data['comment'],
      rating: (data['rating'] as num).toInt(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() =>
      {
        'productId': productId,
        'userId': userId,
        'userEmail': userEmail,
        'comment': comment,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
