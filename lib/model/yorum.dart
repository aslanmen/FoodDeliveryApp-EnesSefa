// To parse this JSON data, do
//
//     final yorum = yorumFromJson(jsonString);

import 'dart:convert';

Yorum? yorumFromJson(String str) => Yorum.fromJson(json.decode(str));

String yorumToJson(Yorum? data) => json.encode(data!.toJson());

class Yorum {
    Yorum({
        required this.hizPuan,
        required this.id,
        required this.kullaniciId,
        required this.lezzetPuan,
        required this.restaurantId,
        required this.servisPuan,
        required this.yorum,
    });

    String hizPuan;
    String id;
    String kullaniciId;
    String lezzetPuan;
    String restaurantId;
    String servisPuan;
    String yorum;

    factory Yorum.fromJson(Map<String, dynamic> json) => Yorum(
        hizPuan: json["hiz_puan"],
        id: json["id"],
        kullaniciId: json["kullanici_id"],
        lezzetPuan: json["lezzet_puan"],
        restaurantId: json["restaurant_id"],
        servisPuan: json["servis_puan"],
        yorum: json["yorum"],
    );

    Map<String, dynamic> toJson() => {
        "hiz_puan": hizPuan,
        "id": id,
        "kullanici_id": kullaniciId,
        "lezzet_puan": lezzetPuan,
        "restaurant_id": restaurantId,
        "servis_puan": servisPuan,
        "yorum": yorum,
    };
}
