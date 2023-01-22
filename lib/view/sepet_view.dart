import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/model/sepet.dart';
import 'package:mobil_projesi/model/siparis.dart';
import 'package:mobil_projesi/view/degerlendir_view.dart';
import 'package:mobil_projesi/view/homepage_view.dart';
import 'package:mobil_projesi/view/login_page_view.dart';
import 'package:mobil_projesi/view/registration_page_view_model.dart';
import 'package:mobil_projesi/view/sepet_view_model.dart';
import 'package:provider/provider.dart';

import '../model/kullanici.dart';
import '../model/restorant.dart';

class Sepet extends StatefulWidget {
  Kullanici kullanici;
  List<SepetObject> urunler;
  //String? userid;
  Sepet(this.urunler, this.kullanici);

  @override
  State<Sepet> createState() => _SepetState(urunler, kullanici);
}

class _SepetState extends State<Sepet> {
  // bu sayfaya giderken id göndersin bizde ona göre sepetten seçelim ve sipariş verince
  // bu idye ait elemanları silelim
  Kullanici kullanici;
  List<SepetObject> urunler;
  //String? userid;
  _SepetState(this.urunler, this.kullanici);

  List<SepetObject> siparisDatas = [];
  List<SepetObject> listedDatas = [];
  listData(String? kid) {
    listedDatas = [];
    for (int i = 0; i < urunler.length; i++) {
      if (urunler[i].kullaniciId == kid) {
        setState(() {
          listedDatas.add(urunler[i]);
        });
      }
    }
  }

  int indexDetect(String kullanici_id, String restraurant_id, String ad) {
    for (int i = 0; i < listedDatas.length; i++) {
      if (kullanici_id == listedDatas[i].kullaniciId &&
          restraurant_id == listedDatas[i].restaurantId &&
          ad == listedDatas[i].urunAd) {
        return i;
      }
    }
    return 0;
  }

  /// restraurant data fetching
  List<Restaurant> _restorantlar = [];
  String _filter = '';

  fetchRestaurantData() async {
    var response =
        await FirebaseFirestore.instance.collection("restorant").get();
    mapRestaurant(response);
  }

  mapRestaurant(QuerySnapshot<Map<String, dynamic>> response) {
    var records = response.docs
        .map((item) => Restaurant(
            gorsel: item['gorsel'],
            ad: item['ad'],
            adres: item['adres'],
            id: item.id,
            hizPuan: item['hiz_puan'],
            lezzetPuan: item['lezzet_puan'],
            servisPuan: item['servis_puan']))
        .toList();
    setState(() {
      _restorantlar = records;
    });
  }

  /// restorant detect
  String detectRestorant(String urunid) {
    for (int i = 0; i < _restorantlar.length; i++) {
      if (_restorantlar[i].id == urunid) {
        return _restorantlar[i].ad ?? '';
      }
    }
    return "";
  }

  String calculateAmount() {
    int total = 0;
    for (int i = 0; i < listedDatas.length; i++) {
      total += int.parse(listedDatas[i].urunUcret);
    }
    return total.toString();
  }

  /// siparis data fetching
  List<Siparis> _siparisler = [];
  fetchSiparisData() async {
    var response = await FirebaseFirestore.instance
        .collection("siparisler")
        .where('kullanici_id',
            isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    mapSiparis(response);
  }

  mapSiparis(QuerySnapshot<Map<String, dynamic>> response) {
    var datas = response.docs
        .map((item) => Siparis(
            gun: item['gun'],
            id: item.id,
            kullaniciId: item["kullanici_id"],
            restaurantId: item['restaurant_id'],
            saat: item['saat'],
            tutar: item['tutar'],
            siparisSure: item['siparis_sure'],
            adres: item['adres'],
            puanlama: item['puanlama']))
        .toList();
    setState(() {
      _siparisler = datas;
    });
  }

  @override
  void initState() {
    super.initState();
    listData(FirebaseAuth.instance.currentUser?.uid);
    fetchRestaurantData();
    fetchSiparisData();
    FirebaseFirestore.instance
        .collection('siparisler')
        .snapshots()
        .listen((records) {
      mapSiparis(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SepetPageOperations>(
      create: (_) => SepetPageOperations(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Sepetim',
          ),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: listedDatas.length > 0
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ), //defaultsizedbox
                    Container(
                      //decoration: BoxDecoration(border: Border.all(width: 2)),
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: listedDatas.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                              title: Text(listedDatas[index].urunAd != null
                                  ? listedDatas[index].urunAd
                                  : ''),
                              subtitle: Text(
                                  listedDatas[index].urunUcret != null
                                      ? listedDatas[index].urunUcret + '  TL'
                                      : ''),
                              trailing: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                      color: Colors.white),
                                  width: 50,
                                  height: 50,
                                  child: InkWell(
                                    onTap: () async {
                                      await context
                                          .read<SepetPageOperations>()
                                          .deleteSepetData(
                                              listedDatas[index].id);
                                      setState(() {
                                        listedDatas.removeAt(indexDetect(
                                            listedDatas[index].kullaniciId,
                                            listedDatas[index].restaurantId,
                                            listedDatas[index].urunAd));
                                      });
                                      print("ürün silindi");
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(top: 13),
                                        child: Icon(
                                          Icons.maximize,
                                          color: appTheme.appColor,
                                        )),
                                  )),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ), // default core dan alınır
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Restorant',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ), // default sized core dan alınacak
                                    Text(detectRestorant(
                                        listedDatas[0].restaurantId)),
                                  ],
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Toplam Tutar',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(calculateAmount() + "  TL")
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Adres',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(kullanici.adres),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.09,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(30)),
                          child: ElevatedButton(
                            onPressed: () async {
                              print(siparisDatas.length);
                              print(listedDatas.length);

                              // burada sipariş gönderilecek
                              // siparişlerin aynı restauranttan olması durumu kontrol edilsin !!!
                              // siparişler sadece aynı restoranttan verilebilir
                              Get.to(LoginPage());
                              Get.to(HomePage());
                              //addSiparis();
                              await context
                                  .read<SepetPageOperations>()
                                  .addSiparis(
                                      listedDatas: listedDatas,
                                      calculateAmount: calculateAmount,
                                      kullanici: kullanici,
                                      fetchSiparisData: fetchSiparisData);

                              fetchSiparisData();

                              // siparis eklenince for döngüsüyle listedDatas içindeki elemanlar database'den silinmeliler
                              for (int i = 0; i < listedDatas.length; i++) {
                                //deleteSepetData(listedDatas[i].id);
                                await context
                                    .read<SepetPageOperations>()
                                    .deleteSepetData(listedDatas[i].id);
                              }
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side:
                                      BorderSide(width: 3, color: Colors.black),
                                ),
                              ),
                            ),
                            child: Text('Sipariş Ver'),
                          ),
                        ),
                      ],
                    ),
                    // Text('listedDatas : '+listedDatas.length.toString()),
                    // Text('urunler : '+urunler.length.toString()),
                    //Text('data: '+urunler[0].kullaniciId),
                    //Text(FirebaseAuth.instance.currentUser?.uid ?? ''),
                  ],
                ))
              : Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.3,
                      left: MediaQuery.of(context).size.width * 0.22),
                  child: Center(
                    child: Container(
                        //decoration: BoxDecoration(border: Border.all(width: 2)),
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Text(
                          'Sepetiniz Boş',
                          style: TextStyle(fontSize: 35, color: Colors.black38),
                        )),
                  ),
                ),
        ),
      ),
    );
  }
}
