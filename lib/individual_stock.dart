// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import 'database_helper.dart';
// import 'model.dart';
// import 'model2.dart';
//
// class Details extends StatefulWidget {
//   const Details({Key? key}) : super(key: key);
//
//   @override
//   _DetailsState createState() => _DetailsState();
// }
//
// class _DetailsState extends State<Details> {
//
//   @override
//   Future<void> initState() async {
//     // TODO: implement initState
//     super.initState();
//     final response = await http.get(Uri.parse('https://api.mfapi.in/mf'));
//
//     if (response.statusCode == 200) {
//       List jsonResponse = json.decode(response.body);
//
//       futureData = jsonResponse.map((data) => Stock.fromMap(data)).toList();
//
//       var res = await DatabaseHelper.db.insertStock(futureData);
//
//       if (res != null) {
//         setState(() {
//           _query();
//         });
//       }
//       setState(() {});
//     } else {
//       throw Exception('Unexpected error occurred!');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
//
