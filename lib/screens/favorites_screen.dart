// lib/screens/favorites_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import '../models/cart_item.dart';
import '../services/firestore_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthModel>();
    final user = auth.user;
    if (user == null) {
      return const Center(child: Text('로그인이 필요합니다'));
    }

    // user.uid 를 넘겨서 서비스 생성
    final fs = FirestoreService(userId: user.uid);

    return StreamBuilder<List<CartItem>>(
      // CartItem 리스트 스트림을 구독합니다
      stream: fs.streamFavorites(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final favs = snap.data ?? [];
        if (favs.isEmpty) {
          return const Center(child: Text('찜한 상품이 없습니다'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: favs.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, i) {
            final item = favs[i];
            return ListTile(
              leading: item.imageUrl.startsWith('http')
                  ? Image.network(
                item.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                item.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(item.name),
              subtitle: Text('${item.price}원'),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // 다시 toggle 해서 찜 해제
                  fs.toggleFavorite(item.productId, {
                    'name': item.name,
                    'price': item.price,
                    'imageUrl': item.imageUrl,
                    'addedAt': FieldValue.serverTimestamp(),
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}
