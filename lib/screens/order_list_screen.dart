import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/order.dart' as order_model;

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return StreamBuilder<List<order_model.Order>>(
      stream: FirestoreService().streamUserOrders(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('에러: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!;
        if (orders.isEmpty) {
          return const Center(child: Text('주문 내역이 없습니다'));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('총액: ${o.total}원'),
                subtitle: Text(
                  '주문일: ${o.createdAt.toDate().toLocal().toString().split('.').first}\n'
                      '상태: ${o.status}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
