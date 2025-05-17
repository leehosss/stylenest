// lib/screens/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/products_model.dart';
import '../models/cart_model.dart';
import '../models/review.dart';
import '../services/firestore_service.dart';
import '../models/auth_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final PageController _pageController = PageController();
  final FirestoreService _fs = FirestoreService();
  late Stream<bool> _favStream;

  int _currentPage = 0;
  int _quantity = 1;

  // 옵션 데이터
  final List<String> _sizes = ['S', 'M', 'L', 'XL'];
  final List<String> _colors = ['블랙', '그레이', '블루', '레드'];

  String? _selectedSize;
  String? _selectedColor;

  bool _isSizeDropdownOpen = false;
  bool _isColorDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    final user = context
        .read<AuthModel>()
        .user;
    if (user != null) {
      _favStream = _fs.isFavorite(user.uid, widget.product.id);
    } else {
      _favStream = Stream.value(false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showOptionsSheet({required bool forCart}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery
                  .of(ctx)
                  .viewInsets
                  .bottom,
              left: 16,
              right: 16,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '옵션을 선택해주세요',
                    style: Theme
                        .of(ctx)
                        .textTheme
                        .titleMedium,
                  ),
                ),
                const SizedBox(height: 16),

                // 사이즈 선택
                GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _isSizeDropdownOpen = !_isSizeDropdownOpen;
                      if (_isSizeDropdownOpen) _isColorDropdownOpen = false;
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedSize != null
                              ? '사이즈: $_selectedSize'
                              : '사이즈 선택',
                          style: Theme
                              .of(ctx)
                              .textTheme
                              .bodyLarge,
                        ),
                        Icon(_isSizeDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
                if (_isSizeDropdownOpen)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _sizes.map((size) {
                        final selected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedSize = size;
                              _isSizeDropdownOpen = false;
                            });
                            setState(() => _selectedSize = size);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300, width: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  size,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selected
                                        ? Theme
                                        .of(context)
                                        .primaryColor
                                        : null,
                                  ),
                                ),
                                if (selected)
                                  Icon(Icons.check,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                      size: 20),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 12),

                // 컬러 선택
                GestureDetector(
                  onTap: () {
                    setModalState(() {
                      _isColorDropdownOpen = !_isColorDropdownOpen;
                      if (_isColorDropdownOpen) _isSizeDropdownOpen = false;
                    });
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedColor != null
                              ? '색상: $_selectedColor'
                              : '색상 선택',
                          style: Theme
                              .of(ctx)
                              .textTheme
                              .bodyLarge,
                        ),
                        Icon(_isColorDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
                if (_isColorDropdownOpen)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _colors.map((colorName) {
                        final selected = _selectedColor == colorName;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedColor = colorName;
                              _isColorDropdownOpen = false;
                            });
                            setState(() => _selectedColor = colorName);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey.shade300, width: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  colorName,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: selected
                                        ? Theme
                                        .of(context)
                                        .primaryColor
                                        : null,
                                  ),
                                ),
                                if (selected)
                                  Icon(Icons.check,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                      size: 20),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // 수량 선택
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('수량', style: Theme
                        .of(ctx)
                        .textTheme
                        .bodyLarge),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setModalState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('$_quantity',
                              style: Theme
                                  .of(ctx)
                                  .textTheme
                                  .bodyLarge),
                        ),
                        IconButton(
                          onPressed: () => setModalState(() => _quantity++),
                          icon: const Icon(Icons.add),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedSize != null &&
                        _selectedColor != null)
                        ? () {
                      Navigator.pop(ctx);
                      _onOptionConfirmed(forCart: forCart);
                    }
                        : null,
                    child:
                    Text(forCart ? '장바구니에 담기' : '바로 구매'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
      },
    );
  }

  void _onOptionConfirmed({required bool forCart}) {
    final p = widget.product;
    if (forCart) {
      context.read<CartModel>().addItem(
        productId: p.id,
        name: '${p.name} ($_selectedSize, $_selectedColor)',
        price: p.price * _quantity,
        imageUrl: p.imageUrl,
        quantity: _quantity,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('장바구니에 담겼습니다')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('구매를 진행합니다')));
    }
    setState(() {
      _selectedSize = null;
      _selectedColor = null;
      _quantity = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = [product.imageUrl];
    final related = context
        .watch<ProductsModel>()
        .items
        .where((p) => p.id != product.id)
        .take(5)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              StreamBuilder<bool>(
                stream: _favStream,
                builder: (ctx, snap) {
                  final isFav = snap.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      final user = context
                          .read<AuthModel>()
                          .user!;
                      _fs.toggleFavorite(
                        user.uid,
                        product.id,
                        {
                          'name': product.name,
                          'price': product.price,
                          'imageUrl': product.imageUrl,
                          'addedAt': FieldValue.serverTimestamp(),
                        },
                      );
                    },
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) =>
                        Image.network(images[i], fit: BoxFit.cover),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        images.length,
                            (i) =>
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == i ? 12 : 8,
                              height: _currentPage == i ? 12 : 8,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(
                                    _currentPage == i ? 0.9 : 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 프로모션 배너
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_offer, color: Colors.deepOrange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '지금 구매 시 쿠폰 10% 즉시 할인!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),

                // 가격·별점·배송
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${product.price.toString().replaceAllMapped(
                          RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}원',
                      style: Theme
                          .of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text('4.8',
                                style:
                                Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium),
                            const SizedBox(width: 4),
                            Text('(120)',
                                style:
                                Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('무료배송',
                            style: Theme
                                .of(context)
                                .textTheme
                                .bodySmall),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 상세정보 & 리뷰 탭
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Theme
                            .of(context)
                            .primaryColor,
                        tabs: const [Tab(text: '상품정보'), Tab(text: '리뷰')],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            // 상품정보
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(product.description,
                                  style:
                                  Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium),
                            ),
                            // 리뷰 리스트 및 작성
                            StreamBuilder<List<Review>>(
                              stream: _fs.reviewsStream(product.id),
                              builder: (ctx, snap) {
                                final reviews = snap.data ?? [];
                                return Column(
                                  children: [
                                    Expanded(
                                      child: reviews.isEmpty
                                          ? const Center(
                                          child: Text('첫 리뷰를 남겨보세요!'))
                                          : ListView.builder(
                                        itemCount: reviews.length,
                                        itemBuilder: (_, i) {
                                          final r = reviews[i];
                                          return ListTile(
                                            title: Text(r.userEmail),
                                            subtitle: Text(r.comment),
                                            trailing:
                                            Text('${r.rating}★'),
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _showReviewDialog(context),
                                        child: const Text('리뷰 작성'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 200),
              ]),
            ),
          ),
        ],
      ),

      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showOptionsSheet(forCart: false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme
                      .of(context)
                      .primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('구매하기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showOptionsSheet(forCart: true),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('장바구니'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    final _commentCtrl = TextEditingController();
    int _rating = 5;

    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('리뷰 작성'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  allowHalfRating: false,
                  itemBuilder: (_, __) =>
                  const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (r) => _rating = r.toInt(),
                ),
                TextField(
                  controller: _commentCtrl,
                  decoration: const InputDecoration(hintText: '댓글을 입력하세요'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소')),
              ElevatedButton(
                onPressed: () {
                  final auth = context.read<AuthModel>();
                  final user = auth.user;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 필요합니다')));
                    return;
                  }
                  final review = Review(
                    id: '',
                    productId: widget.product.id,
                    userId: user.uid,
                    userEmail: user.email!,
                    comment: _commentCtrl.text.trim(),
                    rating: _rating,
                    createdAt: DateTime.now(),
                  );
                  _fs.addReview(review).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('리뷰가 등록되었습니다')));
                    Navigator.pop(context);
                  }).catchError((e, st) {
                    print('❌ 리뷰 등록 실패: $e\n$st');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                        Text('리뷰 등록 중 오류가 발생했습니다:\n$e')));
                  });
                },
                child: const Text('등록'),
              ),
            ],
          ),
    );
  }
}
