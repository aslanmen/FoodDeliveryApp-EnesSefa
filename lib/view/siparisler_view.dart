import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/model/restorant.dart';
import 'package:mobil_projesi/view/profile_view_model.dart';
import 'package:mobil_projesi/view/siparisler_view_model.dart';
import 'package:provider/provider.dart';

import '../model/kullanici.dart';
import '../model/siparis.dart';
import 'degerlendir_view.dart';

class Siparisler extends StatefulWidget {
  Kullanici kullanici;
  List<Siparis> siparisler;
  List<Restaurant> _restorantlar;
  Siparisler(this.kullanici, this.siparisler, this._restorantlar);

  @override
  State<Siparisler> createState() =>
      _SiparislerState(kullanici, siparisler, _restorantlar);
}

class _SiparislerState extends State<Siparisler> {
  Kullanici kullanici;
  List<Siparis> siparisler;
  List<Restaurant> _restorantlar;
  _SiparislerState(this.kullanici, this.siparisler, this._restorantlar);

  // fiter siparis
  List<Siparis> _siparisler = [];
  filterSiparis() {
    for (int i = 0; i < siparisler.length; i++) {
      if (siparisler[i].kullaniciId == kullanici.id) {
        setState(() {
          _siparisler.add(siparisler[i]);
        });
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

  // restorant isim tespiti
  //List<String> restorantlar = [];

  String restorantNameDetect(String id) {
    for (int i = 0; i < _restorantlar.length; i++) {
      if (_restorantlar[i].id == id) {
        print("uğradım");
        return _restorantlar[i].ad ?? '';
      }
    }

    return "";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    filterSiparis();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SiparislerOperations>(
      create: (_) => SiparislerOperations(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Siparişlerim',
          ),
          automaticallyImplyLeading: false,
        ),
        body: _siparisler.length > 0
            ? SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    height: _siparisler.length * 150,
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: _siparisler.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.14,
                            child: Card(
                              elevation: 15,
                              child: compareMinute(
                                          _siparisler[index].siparisSure,
                                          _siparisler[index].gun,
                                          _siparisler[index].saat) ==
                                      1
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.55,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.14,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text("Restorant : ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(restorantNameDetect(
                                                          _siparisler[index]
                                                              .restaurantId)),
                                                      SizedBox(
                                                        width: 30,
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("Toplam Tutar : ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(_siparisler[index]
                                                              .tutar +
                                                          " TL"),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("Sipariş Tarihi : ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(_siparisler[index]
                                                          .gun),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text("Sipariş Saati : ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(_siparisler[index]
                                                          .saat),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.49,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.18,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("Sipariş Durumu : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                      "Aktif",
                                                      style: TextStyle(
                                                          color: appTheme
                                                              .appColor),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : compareMinute(
                                              _siparisler[index].siparisSure,
                                              _siparisler[index].gun,
                                              _siparisler[index].saat) ==
                                          2
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.18,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text("Restorant : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(restorantNameDetect(
                                                              _siparisler[index]
                                                                  .restaurantId)),
                                                          SizedBox(
                                                            width: 30,
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Toplam Tutar : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              _siparisler[index]
                                                                      .tutar +
                                                                  " TL"),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Sipariş Tarihi : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              _siparisler[index]
                                                                  .gun),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              "Sipariş Saati : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              _siparisler[index]
                                                                  .saat),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.49,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.18,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                            "Sipariş Durumu : ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                          "Teslim Edildi",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .timer_outlined,
                                                                  color: appTheme
                                                                      .appColor,
                                                                ),
                                                                Text(
                                                                  'Değerlendirme Bekleniyor...',
                                                                  style:
                                                                      TextStyle(),
                                                                ),
                                                              ],
                                                            ))
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : compareMinute(
                                                  _siparisler[index]
                                                      .siparisSure,
                                                  _siparisler[index].gun,
                                                  _siparisler[index].saat) ==
                                              3
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.5,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.18,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Restorant : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Text(restorantNameDetect(
                                                                  _siparisler[
                                                                          index]
                                                                      .restaurantId)),
                                                              SizedBox(
                                                                width: 30,
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Toplam Tutar : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Text(_siparisler[
                                                                          index]
                                                                      .tutar +
                                                                  " TL"),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Sipariş Tarihi : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Text(_siparisler[
                                                                      index]
                                                                  .gun),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                  "Sipariş Saati : ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              Text(_siparisler[
                                                                      index]
                                                                  .saat),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.49,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.18,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                                "Sipariş Durumu : ",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                            Text(
                                                              "Teslim Edildi",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top: 3),
                                                                child: _siparisler[index]
                                                                            .puanlama ==
                                                                        "false"
                                                                    ? ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Get.to(Degerlendir(
                                                                              _siparisler[index].restaurantId,
                                                                              _siparisler[index]));
                                                                        },
                                                                        child: Text(
                                                                            'Değerlendir'))
                                                                    : Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check,
                                                                              color: Colors.green,
                                                                            ),
                                                                            Text(
                                                                              'Siparişi Değerlendirdiniz!',
                                                                              style: TextStyle(),
                                                                            ),
                                                                          ],
                                                                        )))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Text('Hata'),
                            ),
                          );
                        }),
                  )
                ]),
              )
            : Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.3,
                    left: MediaQuery.of(context).size.width * 0.12),
                child: Center(
                  child: Container(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Text(
                        'Sipariş Kaydınız Yok',
                        style: TextStyle(fontSize: 35, color: Colors.black38),
                      )),
                ),
              ),
      ),
    );
  }
}
