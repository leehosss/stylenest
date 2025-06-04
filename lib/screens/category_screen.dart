// lib/screens/category_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
import '../models/products_model.dart';
import '../models/product.dart';
import 'product_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FirestoreService _fs = FirestoreService();
  List<String> _popular = [];

  // 전체/남성/여성 필터
  final _genderTabs = ['전체', '남성', '여성'];
  int _genderIndex = 0;

  // 카테고리 목록
  static const List<String> _categories = [
    '일반상의',
    '긴상의',
    '일반드레스',
    '롱 드레스',
    '짧은 치마',
    '일반치마',
    '긴치마',
    '바지',
  ];

  // 현재 검색어
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadPopular();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  Future<void> _loadPopular() async {
    final terms = await _fs.getPopularSearchTerms(limit: 5);
    setState(() => _popular = terms);
  }

  Future<void> _onSearchSubmitted(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    await _fs.recordSearchTerm(t);
    await _loadPopular();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 전체 상품 리스트
    final allProducts = context
        .watch<ProductsModel>()
        .items;

    // 검색 결과 필터링
    final searchResults = _query.isEmpty
        ? <Product>[]
        : allProducts
        .where((p) => p.name.toLowerCase().contains(_query))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          // 인기 검색어 Chips
          if (_popular.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _popular.map((t) {
                  return ActionChip(
                    label: Text(t),
                    onPressed: () {
                      _searchCtrl.text = t;
                      _onSearchSubmitted(t);
                    },
                  );
                }).toList(),
              ),
            ),

          // 검색창
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '상품명으로 검색',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearchSubmitted,
            ),
          ),

          // 전체/남성/여성 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genderTabs.length,
              itemBuilder: (_, i) {
                final selected = i == _genderIndex;
                return GestureDetector(
                  onTap: () => setState(() => _genderIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 2,
                          color: selected ? Colors.black : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Text(
                      _genderTabs[i],
                      style: TextStyle(
                        color: selected ? Colors.black : Colors.grey,
                        fontWeight: selected ? FontWeight.bold : FontWeight
                            .normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 검색 결과 또는 카테고리 그리드
          Expanded(
            child: _query.isNotEmpty
                ? (searchResults.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다'))
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (_, i) {
                final p = searchResults[i];
                return ListTile(
                  leading: Image.network(
                    p.imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image),
                  ),
                  title: Text(p.name),
                  subtitle: Text('${p.price}원'),
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductListScreen(filterCategory: p.category),
                        ),
                      ),
                );
              },
            ))
                : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3 / 2,
              ),
              itemCount: _categories.length,
              itemBuilder: (_, idx) {
                final name = _categories[idx];
                return GestureDetector(
                  onTap: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductListScreen(filterCategory: name),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/$name.png',
                          width: 48,
                          height: 48,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                        ),
                        const SizedBox(height: 8),
                        Text(name, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
