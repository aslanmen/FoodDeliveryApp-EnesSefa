import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/kullanici.dart';

class RegistraitonPageOperations extends ChangeNotifier {
  Future<void> newUser({required String email, required String sifre}) async {
    // burada verileri çekme metodu kullan eğer true dönerse böyle hesap vardır gibisinden sonra bu kayıt başarılı olamasın
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: sifre)
        .then((value) {
      FirebaseFirestore.instance
          .collection('kullanici')
          .doc(value.user?.uid)
          .set({
        "email": email,
        "sifre": sifre,
        "id": value.user?.uid,
        "adres": "Adres..."
      });
    });
    print("Kayıt Eklendi");
  }
}
