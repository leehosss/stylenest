import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class ProductsModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  List<Product> items = [];
  bool isLoading = true;
  String? error;

  ProductsModel() { _load(); }

  void _load() {
    _db.collection('products')
        .snapshots()
        .listen((snap) {
      items = snap.docs.map((d) => Product.fromFirestore(d)).toList();
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    });
  }
}
