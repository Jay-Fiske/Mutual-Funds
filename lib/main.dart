import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'database_helper.dart';
import 'individual_stock.dart';
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
  bool isSearch = false;
  var isLoading = false;
  List<Stock> futureData = [];

  List<Stock> result = [];
  List<Stock> match = [];
  TextEditingController searchField = TextEditingController();

  @override
  void initState() {
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
      appBar: AppBar(
        elevation: 1,
        title: !isSearch
            ? Text('Scheme Analyzer')
            : Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
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
                                isSearch = false;
                              });
                            }),
                        hintText: 'Search...',
                        border: InputBorder.none),
                    onChanged: (val) {
                      match.clear();

                      for (int i = 0; result.length > i; i++) {
                        if (result[i]
                                .schemeName
                                .toLowerCase()
                                .contains(val.toLowerCase()) ||
                            result[i].schemeCode.toString().contains(val)) {
                          match.add(result[i]);
                        }
                      }

                      setState(() {});
                    },
                  ),
                ),
              ),
        actions: <Widget>[
          Visibility(
            visible: !isSearch,
            child: Container(
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  isSearch = true;
                  setState(() {});
                },
              ),
            ),
          ),
          Container(
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
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Details(
                                              schemeCode: result[index]
                                                  .schemeCode
                                                  .toString(),
                                            )));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: w * 0.01, vertical: h * 0.005),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 2,
                                  child: Container(
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Details(
                                              schemeCode: match[index]
                                                  .schemeCode
                                                  .toString(),
                                            ),
                                          ),
                                        );
                                      },
                                      title: Text(match[index].schemeName),
                                      subtitle: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                        child: Text("Scheme Code : " +
                                            match[index].schemeCode.toString()),
                                      ),
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
                    : ListView.builder(
                        itemCount: result.length,
                        itemBuilder: (BuildContext context, int index) {
                          //
                          // log('array size ${snapshot.data.length}');
                          return Container(
                            child: Center(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.01,
                                        vertical: h * 0.005),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Details(
                                                      schemeCode: result[index]
                                                          .schemeCode
                                                          .toString(),
                                                    )));
                                      },
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        elevation: 2,
                                        child: Container(
                                          child: ListTile(
                                            title:
                                                Text(result[index].schemeName),
                                            subtitle: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Text("Scheme Code: "
                                                  "${result[index].schemeCode.toString()}"),
                                            ),
                                          ),
                                        ),
                                      ),
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
