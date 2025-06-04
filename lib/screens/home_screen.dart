import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/cart_item.dart';
import '../models/cart_model.dart';
import '../models/products_model.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  late final PageController _bannerController;
  int _bannerPage = 0;

  final List<Widget> _pages = const [
    ProductListScreen(),
    CategoryScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    '홈',
    '카테고리',
    '찜',
    '장바구니',
    '마이페이지',
  ];

  // 로컬 배너 이미지 경로
  final List<String> _bannerImages = [
    'assets/images/be/stl.png',
  ];

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  Widget _buildHomeBannerAndRecommend() {
    final allProducts = List<Product>.from(
      context
          .watch<ProductsModel>()
          .items,
    )
      ..shuffle();
    final recommended = allProducts.take(5).toList();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            onPageChanged: (i) => setState(() => _bannerPage = i),
            itemBuilder: (context, index) =>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _bannerImages[index],
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '오늘의 추천',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductListScreen(),
                    ),
                  );
                },
                child: const Text('더보기'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommended.length,
            itemBuilder: (context, i) {
              final p = recommended[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: p),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.imageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(
                                color: Colors.grey.shade200,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 28,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.name,
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${p.price.toString().replaceAllMapped(
                            RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}원',
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentTab]),
        // 홈 탭 외엔 검색/알림 버튼 제거
      ),
      body: Column(
        children: [
          if (_currentTab == 0) _buildHomeBannerAndRecommend(),
          Expanded(child: _pages[_currentTab]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: '카테고리'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: '찜'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: '장바구니'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
        onTap: (idx) => setState(() => _currentTab = idx),
      ),
    );
  }
}
