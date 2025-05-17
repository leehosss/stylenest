// lib/screens/admin_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String imageUrl = '';
  int price = 0;
  int stock = 0;
  String category = '상의'; // ★ 초기값
  final _categories = [ // ★ 드롭다운 옵션
    '상의', '긴상의', '원피스', '롱 드레스', '짧은 치마', '일반치마', '긴치마', '바지',
  ];
  bool _loading = false;

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _loading = true);
    try {
      final data = {
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'stock': stock,
        'category': category, // ★ 추가
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('products')
          .add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품이 성공적으로 추가되었습니다')),
      );
      _formKey.currentState!.reset();
      setState(() => category = _categories.first); // 드롭다운 초기화
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 모드')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 상품명
              TextFormField(
                decoration: const InputDecoration(labelText: '상품명'),
                validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
                onSaved: (v) => name = v!.trim(),
              ),
              const SizedBox(height: 12),

              // 이미지 URL
              TextFormField(
                decoration: const InputDecoration(labelText: '이미지 URL'),
                validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
                onSaved: (v) => imageUrl = v!.trim(),
              ),
              const SizedBox(height: 12),

              // 가격
              TextFormField(
                decoration: const InputDecoration(labelText: '가격'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return '필수 입력';
                  if (int.tryParse(v) == null) return '숫자만 입력';
                  return null;
                },
                onSaved: (v) => price = int.parse(v!),
              ),
              const SizedBox(height: 12),

              // 재고
              TextFormField(
                decoration: const InputDecoration(labelText: '재고'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return '필수 입력';
                  if (int.tryParse(v) == null) return '숫자만 입력';
                  return null;
                },
                onSaved: (v) => stock = int.parse(v!),
              ),
              const SizedBox(height: 12),

              // 카테고리 선택 드롭다운 ★
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: '카테고리'),
                value: category,
                items: _categories
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v ?? category),
              ),
              const SizedBox(height: 24),

              // 제출 버튼
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _addProduct,
                child: const Text('상품 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
