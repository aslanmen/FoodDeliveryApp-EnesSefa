import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/kullanici.dart';
import '../model/siparis.dart';
import '../model/yorum.dart';

class DegerlendirOperations extends ChangeNotifier {
  Future<void> addYorum(
      {required double hizrating,
      required double lezzetrating,
      required String name,
      required double servisrating,
      required String yorumController}) async {
    var newYorum = Yorum(
        hizPuan: hizrating.toString(),
        id: "id",
        kullaniciId: FirebaseAuth.instance.currentUser?.uid ?? '',
        lezzetPuan: lezzetrating.toString(),
        restaurantId: name,
        servisPuan: servisrating.toString(),
        yorum: yorumController);
    await FirebaseFirestore.instance
        .collection("yorumlar")
        .add(newYorum.toJson());
  }

  Future<void> setSiparis({required Siparis siparis}) async {
    var newSiparis = Siparis(
        adres: siparis.adres,
        gun: siparis.gun,
        id: "id",
        kullaniciId: siparis.kullaniciId,
        puanlama: "true",
        restaurantId: siparis.restaurantId,
        saat: siparis.saat,
        siparisSure: siparis.siparisSure,
        tutar: siparis.tutar);
    await FirebaseFirestore.instance
        .collection("siparisler")
        .doc(siparis.id)
        .set(newSiparis.toJson());
  }
}
