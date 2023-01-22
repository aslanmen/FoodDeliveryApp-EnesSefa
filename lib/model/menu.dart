// To parse this JSON data, do
//
//     final menu = menuFromJson(jsonString);

import 'dart:convert';

Menu menuFromJson(String str) => Menu.fromJson(json.decode(str));

String menuToJson(Menu data) => json.encode(data.toJson());

class Menu {
    Menu({
        required this.ad,
        required this.id,
        required this.restaurantId,
        required this.tur,
        required this.ucret,
    });

    String ad;
    String id;
    String restaurantId;
    String tur;
    String ucret;

    factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        ad: json["ad"],
        id: json["id"],
        restaurantId: json["restaurant_id"],
        tur: json["tur"],
        ucret: json["ucret"],
    );

    Map<String, dynamic> toJson() => {
        "ad": ad,
        "id": id,
        "restaurant_id": restaurantId,
        "tur": tur,
        "ucret": ucret,
    };
}
