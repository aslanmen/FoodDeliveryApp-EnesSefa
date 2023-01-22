import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/kullanici.dart';
import '../model/siparis.dart';

class SiparislerOperations extends ChangeNotifier {
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

  filterSiparis(List<Siparis> siparisler, List<Siparis> _siparisler,
      Kullanici kullanici) {
    for (int i = 0; i < siparisler.length; i++) {
      if (siparisler[i].kullaniciId == kullanici.id) {
        _siparisler.add(siparisler[i]);
        notifyListeners();
      }
    }
  }

  int compareMinute(
      String siparis_sure, String soylenen_gun, String soylenen_saat) {
    // kullanılacak
    //var future = DateTime.now().add(const Duration(days: 0));
    //var futureString = DateFormat('dd--MM--yyyy').format(future);//kullanılacak

    //var databaseTimeString = DateFormat('kk:mm:ss').format(DateTime.now());// soylenen_gun
    List<String> databaseTimeList = []; // içini dolduralım saat ile
    List<String> databaseStringList = []; // içini dolduralm gun ile

    var nowString = DateFormat('dd/MM/yyyy').format(DateTime.now());
    var nowTimeString = DateFormat('kk:mm:ss')
        .format(DateTime.now()); // bu datasetten çekilecek
    List<String> nowTimeList = [];
    List<String> nowStringList = [];

// önce gün compare edelim sonraysa saat compare edelim
// saat farkı 1 den fazlaysa true olsun öyle olunca da
// değerlendirme kısmı açılsın

    for (int i = 0; i < soylenen_gun.length; i++) {
      if (soylenen_gun[i] != '/') {
        nowStringList.add(nowString[i]);
        databaseStringList.add(soylenen_gun[i]);
      }
    }
    for (int i = 0; i < nowTimeString.length; i++) {
      if (nowTimeString[i] != ':') {
        nowTimeList.add(nowTimeString[i]);
        databaseTimeList.add(soylenen_saat[i]);
      }
    }

    // saatler birleştirilsin
    String nowsaat = nowTimeList[0] + nowTimeList[1];
    String nowdakika = nowTimeList[2] + nowTimeList[3];

    String databasesaat = databaseTimeList[0] + databaseTimeList[1];
    String databasedakika = databaseTimeList[2] + databaseTimeList[3];

    String nowsayi1 = nowStringList[0] + nowStringList[1]; // gun verisi şimdi
    String nowsayi2 = nowStringList[2] + nowStringList[3]; // ay verisi şimdi

    String databasegun =
        databaseStringList[0] + databaseStringList[1]; // gun verisi gelecek
    String databaseay =
        databaseStringList[2] + databaseStringList[3]; // ay verisi gelecek

    print(int.parse(databasegun) - int.parse(nowsayi1));

    if (int.parse(databaseay) - int.parse(nowsayi2) == 0 &&
        int.parse(databasegun) - int.parse(nowsayi1) == 0) {
      // future'un toplam dakikayı hesaplıcaz 20 den azsa sipariş ulaşmadı 20 ile 80 arası sipariş geldi puanlama bekliyor
      // 80 den yukarıysa
      int nowtoplamdakika = int.parse(nowsaat) * 60 + int.parse(nowdakika);
      int databasetoplamdakika =
          int.parse(databasesaat) * 60 + int.parse(databasedakika);

      if (nowtoplamdakika - databasetoplamdakika < int.parse(siparis_sure)) {
        //   print(nowtoplamdakika - databasetoplamdakika);
        // print("Sipariş ulaştırılamadı");
        return 1;
      } else if (nowtoplamdakika - databasetoplamdakika >=
              int.parse(siparis_sure) &&
          nowtoplamdakika - databasetoplamdakika < 80) {
        var remain = 80 - (nowtoplamdakika - databasetoplamdakika);
        //  print("Sipariş eline ulaştı puanlama için zaman gerekiyor"+remain.toString());
        return 2;
      } else if (nowtoplamdakika - databasetoplamdakika >= 80) {
        //print("Sipariş eline ulaştı ve puanlamaya hazır durumda");
        return 3;
      }
    } else if (int.parse(databasegun) - int.parse(nowsayi1) > 0 &&
        int.parse(databaseay) - int.parse(nowsayi2) >= 0) {
      // gelecek gün büyükse ama aylar eşitse
      //print("geçti2");
      // print(nowString);
      //print(soylenen_gun);
      return 3;
    } else if (int.parse(databaseay) - int.parse(nowsayi2) > 0) {
      // direkt olarak ay daha büyükse
      //print("geçti3");
      // print(nowString);
      //print(soylenen_gun);
      return 3;
    } else if (int.parse(databasegun) - int.parse(nowsayi1) < 0 &&
        int.parse(databasegun) - int.parse(nowsayi2) > 0) {
      // gun kucukse ama ay olarak buyukse
      print("geçti4");
      print(nowString);
      print(soylenen_gun);
      return 3;
    }
    return 0;
  }
}
