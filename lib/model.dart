import 'dart:convert';
class Stock {
  late int schemeCode;
  late String schemeName;

  Stock({required this.schemeCode, required this.schemeName});

  factory Stock.fromMap(Map<String, dynamic> json) {
    return Stock(
        schemeCode: json['schemeCode'], schemeName: json['schemeName']);
  }

  Map<String, dynamic> toMap() =>
      {'schemeCode': schemeCode, 'schemeName': schemeName};
}

List<Stock> stockFromJson(String str) =>
    List<Stock>.from(json.decode(str).map((x) => Stock.fromMap(x)));

String stockToJson(List<Stock> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
