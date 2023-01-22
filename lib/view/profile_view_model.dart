import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../model/kullanici.dart';
import '../service/auth.dart';
import 'login_page_view.dart';

class UpdateProfileView extends ChangeNotifier {
  Future<void> updateUser(
      {required String adres,
      required String email,
      required String sifre,
      required Kullanici kullanici}) async {
    var updateUser = Kullanici(
        adres: email.length > 0 ? email : kullanici.adres,
        email: email.length > 0 ? email : kullanici.email,
        id: FirebaseAuth.instance.currentUser?.uid ?? '',
        sifre: sifre.length > 0 ? sifre : kullanici.sifre);
    await FirebaseFirestore.instance
        .collection('kullanici')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update(updateUser.toJson());
  }

  signOut() async {
    await Auth().signOut();
    Get.to(LoginPage());
  }
}
