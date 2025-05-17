// lib/models/auth_model.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  AuthModel() {
    _auth.authStateChanges().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  Future<void> signUp(String email, String pw) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: pw);
    // Firestore에 기본 유저 문서 생성 (isAdmin=false)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({'isAdmin': false});
  }

  Future<void> signIn(String email, String pw) async {
    await _auth.signInWithEmailAndPassword(email: email, password: pw);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
