import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobil_projesi/model/sepet.dart';
import '../model/kullanici.dart';
import '../model/siparis.dart';

class SepetPageOperations extends ChangeNotifier {
  Future<void> addSiparis(
      {required List<SepetObject> listedDatas,
      required Function calculateAmount,
      required Kullanici kullanici,
      required Function fetchSiparisData}) async {
    var newSiparis = Siparis(
        gun: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        id: "id",
        kullaniciId: FirebaseAuth.instance.currentUser?.uid ?? '',
        restaurantId: listedDatas[0].restaurantId,
        saat: DateFormat('kk:mm:ss').format(DateTime.now()),
        tutar: calculateAmount(),
        siparisSure: "20",
        adres: kullanici.adres,
        puanlama: "false");
    await FirebaseFirestore.instance
        .collection("siparisler")
        .add(newSiparis.toJson());
    fetchSiparisData();
  }

  Future<void> deleteSepetData(String id) async {
    await FirebaseFirestore.instance.collection('sepet').doc(id).delete();
  }
}
