import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/product.dart';
import '../models/products_model.dart';
import '../services/firestore_service.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatelessWidget {
  final String? filterCategory;

  const ProductListScreen({Key? key, this.filterCategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context
        .watch<AuthModel>()
        .user;
    final fs = FirestoreService(userId: user?.uid);
    final model = context.watch<ProductsModel>();
    final all = model.items;
    final products = (filterCategory == null || filterCategory == '전체')
        ? all
        : all.where((p) => p.category == filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(filterCategory == null || filterCategory == '전체'
            ? '전체 상품'
            : filterCategory!),
      ),
      body: Builder(builder: (_) {
        if (model.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (model.error != null) {
          return Center(child: Text('에러: ${model.error}'));
        }
        if (products.isEmpty) {
          return const Center(child: Text('등록된 상품이 없습니다.'));
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: p),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              p.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 48)),
                            ),
                          ),

                          // 찜(즐겨찾기) 버튼
                          Positioned(
                            top: 8,
                            right: 8,
                            child: StreamBuilder<bool>(
                              stream: fs.isFavorite(p.id),
                              initialData: false,
                              builder: (ctx, snap) {
                                final isFav = snap.data ?? false;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                      color:
                                      isFav ? Colors.red : Colors.grey[700],
                                    ),
                                    onPressed: () {
                                      if (user == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                            content: Text(
                                                '로그인이 필요합니다')));
                                        return;
                                      }
                                      fs.toggleFavorite(
                                        p.id,
                                        {
                                          'name': p.name,
                                          'price': p.price,
                                          'imageUrl': p.imageUrl,
                                          'addedAt':
                                          FieldValue.serverTimestamp(),
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.price.toString().replaceAllMapped(
                          RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}원',
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
