import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';
import '../models/order.dart' as order_model;
import '../services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cardCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  bool _processing = false;
  String? _error;

  @override
  void dispose() {
    _cardCtrl.dispose();
    _expCtrl.dispose();
    _cvcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() { _processing = true; _error = null; });
    try {
      final cart = context.read<CartModel>();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      // TODO: 실제 결제 로직 삽입
      // 임시 딜레이
      await Future.delayed(const Duration(seconds: 2));
      // 주문 생성
      final newOrder = order_model.Order(
        id: '',
        userId: uid,
        items: cart.items,
        total: cart.totalPrice,
        status: 'paid',
        createdAt: Timestamp.now(),
      );
      await FirestoreService().createOrder(newOrder);
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('결제가 완료되었습니다')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _processing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('결제')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _cardCtrl,
              decoration: const InputDecoration(labelText: '카드번호'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _expCtrl,
              decoration: const InputDecoration(labelText: '유효기간 (MM/YY)'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _cvcCtrl,
              decoration: const InputDecoration(labelText: 'CVC'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            _processing
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pay,
                child: const Text('카드 결제'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
