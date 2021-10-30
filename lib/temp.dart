import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';
import 'model.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int get) => true;
  }
}

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
      home: const MyHomePage(title: 'Api to Sqflite'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final client = Dio();
  var isLoading = false;
  List<Stock> futureData = [];

  List<Stock> result = [];
  List<Stock> match = [];
  TextEditingController searchField = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _query();
  }

  _query() async {
    result = await DatabaseHelper.db.getAllStock();
    setState(() {});
    if (result.isEmpty) {
      fetchData();
    } else {
      return result;
    }

    return result;
  }

  void fetchData() async {
    final response = await http.get(Uri.parse('https://api.mfapi.in/mf'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);

      futureData = jsonResponse.map((data) => Stock.fromMap(data)).toList();

      var res = await DatabaseHelper.db.insertStock(futureData);

      if (res != null) {
        setState(() {
          _query();
        });
      }
      setState(() {});
    } else {
      throw Exception('Unexpected error occurred!');
    }

  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(elevation: 1,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: TextField(
              controller: searchField,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchField.clear();
                          match.clear();

                        });
                      }),
                  hintText: 'Search...',
                  border: InputBorder.none),
              onChanged: (val) {
                match.clear();

                for (int i = 0; result.length > i; i++) {
                  if (result[i].schemeName.toLowerCase().contains(val.toLowerCase()) ||
                      result[i].schemeCode.toString().contains(val)) {
                    match.add(result[i]);
                  }
                }

                setState(() {});
              },
            ),
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.refresh_rounded),
              onPressed: () {
                fetchData();
              },
            ),
          ),

          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: match.isNotEmpty
                ? ListView.builder(
                itemCount: match.length,
                itemBuilder: (BuildContext context, int index) {
                  return Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            child: Card(
                              elevation: 2,
                              child: Container(
                                margin: EdgeInsets.all(4),
                                child: ListTile(
                                  onTap: () {},
                                  title: Text("Scheme Code : " +
                                      match[index].schemeCode.toString()),
                                  subtitle: Text("Scheme Name : " +
                                      match[index].schemeName),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                : result.isEmpty
                ? Center(
              child: CircularProgressIndicator(),
            )
                : ListView.separated(
              separatorBuilder: (context, index) => const Divider(
                color: Colors.black12,
              ),
              itemCount: result.length,
              itemBuilder: (BuildContext context, int index) {
                //
                // log('array size ${snapshot.data.length}');
                return Container(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            child: Card(
                                elevation: 2,
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  child: ListTile(
                                    leading: Text(
                                      "${index + 1}",
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    title: Text(result[index]
                                        .schemeCode
                                        .toString()),
                                    subtitle:
                                    Text(result[index].schemeName),
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
