
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import 'payment_screen.dart';

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
        Expanded(
          child: ListView.builder(
            itemCount: cart.items.length,
            itemBuilder: (context, i) {
              final item = cart.items[i];
              return ListTile(
                leading: item.imageUrl.startsWith('http')
                    ? Image.network(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                    : Image.asset(item.imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(item.name),
                subtitle: Text('${item.price}원 × ${item.quantity}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => context
                      .read<CartModel>()
                      .removeItem(item.productId),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '총액: ${context.read<CartModel>().totalPrice}원',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // 결제 화면으로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentScreen(),
              ),
            );
          },
          child: const Text('결제하기'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}