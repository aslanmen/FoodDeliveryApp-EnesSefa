import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/view/login_page_view.dart';
import 'package:mobil_projesi/view/profile_view_model.dart';
import 'package:provider/provider.dart';

import '../model/kullanici.dart';
import '../service/auth.dart';

class Profil extends StatefulWidget {
  Kullanici kullanici;
  Profil(this.kullanici);

  @override
  State<Profil> createState() => _ProfilState(kullanici);
}

class _ProfilState extends State<Profil> {
  Kullanici kullanici;
  _ProfilState(this.kullanici);

  TextEditingController _emailController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();
  TextEditingController _adresController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;

  // şifre kaydetme
  void _changePassword(String password) async {
    User? user = await Auth().currentUser;

    user?.updatePassword(password).then((_) {
      print("Şifre değişti yeni şifre : $password");
    });
  }

  String changerMail = '';
  String changerSifre = '';
  String changerAdres = '';
  @override
  void initState() {
    super.initState();
    print(kullanici.email);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateProfileView>(
      create: (_) => UpdateProfileView(),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: appTheme.appColor,
          title: Text('Profilim'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: () async {
                  //signOut();
                  await context.read<UpdateProfileView>().signOut();
                },
                icon: Icon(Icons.logout))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                //CircleAvatar(child: Icon(Icons.portable_wifi_off_outlined)),/// default foto koyalım!
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),

                SizedBox(
                  height: 10,
                ), // default core dan alınır
                Text(
                  'E-mail',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ), // default sized core dan alınacak
                Text(_emailController.text.length > 0
                    ? changerMail
                    : kullanici.email),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Şifre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(_sifreController.text.length > 0
                    ? changerSifre
                    : kullanici.sifre),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Adres',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(_adresController.text.length > 0
                    ? changerAdres
                    : kullanici.adres),
                SizedBox(
                  height: 30,
                ),

                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            changerMail = value;
                          });
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.mail,
                              color: Colors.black38,
                            ),
                            border: InputBorder.none,
                            hintText: 'E-mail'),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            changerSifre = value;
                          });
                        },
                        controller: _sifreController,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.key_outlined,
                              color: Colors.black38,
                            ),
                            border: InputBorder.none,
                            hintText: 'Şifre'),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),

                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.09,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(30)),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            changerAdres = value;
                          });
                        },
                        controller: _adresController,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.apartment_sharp,
                              color: Colors.black38,
                            ),
                            border: InputBorder.none,
                            hintText: 'Adres'),
                      ),
                    )),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(30)),
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<UpdateProfileView>().updateUser(
                          adres: changerAdres,
                          email: changerMail,
                          sifre: changerSifre,
                          kullanici: kullanici);
                      _changePassword(_sifreController.text);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 1),
                          backgroundColor: Colors.white,
                          content: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                child: Lottie.network(
                                    "https://assets1.lottiefiles.com/packages/lf20_vuliyhde.json"),
                              ),
                              Text(
                                'Kaydınız başarıyla güncellendi',
                                style: TextStyle(color: Colors.green),
                              ),
                            ],
                          )));
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text('Güncelle'),
                  ),
                ),
                //myButton('Çıkış Yap',signOut),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*Container textos(BuildContext context, String hint,
      TextEditingController controller, Icon iconn, String changerrr) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.09,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            onChanged: (value) {
              
                changerrr = value;
              
            },
            controller: controller,
            decoration: InputDecoration(
                icon: iconn, border: InputBorder.none, hintText: hint),
          ),
        ));
  }*/

class myText extends StatelessWidget {
  TextEditingController _sifreController;
  String hint;
  Icon myIcon;
  //Function() onchanged;
  myText(this._sifreController, this.hint, this.myIcon); //,this.onchanged);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.09,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            //onChanged: ,//onchanged(),
            controller: _sifreController,
            decoration: InputDecoration(
                icon: myIcon, border: InputBorder.none, hintText: hint),
          ),
        ));
  }
}

class myButton extends StatelessWidget {
  String text;
  Function() onpressed;
  myButton(this.text, this.onpressed);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.09,
      decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(30)),
      child: ElevatedButton(
        onPressed: onpressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(width: 3, color: Colors.black),
            ),
          ),
        ),
        child: Text(this.text),
      ),
    );
  }
}
