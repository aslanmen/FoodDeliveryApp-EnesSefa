import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/model/siparis.dart';
import 'package:mobil_projesi/model/yorum.dart';
import 'package:mobil_projesi/view/degerlendir_view_model.dart';
import 'package:mobil_projesi/view/homepage_view.dart';
import 'package:mobil_projesi/view/profile_view_model.dart';
import 'package:provider/provider.dart';

import '../model/restorant.dart';

class Degerlendir extends StatefulWidget {
  String name;
  Siparis siparis;
  Degerlendir(this.name, this.siparis);

  @override
  State<Degerlendir> createState() => _DegerlendirState(name, siparis);
}

class _DegerlendirState extends State<Degerlendir> {
  String name;
  Siparis siparis;
  _DegerlendirState(this.name, this.siparis);
  TextEditingController _yorumController = TextEditingController();
  double hizrating = 3;
  double lezzetrating = 3;
  double servisrating = 3;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _yorumController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DegerlendirOperations>(
      create: (_) => DegerlendirOperations(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme.appColor,
          title: Text('Siparişi Değerlendir'),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.96,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Card(
                    elevation: 20,
                    child: Column(
                      children: [
                        Default(),
                        Text(
                          'Hız($hizrating)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RatingBar(
                          initialRating: 3,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          minRating: 1,
                          itemCount: 5,
                          itemSize: 50,
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
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          onRatingUpdate: (rating) {
                            setState(() {
                              hizrating = rating;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Servis($servisrating)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RatingBar(
                          initialRating: 3,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          minRating: 1,
                          itemSize: 50,
                          itemCount: 5,
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
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          onRatingUpdate: (rating) {
                            setState(() {
                              servisrating = rating;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Lezzet($lezzetrating)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RatingBar(
                          initialRating: 3,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          minRating: 1,
                          itemSize: 50,
                          itemCount: 5,
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
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          onRatingUpdate: (rating) {
                            setState(() {
                              lezzetrating = rating;
                            });
                          },
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Restoran yorumu',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _yorumController,
                            keyboardType: TextInputType.multiline,
                            maxLines: 4,
                            decoration: InputDecoration(
                                hintText: "Bir şeyler yaz...",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 3, color: Colors.black))),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 60),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.09,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(30)),
                          child: ElevatedButton(
                            onPressed: () async {
                              //addYorum();
                              await context
                                  .read<DegerlendirOperations>()
                                  .addYorum(
                                      hizrating: hizrating,
                                      lezzetrating: lezzetrating,
                                      name: name,
                                      servisrating: servisrating,
                                      yorumController: _yorumController.text);

                              //setSiparis();

                              await context
                                  .read<DegerlendirOperations>()
                                  .setSiparis(siparis: siparis);
                              Get.to(HomePage());
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
                            child: Text('Kaydet'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Default extends StatelessWidget {
  const Default({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
    );
  }
}
