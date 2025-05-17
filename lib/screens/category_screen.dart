// lib/screens/category_screen.dart

import 'package:flutter/material.dart';
import 'product_list_screen.dart';
import '../services/firestore_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late final TabController _mainTabController;

  // 인기 검색어
  final FirestoreService _fs = FirestoreService();
  List<String> _popular = [];

  // 전체/남성/여성 필터
  final _genderTabs = ['전체', '남성', '여성'];
  int _genderIndex = 0;

  // 사용자 지정 카테고리 목록
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

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _loadPopular();
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
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 인기 검색어 Chips
            if (_popular.isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            // 1) 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '상품명으로 검색',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearchSubmitted,
              ),
            ),

            // 2) 카테고리 / 서비스 탭
            TabBar(
              controller: _mainTabController,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: '카테고리'),
                Tab(text: '서비스'),
              ],
            ),

            // 3) 전체/남성/여성 필터
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
                              color:
                              selected ? Colors.black : Colors.transparent),
                        ),
                      ),
                      child: Text(
                        _genderTabs[i],
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.grey,
                          fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // 4) 카테고리 그리드 / 서비스 탭뷰
            Expanded(
              child: TabBarView(
                controller: _mainTabController,
                children: [
                  // — 카테고리 뷰
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (_, idx) {
                      final name = _categories[idx];
                      final assetPath = 'assets/icons/$name.png';
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductListScreen(
                                    filterCategory: name,
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                assetPath,
                                width: 48,
                                height: 48,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // — 서비스 뷰 (미구현)
                  const Center(child: Text('서비스 준비중입니다')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
