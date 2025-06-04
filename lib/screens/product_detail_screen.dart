// lib/screens/product_detail_screen.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/cart_model.dart';
import '../models/products_model.dart';
import '../models/review.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/vton_service.dart';
import 'tryon_result_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Firebase & Favorites
  late final FirestoreService _fs;
  late final Stream<bool> _favStream;

  // Carousel
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 옵션
  int _quantity = 1;
  String? _selectedSize, _selectedColor;
  bool _isSizeOpen = false,
      _isColorOpen = false;
  final _sizes = ['S', 'M', 'L', 'XL'];
  final _colors = ['블랙', '그레이', '블루', '레드'];

  // VTON
  final ImagePicker _picker = ImagePicker();
  late final VtonService _vton;
  bool _loadingTryOn = false;

  @override
  void initState() {
    super.initState();
    final user = context
        .read<AuthModel>()
        .user;
    _fs = FirestoreService(userId: user?.uid);
    _favStream =
    user != null ? _fs.isFavorite(widget.product.id) : Stream.value(false);
    _vton = VtonService(apiUrl: 'https://b09a-50-173-30-254.ngrok-free.app');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 구매/장바구니 옵션 모달
  Future<void> _showOptions({required bool forCart}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) =>
          StatefulBuilder(builder: (ctx, setM) {
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('옵션을 선택해주세요',
                          style: Theme
                              .of(ctx)
                              .textTheme
                              .titleMedium),
                    ),
                    const SizedBox(height: 16),

                    // 사이즈
                    GestureDetector(
                      onTap: () =>
                          setM(() {
                            _isSizeOpen = !_isSizeOpen;
                            if (_isSizeOpen) _isColorOpen = false;
                          }),
                      child: _buildDropdown(
                        ctx,
                        _selectedSize == null
                            ? '사이즈 선택'
                            : '사이즈: $_selectedSize',
                        _isSizeOpen,
                      ),
                    ),
                    if (_isSizeOpen)
                      ..._sizes.map((s) =>
                          _buildListTile(
                            s,
                            _selectedSize == s,
                                () {
                              setM(() => _selectedSize = s);
                              setState(() => _selectedSize = s);
                            },
                          )),

                    const SizedBox(height: 12),

                    // 컬러
                    GestureDetector(
                      onTap: () =>
                          setM(() {
                            _isColorOpen = !_isColorOpen;
                            if (_isColorOpen) _isSizeOpen = false;
                          }),
                      child: _buildDropdown(
                        ctx,
                        _selectedColor == null
                            ? '색상 선택'
                            : '색상: $_selectedColor',
                        _isColorOpen,
                      ),
                    ),
                    if (_isColorOpen)
                      ..._colors.map((c) =>
                          _buildListTile(
                            c,
                            _selectedColor == c,
                                () {
                              setM(() => _selectedColor = c);
                              setState(() => _selectedColor = c);
                            },
                          )),

                    const SizedBox(height: 24),

                    // 수량
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
                              icon: const Icon(Icons.remove),
                              onPressed: _quantity > 1
                                  ? () => setM(() => _quantity--)
                                  : null,
                            ),
                            Text('$_quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setM(() => _quantity++),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 확인
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_selectedSize != null &&
                            _selectedColor != null)
                            ? () {
                          Navigator.pop(ctx);
                          _confirm(forCart: forCart);
                        }
                            : null,
                        child:
                        Text(forCart ? '장바구니에 담기' : '바로 구매'),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _buildDropdown(BuildContext ctx, String label, bool open) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme
              .of(ctx)
              .textTheme
              .bodyLarge),
          Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
        ],
      ),
    );
  }

  Widget _buildListTile(String text, bool selected, VoidCallback onTap) {
    return ListTile(
      title: Text(text),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }

  void _confirm({required bool forCart}) {
    final p = widget.product;
    if (forCart) {
      context.read<CartModel>().addItem(
        productId: p.id,
        name: '${p.name} ($_selectedSize, $_selectedColor)',
        price: p.price * _quantity,
        imageUrl: p.imageUrl,
        quantity: _quantity,
        size: _selectedSize!,
        color: _selectedColor!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('장바구니에 담겼습니다')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('바로 구매를 진행합니다')));
    }
    setState(() {
      _selectedSize = null;
      _selectedColor = null;
      _quantity = 1;
    });
  }

  void _showReviewDialog(BuildContext context) {
    final ctrl = TextEditingController();
    int rating = 5;
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
                  onRatingUpdate: (r) => rating = r.toInt(),
                ),
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(hintText: '댓글을 입력하세요'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('취소')),
              ElevatedButton(
                onPressed: () {
                  final user = context
                      .read<AuthModel>()
                      .user;
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
                    comment: ctrl.text.trim(),
                    rating: rating,
                    createdAt: DateTime.now(),
                  );
                  _fs.addReview(review).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('리뷰가 등록되었습니다')));
                    Navigator.pop(context);
                  }).catchError((e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('리뷰 등록 실패: $e')));
                  });
                },
                child: const Text('등록'),
              ),
            ],
          ),
    );
  }

  /// 사용자 사진만 갤러리에서 고르고, asset 이미지를 자동으로 업로드하는 가상 피팅
  Future<void> _showVirtualTryOn() async {
    // 1) 사용자 사진 선택
    final XFile? person =
    await _picker.pickImage(source: ImageSource.gallery);
    if (person == null) return;

    setState(() => _loadingTryOn = true);
    try {
      // 2) 사용자 사진 업로드
      final userImageId = await _vton.uploadUserImage(person);

      // 3) asset 이미지(제품 상세의 imageUrl)를 서버에 바로 업로드
      final clothingId = await _vton.uploadClothingFromAsset(
        widget.product.imageUrl, // e.g. "assets/images/tshirt.png"
        widget.product.category,
      );


      // 4) 인체 파싱
      final parsingId = await _vton.humanParsing(person);

      // 5) 가상 피팅 요청
      final resultId = await _vton.tryOn(
        userImageId: userImageId,
        clothingId: clothingId,
        category: widget.product.category,
        parsingId: parsingId,
      );

      // 6) 결과 이미지 다운로드
      final Uint8List imageBytes =
      await _vton.downloadResultImage(resultId);

      // 7) 결과 화면으로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TryOnResultScreen(imageBytes: imageBytes),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('가상 피팅 실패: $e')));
    } finally {
      setState(() => _loadingTryOn = false);
    }
  }

  Widget _buildReviewList(BuildContext ctx, AsyncSnapshot<List<Review>> snap) =>
      snap.data == null || snap.data!.isEmpty
          ? const Center(child: Text('첫 리뷰를 남겨보세요!'))
          : ListView.builder(
        itemCount: snap.data!.length,
        itemBuilder: (_, i) {
          final r = snap.data![i];
          return ListTile(
            title: Text(r.userEmail),
            subtitle: Text(r.comment),
            trailing: Text('${r.rating}★'),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final images = [p.imageUrl];
    final related = context
        .watch<ProductsModel>()
        .items
        .where((x) => x.id != p.id)
        .take(5)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 이미지 캐러셀
          SliverAppBar(
            pinned: true,
            expandedHeight: 360,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) =>
                    Image.network(images[i], fit: BoxFit.cover),
              ),
            ),
            actions: [
              StreamBuilder<bool>(
                stream: _favStream,
                builder: (ctx, snap) {
                  final isFav = snap.data ?? false;
                  return IconButton(
                    icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: Colors.redAccent),
                    onPressed: () {
                      final user = context
                          .read<AuthModel>()
                          .user!;
                      _fs.toggleFavorite(p.id, {
                        'name': p.name,
                        'price': p.price,
                        'imageUrl': p.imageUrl,
                        'addedAt': FieldValue.serverTimestamp(),
                      });
                    },
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),

          // 상품명 & 가격
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${p.price.toString().replaceAllMapped(
                        RegExp(r"\\B(?=(\\d{3})+(?!\\d))"),
                            (m) => ',')}원',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 가상 피팅 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton(
                onPressed:
                _loadingTryOn ? null : _showVirtualTryOn,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _loadingTryOn
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('가상 피팅'),
              ),
            ),
          ),

          // 탭: 상품정보 / 리뷰
          SliverPadding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                        height: 340,
                        child: TabBarView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                p.description,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                            StreamBuilder<List<Review>>(
                              stream: _fs.reviewsStream(p.id),
                              builder: _buildReviewList,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          // 추천 상품
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('추천 상품',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                itemBuilder: (_, i) {
                  final r = related[i];
                  return GestureDetector(
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailScreen(product: r)),
                        ),
                    child: SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(8),
                            child: Image.network(r.imageUrl,
                                height: 100,
                                width: 140,
                                fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 6),
                          Text(r.name,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis),
                          Text(
                              '${r.price.toString().replaceAllMapped(
                                  RegExp(r"\\B(?=(\\d{3})+(?!\\d))"),
                                      (m) => ',')}원'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // 하단 구매/장바구니 버튼
      bottomSheet: Container(
        color: Colors.white,
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showOptions(forCart: false),
                child: const Text('구매하기'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showOptions(forCart: true),
                child: const Text('장바구니'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
