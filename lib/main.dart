import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'database_helper.dart';
import 'model.dart';
import 'package:http/http.dart' as http;
import 'model2.dart';

const String url1 = 'https://api.mfapi.in/mf/100055';

void main() {
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int get) => true;
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Details(),
    );
  }
}

class Details extends StatefulWidget {
  const Details({Key? key}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final client = Dio();
  var isLoading = false;
   FullDetails _fullDetails = FullDetails(stocks: StockDetails(schemeCode: 0,schemeName: '',fund_house: '',scheme_type: '',scheme_category: ''),
       navList: [Data(date: '',nav: '')], status: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData2();
  }

  void fetchData2() async {
    final response = await http.get(Uri.parse(url1));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      _fullDetails = (FullDetails.fromMap(jsonResponse));
    } else {
      throw Exception('Unexpected error occurred!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Text(_fullDetails.stocks.schemeName),
      ]),
    );
  }
}
