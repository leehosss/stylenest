// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  UserModel() {
    // FirebaseAuth 상태 변화에 따라 롤 로드
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadRole(user.uid);
      } else {
        _isAdmin = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    // Firestore에 저장된 isAdmin 값(true/false)
    _isAdmin = (doc.data()?['isAdmin'] as bool?) ?? false;
    notifyListeners();
  }
}
