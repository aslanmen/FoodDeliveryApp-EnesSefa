// To parse this JSON data, do
//
//     final sepetObject = sepetObjectFromJson(jsonString);

import 'dart:convert';

SepetObject sepetObjectFromJson(String str) => SepetObject.fromJson(json.decode(str));

String sepetObjectToJson(SepetObject data) => json.encode(data.toJson());

class SepetObject {
    SepetObject({
        required this.id,
        required this.kullaniciId,
        required this.restaurantId,
        required this.urunAd,
        required this.urunUcret,
    });

    String id;
    String kullaniciId;
    String restaurantId;
    String urunAd;
    String urunUcret;

    factory SepetObject.fromJson(Map<String, dynamic> json) => SepetObject(
        id: json["id"],
        kullaniciId: json["kullanici_id"],
        restaurantId: json["restaurant_id"],
        urunAd: json["urun_ad"],
        urunUcret: json["urun_ucret"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "kullanici_id": kullaniciId,
        "restaurant_id": restaurantId,
        "urun_ad": urunAd,
        "urun_ucret": urunUcret,
    };
}
