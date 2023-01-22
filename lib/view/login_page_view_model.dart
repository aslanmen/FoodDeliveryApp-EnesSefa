import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../model/kullanici.dart';
import 'homepage_view.dart';

class LoginPageOperations extends ChangeNotifier {
  Future<void> signIn({
    required String email,
    required String sifre,
  }) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: sifre);
    Get.to(HomePage());
  }
}
