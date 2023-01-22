import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/sepet.dart';

class RestaurantPageOperations extends ChangeNotifier {
  Future<void> addSepet(String? kullanici_id, String restaurant_id,
      String urun_ad, String urun_ucret) async {
    var newSepet = SepetObject(
        id: "id",
        kullaniciId: kullanici_id ?? '',
        restaurantId: restaurant_id,
        urunAd: urun_ad,
        urunUcret: urun_ucret);
    await FirebaseFirestore.instance.collection('sepet').add(newSepet.toJson());
  }
}
