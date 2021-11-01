import 'dart:convert';
class FullDetails{
  late StockDetails stocks;
  late List<Data> navList;
  late String status;
  
  FullDetails(
  {
    required this.stocks,
    required this.navList,
    required this.status    
  });
  
  factory FullDetails.fromMap(Map<String,dynamic> json){
    var list = json['data'];
    List<Data> dataList = list.map((i) => Data.fromMap(i).toMap()).toList;
    return FullDetails(stocks: StockDetails.fromMap(json['meta']), navList: dataList, status: json['data']);
    
  }
  
}
class StockDetails {
  late int schemeCode;
  late String schemeName;
  late String fund_house;
  late String scheme_category;
  late String scheme_type;


  StockDetails(
      {required this.schemeCode,
      required this.schemeName,
      required this.fund_house,
      required this.scheme_category,
      required this.scheme_type});

  factory StockDetails.fromMap(Map<String, dynamic> json) {
    return StockDetails(
        schemeCode: json['schemeCode'],
        schemeName: json['schemeName'],
        fund_house: json['fund_house'],
        scheme_category: json['scheme_category'],
        scheme_type: json['scheme_type'],);
  }

  Map<String, dynamic> toMap() => {
        'schemeCode': schemeCode,
        'schemeName': schemeName,
        'fund_house': fund_house,
        'scheme_category': scheme_category,
        'scheme_type': scheme_type,
      };
}

class Data {
  late String date;
  late String nav;
  Data({required this.date, required this.nav});
  factory Data.fromMap(Map<String, dynamic> json) {
    return Data(date: json['date'], nav: json['nav']);
  }
  Map<String, dynamic> toMap() {
    return {'date': date, 'nav': nav};
  }
}

List<StockDetails> stockFromJson(String str) => List<StockDetails>.from(
    json.decode(str).map((x) => StockDetails.fromMap(x)));

String stockToJson(List<StockDetails> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));
