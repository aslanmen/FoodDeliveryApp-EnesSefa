// To parse this JSON data, do
//
//     final kullanici = kullaniciFromJson(jsonString);

import 'dart:convert';

Kullanici kullaniciFromJson(String str) => Kullanici.fromJson(json.decode(str));

String kullaniciToJson(Kullanici data) => json.encode(data.toJson());

class Kullanici {
    Kullanici({
        required this.adres,
        required this.email,
        required this.id,
        required this.sifre,
    });

    String adres;
    String email;
    String id;
    String sifre;

    factory Kullanici.fromJson(Map<String, dynamic> json) => Kullanici(
        adres: json["adres"],
        email: json["email"],
        id: json["id"],
        sifre: json["sifre"],
    );

    Map<String, dynamic> toJson() => {
        "adres": adres,
        "email": email,
        "id": id,
        "sifre": sifre,
    };
}
