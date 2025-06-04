// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/cart_item.dart';
import 'payment_screen.dart'; // 결제 화면 임포트

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    if (cart.items.isEmpty) {
      return const Center(child: Text('장바구니가 비어있습니다'));
    }

    return Column(
      children: [
        // 1) 아이템 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final CartItem item = cart.items[i];
              return ListTile(
                leading: item.imageUrl.startsWith('http')
                    ? Image.network(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                    : Image.asset(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                // size, color 정보 노출
                title: Text('${item.name} (${item.size}, ${item.color})'),
                subtitle: Text('${item.price}원'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        context.read<CartModel>().decrement(
                          item.productId,
                          item.size,
                          item.color,
                        );
                      },
                    ),
                    Text('${item.quantity}',
                        style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        context.read<CartModel>().increment(
                          item.productId,
                          item.size,
                          item.color,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        context.read<CartModel>().removeItem(
                          item.productId,
                          item.size,
                          item.color,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // 2) 총액
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '총액: ${cart.totalPrice}원',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),

        // 3) 결제하기 버튼
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ElevatedButton(
            onPressed: () {
              // 결제 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              );
            },
            child: const Text('결제하기'),
          ),
        ),
      ],
    );
  }
}
