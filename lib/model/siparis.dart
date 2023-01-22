// To parse this JSON data, do
//
//     final siparis = siparisFromJson(jsonString);

import 'dart:convert';

Siparis? siparisFromJson(String str) => Siparis.fromJson(json.decode(str));

String siparisToJson(Siparis? data) => json.encode(data!.toJson());

class Siparis {
    Siparis({
        required this.adres,
        required this.gun,
        required this.id,
        required this.kullaniciId,
        required this.puanlama,
        required this.restaurantId,
        required this.saat,
        required this.siparisSure,
        required this.tutar,
    });

    String adres;
    String gun;
    String id;
    String kullaniciId;
    String puanlama;
    String restaurantId;
    String saat;
    String siparisSure;
    String tutar;

    factory Siparis.fromJson(Map<String, dynamic> json) => Siparis(
        adres: json["adres"],
        gun: json["gun"],
        id: json["id"],
        kullaniciId: json["kullanici_id"],
        puanlama: json["puanlama"],
        restaurantId: json["restaurant_id"],
        saat: json["saat"],
        siparisSure: json["siparis_sure"],
        tutar: json["tutar"],
    );

    Map<String, dynamic> toJson() => {
        "adres": adres,
        "gun": gun,
        "id": id,
        "kullanici_id": kullaniciId,
        "puanlama": puanlama,
        "restaurant_id": restaurantId,
        "saat": saat,
        "siparis_sure": siparisSure,
        "tutar": tutar,
    };
}
