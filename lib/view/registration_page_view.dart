import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mobil_projesi/core/colors/themeColor.dart';
import 'package:mobil_projesi/core/components/sized_box.dart';
import 'package:mobil_projesi/view/login_page_view.dart';
import 'package:mobil_projesi/view/registration_page_view_model.dart';
import 'package:provider/provider.dart';

// color şemasıyla renk geçişi yapılsın kırmızıdan sarıya gibi
// yine animasyon olsun ve giriş ekranı tabi ki

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  bool _visible = true;

  backtoLogin() {
    Get.to(LoginPage());
  }

  bool check() {
    if (_emailController.text.length == 0 ||
        _sifreController.text.length == 0) {
      return true;
    }
    return false;
  }

  changeVisible() {
    _visible = !_visible;
  }

  bool checkEmail(String email) {
    for (int i = 0; i < email.length; i++) {
      if (email[i] == '@') {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _sifreController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegistraitonPageOperations>(
      create: (_) => RegistraitonPageOperations(),
      builder: (context, _) => Scaffold(
          //appBar: ,
          body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [
                  0.07,
                  0.4,
                  1.8,
                  0.1,
                  0.3
                ],
                    colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.white
                ])),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.16,
                ),
                SizedBox(
                    height: 300,
                    width: 300,
                    child: Image.asset('assets/lpg.gif')),
                /*('İYİ GİDER',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),*/

                myText(
                    _emailController,
                    'E-mail*',
                    Icon(
                      Icons.mail,
                      color: Colors.grey,
                    ),
                    false),
                DefaultIndent(),
                myText(_sifreController, 'Şifre*',
                    Icon(Icons.key_outlined, color: Colors.grey), true),
                DefaultIndent(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.09,
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(30)),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (check()) {
                        /// hata dönder
                        //changeVisible();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: appTheme.appColor,
                          content: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Text(
                                  'E-mail ve Şifre bilgileriniz eksiksiz girilmelidir'),
                            ],
                          ),
                          duration: Duration(seconds: 1),
                        ));
                        //print(_visible);
                      } else {
                        if (checkEmail(_emailController.text)) {
                          //newUser();
                          await context
                              .read<RegistraitonPageOperations>()
                              .newUser(
                                email: _emailController.text.trim(),
                                sifre: _sifreController.text.trim(),
                              );

                          //changeVisible();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text('Yeni Kullanıcı Hesabı Oluşturuldu'),
                              ],
                            ),
                            duration: Duration(seconds: 1),
                          ));
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 170,
                                  width: 150,
                                  child: AlertDialog(
                                    content: Container(
                                      height: 130,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            child: Lottie.network(
                                                'https://assets2.lottiefiles.com/packages/lf20_ddxv3rxw.json'),
                                          ),
                                          DefaultSized(),
                                          Text('Hatalı email formatı'),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Kapat')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }
                      }
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(width: 3, color: Colors.black),
                        ),
                      ),
                    ),
                    child: Text('Kayıt Ol'),
                  ),
                ),
                DefaultIndent(),
                myButton('Geri Dön', backtoLogin),
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class myText extends StatelessWidget {
  TextEditingController _sifreController;
  String hint;
  Icon myIcon;
  bool obscuretext;
  myText(this._sifreController, this.hint, this.myIcon, this.obscuretext);
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
            obscureText: obscuretext,
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

class DefaultIndent extends StatelessWidget {
  const DefaultIndent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.01,
    );
  }
}
