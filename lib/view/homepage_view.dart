import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobil_projesi/model/restorant.dart';
import 'package:mobil_projesi/model/sepet.dart';
import 'package:mobil_projesi/model/yorum.dart';
import 'package:mobil_projesi/view/profile_view.dart';
import 'package:mobil_projesi/view/restaurant_view.dart';
import 'package:mobil_projesi/view/siparisler_view.dart';
import 'package:mobil_projesi/view/sepet_view.dart';
import '../core/colors/themeColor.dart';
import '../core/components/sized_box.dart';
import '../model/kullanici.dart';
import '../model/menu.dart';
import '../model/siparis.dart';
import '../service/auth.dart';

// tüm restaurant verileri çekilecek yazılan yemek eper

const TextStyle _textStyle = TextStyle(
  fontSize: 40,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  fontStyle: FontStyle.italic,
);

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState(); //mail);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final User? user = Auth().currentUser;

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Color _appColor = appTheme.appColor;

  int _currentIndex = 0;
  String info = '';

  Widget appbarTitle = Text('');
  Icon actionIcon = Icon(Icons.search);

  // appbar textfield controller
  var _tcontroller = TextEditingController();
  Icon _searchicon = Icon(Icons.search);
  // appbar logic
  bool _touched = true;

  // restraurant data fetching
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

  List<Menu> _menuler = [];

  List<Restaurant> empty = [];
  restaurantFilter() async {
    // menu verileri cekiliyor burada
    _menuler = [];
    empty = [];

    await FirebaseFirestore.instance
        .collection("restorant")
        .get()
        .then((value) {
      value.docs.forEach((result) {
        FirebaseFirestore.instance
            .collection("restorant")
            .doc(result.id)
            .collection("menu")
            .where('tur', isEqualTo: 'Yiyecek')
            //.where('ad',isEqualTo: input)
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
              _menuler.add(yeni);
            });
          });
        });
      });
    });
  }

  search(String input) {
    empty = [];
    for (int i = 0; i < _menuler.length; i++) {
      if (_menuler[i].ad == input) {
        for (int j = 0; j < _restorantlar.length; j++) {
          if (_menuler[i].restaurantId == _restorantlar[j].id) {
            print("POİNT2");
            empty.add(_restorantlar[j]);
          }
        }
      }
    }
  }

  // sepet verileri
  List<SepetObject> urunler = [];
  // user infoya göre sepetten veri çekilip gönderilmesi
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

  // data listele
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

// kullanici
  Kullanici istenen = Kullanici(adres: "adres", email: "", id: "id", sifre: "");
  List<Kullanici> kullanici = [];
  userDataFetch() async {
    var response =
        await FirebaseFirestore.instance.collection("kullanici").get();
    mapUser(response);
  }

  mapUser(QuerySnapshot<Map<String, dynamic>> response) {
    var records = response.docs
        .map((item) => Kullanici(
            adres: item['adres'],
            email: item['email'],
            id: item['id'],
            sifre: item['sifre']))
        .toList();
    setState(() {
      kullanici = records;
    });
  }

  chooseKullanici() {
    for (int i = 0; i < kullanici.length; i++) {
      if (kullanici[i].id == FirebaseAuth.instance.currentUser?.uid) {
        setState(() {
          istenen = kullanici[i];
        });
      }
    }
  }

  // siparis data fetch
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

  //fetchYorumData
  List<Yorum> _yorumlar = [];
  fetchYorumData() async {
    var record = await FirebaseFirestore.instance.collection("yorumlar").get();
    mapYorum(record);
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

  double calculateAvarageStar(String restaurant_id) {
    List<Yorum> _holder = [];
    for (int i = 0; i < _yorumlar.length; i++) {
      if (_yorumlar[i].restaurantId == restaurant_id) {
        _holder.add(_yorumlar[i]);
      }
    }
    double total = 0;
    for (int i = 0; i < _holder.length; i++) {
      total = total +
          double.parse(_holder[i].hizPuan) +
          double.parse(_holder[i].lezzetPuan) +
          double.parse(_holder[i].servisPuan);
    }

    total = total / (_holder.length * 3);

    return total;
  }

  @override
  void initState() {
    super.initState();
    fetchRestaurantData();
    userDataFetch();
    fetchSepettData();
    chooseKullanici();
    fetchSiparisData();
    fetchYorumData();
    restaurantFilter();

    print("istenen id :" + istenen.id);
    print("sepet bu kadar" + urunler.length.toString());
    //info = mail;

    /// kullanıcı verilerini bu şekilde çekip collection verileriyle eşleyebiliriz daha sonrasında
    final user = FirebaseAuth.instance.currentUser;
    print(user?.email);
    print(user?.uid);
  }

  @override
  Widget build(BuildContext context) {
    print(_currentIndex);
    return Scaffold(
      // floatingactionbutton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: _appColor,
              focusColor: _appColor,
              onPressed: () {
                setState(() {
                  _touched = !_touched;
                });
              },
              child: _touched ? Icon(Icons.search) : Icon(Icons.close),
            )
          : null,

      appBar: _currentIndex != 0
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              backgroundColor: _touched ? _appColor : Colors.white,
              title: _touched
                  ? Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Text(
                        'Ne Yesem?',
                        style: TextStyle(fontSize: 20),
                      ))
                  : Container(
                      margin: EdgeInsets.only(left: 30),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Ne Yesem...',
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 20),
                        controller: _tcontroller,
                        onChanged: (value) {
                          if (value.length > 4) {
                            setState(() {
                              search(value);
                            });
                          }
                        },
                      )),
              actions: _touched
                  ? [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _touched = !_touched;
                            });
                          },
                          icon: Icon(Icons.search))
                    ]
                  : [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _touched = !_touched;
                            });
                          },
                          icon: Icon(
                            Icons.close,
                            color: Colors.black,
                          ))
                    ],
            ),

      /// body
      body: _currentIndex != 0
          ? Center(
              child: _currentIndex == 1
                  ? Siparisler(istenen, _siparisler, _restorantlar)
                  : _currentIndex == 2
                      ? Sepet(urunler, istenen)
                      : Profil(istenen))
          : //buraya da logic verebiliriz eğer search'e basıldıysa listview ile arama ve kayıtlar getirilsin yoksa normal sayfa olsun
          SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: _touched
                  ? Center(
                      child: Column(
                        children: [
                          DefaultSized(),
                          Container(
                            //decoration: BoxDecoration(border: Border.all(width: 2)),
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView(
                              padding: EdgeInsets.only(),
                              physics: BouncingScrollPhysics(),
                              children: [
                                //Center(child: Text('Kampanyalar')),
                                //Divider(thickness: 2,color: Colors.black38,endIndent: MediaQuery.of(context).size.width*0.4,indent: MediaQuery.of(context).size.width*0.4),
                                CarouselSlider(
                                  items: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.8, top: 0.8, right: 0.8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: AssetImage('assets/k1.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.8, top: 0.8, right: 0.8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/cs1.jpg') /*Image.asset(
                                              'assets/cs1.jpeg')*/
                                          ,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.8, top: 0.8, right: 0.8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: AssetImage('assets/cs2.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.8, top: 0.8, right: 0.8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: AssetImage('assets/cs3.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 0.8, top: 0.8, right: 0.8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        image: DecorationImage(
                                          image: AssetImage('assets/cs00.jpeg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ],
                                  options: CarouselOptions(
                                    height: MediaQuery.of(context).size.height *
                                        0.26,
                                    enlargeCenterPage: true,
                                    autoPlay: true,
                                    aspectRatio: 16 / 9,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enableInfiniteScroll: true,
                                    autoPlayAnimationDuration:
                                        Duration(milliseconds: 800),
                                    viewportFraction: 0.9,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text('Yemekler'),
                          Divider(
                              thickness: 2,
                              color: Colors.black38,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.43,
                              indent: MediaQuery.of(context).size.width * 0.43),
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.15,
                              child: ListView(
                                physics: BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Container(
                                    width: 85,
                                    child: Column(
                                      children: [
                                        Card(
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _touched = !_touched;
                                                  _tcontroller.text =
                                                      'Hamburger';
                                                  search(_tcontroller.text);
                                                  print(_touched);
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/hamburger.png',
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        Text('Hamburger')
                                      ],
                                    ),
                                  ),
                                  Container(
                                      width: 85,
                                      child: Column(
                                        children: [
                                          Column(
                                            children: [
                                              Card(
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _touched = !_touched;
                                                        _tcontroller.text =
                                                            'Çiğköfte';
                                                        search(
                                                            _tcontroller.text);
                                                        print(_touched);
                                                      });
                                                    },
                                                    child: Image.asset(
                                                      'assets/cigkofte.png',
                                                      fit: BoxFit.cover,
                                                    )),
                                              ),
                                              Text('Çigköfte')
                                            ],
                                          ),
                                        ],
                                      )),
                                  Container(
                                    width: 85,
                                    child: Column(
                                      children: [
                                        Card(
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _touched = !_touched;
                                                  _tcontroller.text = 'Pilav';
                                                  search(_tcontroller.text);
                                                  print(_touched);
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/pilav.png',
                                                fit: BoxFit.cover,
                                              )), // değişecek
                                        ),
                                        Text('Pilav')
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 85,
                                    child: Column(
                                      children: [
                                        Card(
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _touched = !_touched;
                                                    _tcontroller.text = 'Kebap';
                                                    search(_tcontroller.text);
                                                    print(_touched);
                                                  });
                                                },
                                                child: Image.asset(
                                                  'assets/kebap.png',
                                                  fit: BoxFit.cover,
                                                ))),
                                        Text('Kebap')
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 85,
                                    child: Column(
                                      children: [
                                        Card(
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _touched = !_touched;
                                                  _tcontroller.text = 'Suşi';
                                                  search(_tcontroller.text);
                                                  print(_touched);
                                                });
                                              },
                                              child: Image.asset(
                                                'assets/susi.png',
                                                fit: BoxFit.cover,
                                              )),
                                        ),
                                        Text('Suşi')
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          DefaultSized(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: Text('Restaurantlar')),
                            ],
                          ),
                          Divider(
                              thickness: 2,
                              color: Colors.black38,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.4,
                              indent: MediaQuery.of(context).size.width * 0.4),
                          //ListView.builder(itemBuilder: ) bu olsa daha iyi ama deneme amaçlı yapılıyor....
                          Container(
                            width: double.infinity,
                            height: _restorantlar.length *
                                70, // itemcount*10 DİYE AYARLA!!!
                            child: _restorantlar.length > 0
                                ? ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: _restorantlar.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            title: Text(
                                                _restorantlar[index].ad ?? ''),
                                            subtitle: Text(
                                                _restorantlar[index].adres ??
                                                    ''),
                                            onTap: () {
                                              listData(FirebaseAuth.instance
                                                      .currentUser?.uid ??
                                                  '');
                                              print("ListedDataslar  : " +
                                                  listedDatas.length
                                                      .toString());
                                              Get.to(Restorant(
                                                  _restorantlar[index],
                                                  listedDatas.length));
                                              //print(_restorantlar[index].gorsel);
                                              //print("ÇOKLUK : "+_restorantlar.length.toString());
                                            },
                                            leading: Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.2,
                                                  child: Image.asset(
                                                      '${_restorantlar[index].gorsel}')),
                                            ),
                                            trailing: RatingBar(
                                              ignoreGestures: true,
                                              minRating: 1,
                                              itemSize: 15,
                                              glowColor: Colors.grey,
                                              maxRating: 5,
                                              initialRating:
                                                  calculateAvarageStar(
                                                      _restorantlar[index].id ??
                                                          ''),
                                              allowHalfRating: true,
                                              onRatingUpdate: (poi) {},
                                              ratingWidget: RatingWidget(
                                                full: Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                half: Icon(
                                                  Icons.star_half,
                                                  color: Colors.amber,
                                                ),
                                                empty: Icon(
                                                  Icons.star,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          //DefaultSized()
                                        ],
                                      );
                                    },
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          )
                        ],
                      ),
                    )
                  : // arama yapılan sayfa yazılan data anlık çekilecek ona uygun datalar çekilecek
                  Center(
                      child: Column(
                        children: [
                          DefaultSized(),
                          DefaultSized(),
                          Container(
                            width: double.infinity,
                            height: empty.length * 90,
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: empty.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(empty[index].ad ?? ''),
                                      subtitle: Text(empty[index].adres ?? ''),
                                      onTap: () {
                                        listData(FirebaseAuth
                                                .instance.currentUser?.uid ??
                                            '');

                                        Get.to(Restorant(
                                            empty[index], listedDatas.length));
                                        //print(_restorantlar[index].gorsel);
                                        //print("ÇOKLUK : "+_restorantlar.length.toString());
                                      },
                                      leading: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.2,
                                          child: Image.asset(
                                              '${empty[index].gorsel}')),
                                      trailing: RatingBar(
                                        ignoreGestures: true,
                                        minRating: 1,
                                        itemSize: 15,
                                        glowColor: Colors.grey,
                                        maxRating: 5,
                                        initialRating: calculateAvarageStar(
                                            empty[index].id ?? ''),
                                        allowHalfRating: true,
                                        onRatingUpdate: (poi) {},
                                        ratingWidget: RatingWidget(
                                          full: Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          half: Icon(
                                            Icons.star_half,
                                            color: Colors.amber,
                                          ),
                                          empty: Icon(
                                            Icons.star,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DefaultSized()
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    )),

      /// bottomNavigationBar
      bottomNavigationBar: Container(
        height: 70,
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int newIndex) {
            setState(() {
              fetchRestaurantData();
              userDataFetch();

              fetchSepettData();
              chooseKullanici();
              fetchSiparisData();
              fetchYorumData();

              Duration(seconds: 1);
              _currentIndex = newIndex;
            });
          },
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Anasayfa',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.food_bank),
              icon: Icon(Icons.food_bank_outlined),
              label: 'Siparişlerim',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.shopping_cart),
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Sepetim',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outlined),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
