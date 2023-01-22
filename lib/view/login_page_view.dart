import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';
import 'package:mobil_projesi/view/homepage_view.dart';
import 'package:mobil_projesi/view/login_page_view_model.dart';
import 'package:mobil_projesi/view/profile_view_model.dart';
import 'package:mobil_projesi/view/registration_page_view.dart';
import 'package:provider/provider.dart';

import '../core/components/sized_box.dart';

// color şemasıyla renk geçişi yapılsın kırmızıdan sarıya gibi
// yine animasyon olsun ve giriş ekranı tabi ki
// circular progress eklenmeli signin başarılıysa
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // timer ile animasyon yapılması

  TextEditingController _emailController = TextEditingController();
  TextEditingController _sifreController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _sifreController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser?.email);
    return ChangeNotifierProvider<LoginPageOperations>(
      create: (_) => LoginPageOperations(),
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
                        controller: _emailController,
                        decoration: InputDecoration(
                            icon: Icon(
                              Icons.mail,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            hintText: 'E-mail'),
                      ),
                    )),
                DefaultIndent(),
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
                        controller: _sifreController,
                        obscureText: true,
                        decoration: InputDecoration(
                            icon: Icon(Icons.key_outlined, color: Colors.grey),
                            border: InputBorder.none,
                            hintText: 'Şifre'),
                      ),
                    )),
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
                      var response = await FirebaseFirestore.instance
                          .collection("kullanici")
                          .where("email", isEqualTo: _emailController.text)
                          .where("sifre", isEqualTo: _sifreController.text)
                          .limit(1)
                          .get();
                      /*   if (_emailController.text.length > 0 &&
                        _sifreController.text.length > 0) {


                    }*/
                      if (response.docs.isNotEmpty) {
                        // sayfaya yönlendirme
                        //signIn();
                        await context.read<LoginPageOperations>().signIn(
                            email: _emailController.text,
                            sifre: _sifreController.text);
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 170,
                                width: 170,
                                child: AlertDialog(
                                  content: Container(
                                    height: 170,
                                    width: 170,
                                    child: Column(
                                      children: [
                                        Text(
                                          'Kullanıcı Bulunamadı',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        DefaultSized(),
                                        DefaultSized(),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: Lottie.network(
                                              'https://assets2.lottiefiles.com/packages/lf20_ddxv3rxw.json'),
                                        ),
                                        DefaultSized(),
                                        Text('Geçersiz email/şifre'),
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
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
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
                    child: Text('Giriş Yap'),
                  ),
                ),
                DefaultIndent(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    yenni(),
                    TextButton(
                        style: TextButton.styleFrom(primary: Colors.red),
                        onPressed: () {
                          Get.to(RegistrationPage());
                        },
                        child: Text('Şimdi Kayıt Olun'))
                  ],
                ),
              ],
            ),
          ),
        ),
      )),
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

SizedBox yenni() {
  return SizedBox(
    width: 165,
    child: DefaultTextStyle(
      style: const TextStyle(color: Colors.black),
      child: AnimatedTextKit(
        repeatForever: true,
        animatedTexts: [
          TypewriterAnimatedText('Hala kayıtlı değil misin ?'),
        ],
        onTap: null,
      ),
    ),
  );
}
