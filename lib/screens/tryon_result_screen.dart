// lib/screens/tryon_result_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';

class TryOnResultScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const TryOnResultScreen({Key? key, required this.imageBytes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가상 피팅 결과')),
      body: Center(
        child: Image.memory(imageBytes, fit: BoxFit.contain),
      ),
    );
  }
}
