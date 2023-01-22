// To parse this JSON data, do
//
//     final restaurant = restaurantFromJson(jsonString);

import 'dart:convert';

Restaurant? restaurantFromJson(String str) => Restaurant.fromJson(json.decode(str));

String restaurantToJson(Restaurant? data) => json.encode(data!.toJson());

class Restaurant {
    Restaurant({
        required this.ad,
        required this.adres,
        required this.gorsel,
        required this.hizPuan,
        required this.id,
        required this.lezzetPuan,
        required this.servisPuan,
    });

    String? ad;
    String? adres;
    String? gorsel;
    String? hizPuan;
    String? id;
    String? lezzetPuan;
    String? servisPuan;

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        ad: json["ad"],
        adres: json["adres"],
        gorsel: json["gorsel"],
        hizPuan: json["hiz_puan"],
        id: json["id"],
        lezzetPuan: json["lezzet_puan"],
        servisPuan: json["servis_puan"],
    );

    Map<String, dynamic> toJson() => {
        "ad": ad,
        "adres": adres,
        "gorsel": gorsel,
        "hiz_puan": hizPuan,
        "id": id,
        "lezzet_puan": lezzetPuan,
        "servis_puan": servisPuan,
    };
}
