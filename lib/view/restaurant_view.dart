import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/model/sepet.dart';
import 'package:mobil_projesi/view/homepage_view.dart';
import 'package:mobil_projesi/view/login_page_view.dart';
import 'package:mobil_projesi/view/restaurant_view_model.dart';
import 'package:mobil_projesi/view/sepet_view.dart';
import 'package:mobil_projesi/view/siparisler_view_model.dart';
import 'package:provider/provider.dart';
import '../model/kullanici.dart';
import '../model/menu.dart';
import '../model/restorant.dart';
import '../model/yorum.dart';

int _holderSepet = 0;
// sayfa her açıldığında restoran puanı set edilsin!!
// buraya restoran verisi gönderilcek sonra eşleşen veriler çekilecek
// buraya sadece homepage den geliş olacak
List<SepetObject> urunler = [];
Kullanici catchKullanici =
    Kullanici(adres: "adres", email: "email", id: "id", sifre: "sifre");

class Restorant extends StatefulWidget {
  Restaurant object;
  int uzunluk;
  Restorant(
    this.object,
    this.uzunluk,
  );

  @override
  State<Restorant> createState() => _RestorantState(object, uzunluk);
}

class _RestorantState extends State<Restorant> with TickerProviderStateMixin {
  Restaurant object;
  int uzunluk;
  _RestorantState(this.object, this.uzunluk);

  /// Tab Controller
  late final TabController _tabController =
      TabController(length: 4, vsync: this);

  /// verilerin tutulacağı listeler
  List<Menu> myMenu = [];

  List<Menu> icecekler = [];

  List<Menu> yiyecekler = [];

  int yorumHolder = 0;

  /// iç içe koleksiyondan veri çeken kod
  nestedDataFetch() async {
    yiyecekler = [];
    icecekler = [];
    await FirebaseFirestore.instance
        .collection("restorant")
        .where('id', isEqualTo: object.id)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection("restorant")
            .doc(result.id)
            .collection("menu")
            .where('tur', isEqualTo: 'Yiyecek')
            .get()
            .then((subcol) {
          subcol.docs.forEach((element) {
            setState(() {
              var yeni = Menu(
                  ad: element.data()['ad'],
                  id: element.data()['id'],
                  restaurantId: result.id,
                  tur: element.data()['tur'],
                  ucret: element.data()['ucret']);
              yiyecekler.add(yeni);
            });
          });
        });
      });
    });
    await FirebaseFirestore.instance
        .collection("restorant")
        .where('id', isEqualTo: object.id)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection("restorant")
            .doc(result.id)
            .collection("menu")
            .where('tur', isEqualTo: 'Icecek')
            .get()
            .then((subcol) {
          subcol.docs.forEach((element) {
            setState(() {
              var yeni = Menu(
                  ad: element.data()['ad'],
                  id: element.data()['id'],
                  restaurantId: result.id,
                  tur: element.data()['tur'],
                  ucret: element.data()['ucret']);
              icecekler.add(yeni);
            });
          });
        });
      });
    });
  }

  //fetchYorumData
  List<Yorum> _yorumlar = [];
  fetchYorumData() async {
    var record = await FirebaseFirestore.instance
        .collection("yorumlar")
        .where('restaurant_id', isEqualTo: object.id)
        .get();
    mapYorum(record);

    setState(() {
      yorumHolder = _yorumlar.length;
    });
  }

  mapYorum(QuerySnapshot<Map<String, dynamic>> record) {
    var datas = record.docs
        .map(
          (item) => Yorum(
              hizPuan: item['hiz_puan'],
              id: item['id'],
              kullaniciId: item['kullanici_id'],
              lezzetPuan: item['lezzet_puan'],
              restaurantId: item['restaurant_id'],
              servisPuan: item['servis_puan'],
              yorum: item['yorum']),
        )
        .toList();

    setState(() {
      _yorumlar = datas;
    });
  }

  /// sepet data fetch etme
  fetchSepettData() async {
    var response = await FirebaseFirestore.instance.collection("sepet").get();
    mapSepet(response);
  }

  mapSepet(QuerySnapshot<Map<String, dynamic>> response) {
    var records = response.docs
        .map((item) => SepetObject(
            id: item.id,
            kullaniciId: item["kullanici_id"],
            restaurantId: item['restaurant_id'],
            urunAd: item['urun_ad'],
            urunUcret: item['urun_ucret']))
        .toList();
    setState(() {
      urunler = records;
    });
  }

  /// data listele
  List<SepetObject> listedDatas = [];
  listData(String kid) {
    listedDatas = [];
    for (int i = 0; i < urunler.length; i++) {
      if (urunler[i].kullaniciId == kid) {
        setState(() {
          listedDatas.add(urunler[i]);
        });
      }
    }
  }

  /// lezzet puan hesapla
  double calculateLezzetStar(String restaurant_id) {
    List<Yorum> _holder = [];
    for (int i = 0; i < _yorumlar.length; i++) {
      if (_yorumlar[i].restaurantId == restaurant_id) {
        _holder.add(_yorumlar[i]);
      }
    }
    double total = 0;
    for (int i = 0; i < _holder.length; i++) {
      total = total + double.parse(_holder[i].lezzetPuan);
    }
    total = total / _holder.length;
    return total;
  }

  /// hız puan hesapla
  double calculateHizStar(String restaurant_id) {
    List<Yorum> _holder = [];
    for (int i = 0; i < _yorumlar.length; i++) {
      if (_yorumlar[i].restaurantId == restaurant_id) {
        _holder.add(_yorumlar[i]);
      }
    }
    double total = 0;
    for (int i = 0; i < _holder.length; i++) {
      total = total + double.parse(_holder[i].hizPuan);
    }
    total = total / _holder.length;
    return total;
  }

  /// Servis puan hesapla
  double calculateServisStar(String restaurant_id) {
    List<Yorum> _holder = [];
    for (int i = 0; i < _yorumlar.length; i++) {
      if (_yorumlar[i].restaurantId == restaurant_id) {
        _holder.add(_yorumlar[i]);
      }
    }

    double total = 0;
    for (int i = 0; i < _holder.length; i++) {
      total = total + double.parse(_holder[i].servisPuan);
    }
    total = total / _holder.length;
    return total;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nestedDataFetch();
    fetchSepettData();
    fetchYorumData();
    _holderSepet = uzunluk;
    listData(FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantPageOperations>(
      create: (_) => RestaurantPageOperations(),
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(object.ad ?? ''),
          leading: IconButton(
              onPressed: () {
                Get.to(HomePage());
              },
              icon: Icon(Icons.arrow_back)),
          actions: [
            // sepet eklenecek stack ile içinde sipariş sayısı gözükecek
            myAppBarIcon()
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ), // defdault sized olarak çekeriz core ' a koyup
              Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.97,
                    height: MediaQuery.of(context).size.height * 0.27,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        // side: BorderSide()
                      ),
                      color: Colors.white,
                      elevation: 20,
                      child: Column(
                        children: [
                          SizedBox(height: 10), // default verilecek
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100))),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.2,
                                        child: CircleAvatar(
                                          child:
                                              Image.asset(object.gorsel ?? ''),
                                        )),
                                  ],
                                ),
                              ),
                              Column(
                                //mainAxisAlignment: MainAxisAlignment.,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    calculateHizStar(object.id ?? '').isNaN
                                        ? 'Hız : 5'
                                        : 'Hız : ' +
                                            calculateHizStar(object.id ?? '')
                                                .toStringAsFixed(1),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  // puan gelicek
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RatingBar(
                                    ignoreGestures: true,
                                    minRating: 1,
                                    itemSize: 25,
                                    glowColor: Colors.grey,
                                    maxRating: 5,
                                    initialRating:
                                        calculateHizStar(object.id ?? ''),
                                    allowHalfRating: true,
                                    onRatingUpdate: (update) {
                                      setState(() {
                                        //rate = update;
                                        // print(rate.toString());
                                      });
                                    },
                                    ratingWidget: RatingWidget(
                                        full: const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        half: Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 5,
                                        ),
                                        empty: Icon(
                                          Icons.star,
                                          color: Colors.grey,
                                          size: 5,
                                        )),
                                  ),
                                  Text(
                                    calculateLezzetStar(object.id ?? '').isNaN
                                        ? 'Lezzet : 5'
                                        : 'Lezzet : ' +
                                            calculateLezzetStar(object.id ?? '')
                                                .toStringAsFixed(1),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                  // puan gelicek
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RatingBar(
                                    ignoreGestures: true,
                                    minRating: 1,
                                    itemSize: 25,
                                    glowColor: Colors.grey,
                                    maxRating: 5,
                                    initialRating:
                                        calculateLezzetStar(object.id ?? ''),
                                    allowHalfRating: true,
                                    onRatingUpdate: (update) {
                                      setState(() {
                                        //rate = update;
                                        // print(rate.toString());
                                      });
                                    },
                                    ratingWidget: RatingWidget(
                                        full: const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        half: Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 5,
                                        ),
                                        empty: Icon(
                                          Icons.star,
                                          color: Colors.grey,
                                          size: 5,
                                        )),
                                  ),
                                  Text(
                                    calculateServisStar(object.id ?? '').isNaN
                                        ? 'Servis : 5'
                                        : 'Servis : ' +
                                            calculateServisStar(object.id ?? '')
                                                .toStringAsFixed(1),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                  // puan gelicek
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RatingBar(
                                    ignoreGestures: true,
                                    minRating: 1,
                                    itemSize: 25,
                                    glowColor: Colors.grey,
                                    maxRating: 5,
                                    initialRating:
                                        calculateServisStar(object.id ?? ''),
                                    allowHalfRating: true,
                                    onRatingUpdate: (update) {
                                      setState(() {
                                        //rate = update;
                                        // print(rate.toString());
                                      });
                                    },
                                    ratingWidget: RatingWidget(
                                        full: const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        half: Icon(
                                          Icons.star_half,
                                          color: Colors.amber,
                                          size: 5,
                                        ),
                                        empty: Icon(
                                          Icons.star,
                                          color: Colors.grey,
                                          size: 5,
                                        )),
                                  ),
                                  //Text('Adres : '),
                                  //Text(object.adres,style: TextStyle(fontWeight: FontWeight.bold),)
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black38,
                    tabs: [
                      Tab(
                        text: "Tüm Ürünler",
                      ),
                      Tab(
                        text: "Yiyecekler",
                      ),
                      Tab(
                        text: "İçecekler",
                      ),
                      Tab(
                        text: "Yorumlar",
                      )
                    ]),
              ),
              Container(
                width: double.maxFinite,
                height: 350,
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              yiyecekler.length > 0 ? 'Yiyecekler' : '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: yiyecekler.length * 90,
                          child: yiyecekler.length > 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: yiyecekler.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide())),
                                      child: ListTile(
                                        title: Text(yiyecekler[index].ad != null
                                            ? yiyecekler[index].ad
                                            : ''),
                                        subtitle: Text(
                                            yiyecekler[index].ucret != null
                                                ? yiyecekler[index].ucret +
                                                    '  TL'
                                                : ''),
                                        trailing: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            width: 50,
                                            height: 50,
                                            child: InkWell(
                                              onTap: () async {
                                                if (_holderSepet == 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration: Duration(
                                                              seconds: 1),
                                                          backgroundColor:
                                                              Colors.white,
                                                          content: Row(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child: Lottie
                                                                    .network(
                                                                        "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                              ),
                                                              Text(
                                                                'Ürün sepete eklendi',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ],
                                                          )));

                                                  setState(() {
                                                    _holderSepet += 1;
                                                  });
                                                  // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                  await context
                                                      .read<
                                                          RestaurantPageOperations>()
                                                      .addSepet(
                                                          FirebaseAuth.instance
                                                              .currentUser?.uid,
                                                          yiyecekler[index]
                                                              .restaurantId,
                                                          yiyecekler[index].ad,
                                                          yiyecekler[index]
                                                              .ucret);

                                                  fetchSepettData();
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                } else {
                                                  // eğer zaten orada varsa !!
                                                  // sepetten data çekip bakalım
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                  // print("urunşko : "+urunler.length.toString());
                                                  // print("dataşko : "+listedDatas.length.toString());

                                                  if (object.id ==
                                                      listedDatas[0]
                                                          .restaurantId) {
                                                    print("HAHAHAH:" +
                                                        listedDatas[0]
                                                            .restaurantId);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                                ),
                                                                Text(
                                                                  'Ürün sepete eklendi',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ],
                                                            )));

                                                    setState(() {
                                                      _holderSepet += 1;
                                                    });
                                                    // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                    await context
                                                        .read<
                                                            RestaurantPageOperations>()
                                                        .addSepet(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                            yiyecekler[index]
                                                                .restaurantId,
                                                            yiyecekler[index]
                                                                .ad,
                                                            yiyecekler[index]
                                                                .ucret);

                                                    fetchSepettData();
                                                    listData(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid ??
                                                        '');
                                                  } else {
                                                    // buradaki gibi eşleşmiyorsa
                                                    // eklemicek
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets6.lottiefiles.com/temp/lf20_QYm9j9.json"),
                                                                ),
                                                                /* IconButton(
                                                                  onPressed:
                                                                      null,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .white,
                                                                  )),*/
                                                                Text(
                                                                  'Sepetinizdeki restorantlar aynı olmalıdır',
                                                                  style: TextStyle(
                                                                      color: appTheme
                                                                          .appColor),
                                                                ),
                                                              ],
                                                            )));
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: appTheme.appColor,
                                              ),
                                            )),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                        // içecekler
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              icecekler.length > 0 ? 'İçecekler' : '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: icecekler.length * 90,
                          child: icecekler.length > 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: icecekler.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide())),
                                      child: ListTile(
                                        title: Text(icecekler[index].ad != null
                                            ? icecekler[index].ad
                                            : ''),
                                        subtitle: Text(icecekler[index].ucret !=
                                                null
                                            ? icecekler[index].ucret + '  TL'
                                            : ''),
                                        trailing: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            width: 50,
                                            height: 50,
                                            child: InkWell(
                                              onTap: () async {
                                                if (_holderSepet == 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration: Duration(
                                                              seconds: 1),
                                                          backgroundColor:
                                                              Colors.white,
                                                          content: Row(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child: Lottie
                                                                    .network(
                                                                        "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                              ),
                                                              Text(
                                                                'Ürün sepete eklendi',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ],
                                                          )));

                                                  setState(() {
                                                    _holderSepet += 1;
                                                  });
                                                  // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                  await context
                                                      .read<
                                                          RestaurantPageOperations>()
                                                      .addSepet(
                                                          FirebaseAuth.instance
                                                              .currentUser?.uid,
                                                          icecekler[index]
                                                              .restaurantId,
                                                          icecekler[index].ad,
                                                          icecekler[index]
                                                              .ucret);

                                                  fetchSepettData();
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                } else {
                                                  // eğer zaten orada varsa !!
                                                  // sepetten data çekip bakalım
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                  // print("urunşko : "+urunler.length.toString());
                                                  // print("dataşko : "+listedDatas.length.toString());

                                                  if (object.id ==
                                                      listedDatas[0]
                                                          .restaurantId) {
                                                    print("HAHAHAH:" +
                                                        listedDatas[0]
                                                            .restaurantId);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                                ),
                                                                Text(
                                                                  'Ürün sepete eklendi',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ],
                                                            )));

                                                    setState(() {
                                                      _holderSepet += 1;
                                                    });
                                                    // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                    await context
                                                        .read<
                                                            RestaurantPageOperations>()
                                                        .addSepet(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                            icecekler[index]
                                                                .restaurantId,
                                                            icecekler[index].ad,
                                                            icecekler[index]
                                                                .ucret);

                                                    fetchSepettData();
                                                    listData(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid ??
                                                        '');
                                                  } else {
                                                    // buradaki gibi eşleşmiyorsa
                                                    // eklemicek
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets6.lottiefiles.com/temp/lf20_QYm9j9.json"),
                                                                ),
                                                                /* IconButton(
                                                                  onPressed:
                                                                      null,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .white,
                                                                  )),*/
                                                                Text(
                                                                  'Sepetinizdeki restorantlar aynı olmalıdır',
                                                                  style: TextStyle(
                                                                      color: appTheme
                                                                          .appColor),
                                                                ),
                                                              ],
                                                            )));
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: appTheme.appColor,
                                              ),
                                            )),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        )
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              yiyecekler.length > 0 ? 'Yiyecekler' : '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: yiyecekler.length * 90,
                          child: yiyecekler.length > 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: yiyecekler.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide())),
                                      child: ListTile(
                                        title: Text(yiyecekler[index].ad != null
                                            ? yiyecekler[index].ad
                                            : ''),
                                        subtitle: Text(
                                            yiyecekler[index].ucret != null
                                                ? yiyecekler[index].ucret +
                                                    '  TL'
                                                : ''),
                                        trailing: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            width: 50,
                                            height: 50,
                                            child: InkWell(
                                              onTap: () async {
                                                if (_holderSepet == 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration: Duration(
                                                              seconds: 1),
                                                          backgroundColor:
                                                              Colors.white,
                                                          content: Row(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child: Lottie
                                                                    .network(
                                                                        "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                              ),
                                                              Text(
                                                                'Ürün sepete eklendi',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ],
                                                          )));

                                                  setState(() {
                                                    _holderSepet += 1;
                                                  });
                                                  // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                  await context
                                                      .read<
                                                          RestaurantPageOperations>()
                                                      .addSepet(
                                                          FirebaseAuth.instance
                                                              .currentUser?.uid,
                                                          yiyecekler[index]
                                                              .restaurantId,
                                                          yiyecekler[index].ad,
                                                          yiyecekler[index]
                                                              .ucret);
                                                  fetchSepettData();
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                } else {
                                                  // eğer zaten orada varsa !!
                                                  // sepetten data çekip bakalım
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                  // print("urunşko : "+urunler.length.toString());
                                                  // print("dataşko : "+listedDatas.length.toString());

                                                  if (object.id ==
                                                      listedDatas[0]
                                                          .restaurantId) {
                                                    print("HAHAHAH:" +
                                                        listedDatas[0]
                                                            .restaurantId);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                                ),
                                                                Text(
                                                                  'Ürün sepete eklendi',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ],
                                                            )));

                                                    setState(() {
                                                      _holderSepet += 1;
                                                    });
                                                    // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                    await context
                                                        .read<
                                                            RestaurantPageOperations>()
                                                        .addSepet(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                            yiyecekler[index]
                                                                .restaurantId,
                                                            yiyecekler[index]
                                                                .ad,
                                                            yiyecekler[index]
                                                                .ucret);
                                                    fetchSepettData();
                                                    listData(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid ??
                                                        '');
                                                  } else {
                                                    // buradaki gibi eşleşmiyorsa
                                                    // eklemicek
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets6.lottiefiles.com/temp/lf20_QYm9j9.json"),
                                                                ),
                                                                /* IconButton(
                                                                  onPressed:
                                                                      null,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .white,
                                                                  )),*/
                                                                Text(
                                                                  'Sepetinizdeki restorantlar aynı olmalıdır',
                                                                  style: TextStyle(
                                                                      color: appTheme
                                                                          .appColor),
                                                                ),
                                                              ],
                                                            )));
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: appTheme.appColor,
                                              ),
                                            )),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              icecekler.length > 0 ? 'İçecekler' : '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: icecekler.length * 90,
                          child: icecekler.length > 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: icecekler.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide())),
                                      child: ListTile(
                                        title: Text(icecekler[index].ad != null
                                            ? icecekler[index].ad
                                            : ''),
                                        subtitle: Text(icecekler[index].ucret !=
                                                null
                                            ? icecekler[index].ucret + '  TL'
                                            : ''),
                                        trailing: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10),
                                                ),
                                                color: Colors.white),
                                            width: 50,
                                            height: 50,
                                            child: InkWell(
                                              onTap: () async {
                                                if (_holderSepet == 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          duration: Duration(
                                                              seconds: 1),
                                                          backgroundColor:
                                                              Colors.white,
                                                          content: Row(
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child: Lottie
                                                                    .network(
                                                                        "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                              ),
                                                              Text(
                                                                'Ürün sepete eklendi',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ],
                                                          )));

                                                  setState(() {
                                                    _holderSepet += 1;
                                                  });
                                                  // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                  await context
                                                      .read<
                                                          RestaurantPageOperations>()
                                                      .addSepet(
                                                          FirebaseAuth.instance
                                                              .currentUser?.uid,
                                                          icecekler[index]
                                                              .restaurantId,
                                                          icecekler[index].ad,
                                                          icecekler[index]
                                                              .ucret);

                                                  fetchSepettData();
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                } else {
                                                  // eğer zaten orada varsa !!
                                                  // sepetten data çekip bakalım
                                                  listData(FirebaseAuth.instance
                                                          .currentUser?.uid ??
                                                      '');
                                                  // print("urunşko : "+urunler.length.toString());
                                                  // print("dataşko : "+listedDatas.length.toString());

                                                  if (object.id ==
                                                      listedDatas[0]
                                                          .restaurantId) {
                                                    print("HAHAHAH:" +
                                                        listedDatas[0]
                                                            .restaurantId);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 50,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                                                                ),
                                                                Text(
                                                                  'Ürün sepete eklendi',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .green),
                                                                ),
                                                              ],
                                                            )));

                                                    setState(() {
                                                      _holderSepet += 1;
                                                    });
                                                    // burada sepete veri eklenecek restorant id kontrolü de yapılacak
                                                    await context
                                                        .read<
                                                            RestaurantPageOperations>()
                                                        .addSepet(
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                            icecekler[index]
                                                                .restaurantId,
                                                            icecekler[index].ad,
                                                            icecekler[index]
                                                                .ucret);

                                                    fetchSepettData();
                                                    listData(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid ??
                                                        '');
                                                  } else {
                                                    // buradaki gibi eşleşmiyorsa
                                                    // eklemicek
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            duration: Duration(
                                                                seconds: 1),
                                                            backgroundColor:
                                                                Colors.white,
                                                            content: Row(
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 50,
                                                                  child: Lottie
                                                                      .network(
                                                                          "https://assets6.lottiefiles.com/temp/lf20_QYm9j9.json"),
                                                                ),
                                                                /* IconButton(
                                                                  onPressed:
                                                                      null,
                                                                  icon: Icon(
                                                                    Icons
                                                                        .warning,
                                                                    color: Colors
                                                                        .white,
                                                                  )),*/
                                                                Text(
                                                                  'Sepetinizdeki restorantlar aynı olmalıdır',
                                                                  style: TextStyle(
                                                                      color: appTheme
                                                                          .appColor),
                                                                ),
                                                              ],
                                                            )));
                                                  }
                                                }
                                              },
                                              child: Icon(
                                                Icons.add,
                                                color: appTheme.appColor,
                                              ),
                                            )),
                                      ),
                                    );
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              _yorumlar.length > 0 ? 'Yorumlar' : '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: double.maxFinite,
                          height: _yorumlar.length * 100,
                          child: _yorumlar.length > 0
                              ? ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: _yorumlar.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        height: 95,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(),
                                                top: BorderSide())),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1, child: SizedBox()),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text('Hiz : ' +
                                                        _yorumlar[index]
                                                            .hizPuan)),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text('Lezzet : ' +
                                                        _yorumlar[index]
                                                            .lezzetPuan)),
                                                Expanded(
                                                    flex: 3,
                                                    child: Text('Servis : ' +
                                                        _yorumlar[index]
                                                            .servisPuan))
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                                width: double.infinity,
                                                height: 50,
                                                child: Text("  " +
                                                    _yorumlar[index].yorum))
                                          ],
                                        ));
                                  },
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget myAppBarIcon() {
  return Container(
    width: 30,
    height: 30,
    margin: EdgeInsets.only(right: 30, top: 7),
    child: Stack(
      children: [
        InkWell(
            child: Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 40),
            onTap: null),
        Container(
          width: 20,
          height: 20,
          //alignment: Alignment.topRight,
          //margin: EdgeInsets.only(top: 5),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Center(
                child: Text(
                  _holderSepet.toString(),
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
