import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  final String productsID;
  final String menuID;
  final String sellersUID;
  final String productDescription;
  final String productTitle;
  final int productPrice;
  final int productQuantity;
  final String thumbnailUrl;
  Timestamp timestamp;

  Items({
    required this.timestamp,
    required this.productsID,
    required this.menuID,
    required this.sellersUID,
    required this.productDescription,
    required this.productTitle,
    required this.productPrice,
    required this.productQuantity,
    required this.thumbnailUrl,
  });

  Items copyWith({
    String? productsID,
    String? menuID,
    String? sellersUID,
    String? productDescription,
    String? productTitle,
    int? productPrice,
    int? productQuantity,
    String? thumbnailUrl,
  }) {
    return Items(
      productsID: productsID ?? this.productsID,
      menuID: menuID ?? this.menuID,
      sellersUID: sellersUID ?? this.sellersUID,
      productDescription: productDescription ?? this.productDescription,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productQuantity: productQuantity ?? this.productQuantity,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productsID': productsID,
      'menuID': menuID,
      'sellersUID': sellersUID,
      'productDescription': productDescription,
      'productTitle': productTitle,
      'productPrice': productPrice,
      'productQuantity': productQuantity,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      productsID: json['productsID'] ,
      menuID: json['menuID'] ?? '',
      sellersUID: json['sellersUID'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productQuantity: json['productQuantity'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(), // Use the appropriate default value
    );
  }


}
