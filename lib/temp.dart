/*
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
*/
/*
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'model2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Details extends StatefulWidget {
  final String schemeCode;
  const Details({Key? key, required this.schemeCode}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> with TickerProviderStateMixin {
  FullDetails _fullDetails = FullDetails(
      stocks: StockDetails(
          schemeCode: 0,
          schemeName: '',
          fund_house: '',
          scheme_type: '',
          scheme_category: ''),
      navList: [Data(date: '', nav: '')],
      status: '');
  List<bool> duration = [true, false, false, false];
  Color change_color = Colors.green;
  double current_day = 0.0, previous_day = 0.0;
  int time_period = 7;
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    fetchData2();
  }

  double percent_change() {
    double change;
    change = current_day - previous_day;
    change = (change * 100) / previous_day;
    if (change < 0) {
      change_color = Colors.red;
      setState(() {});
    }
    return change;
  }

  void fetchData2() async {
    String url1 = 'https://api.mfapi.in/mf/${widget.schemeCode}';

    final response = await http.get(Uri.parse(url1));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      _fullDetails = FullDetails.fromMap(jsonResponse);
      current_day = double.parse(_fullDetails.navList[0].toMap()['nav']);
      previous_day = double.parse(_fullDetails.navList[1].toMap()['nav']);
      percent_change();
      setState(() {});
    } else {
      throw Exception('Unexpected error occurred!');
    }
  }

  void change_time_period(int t) {
    for (int i = 0; i < duration.length; i++) {
      duration[i] = false;
    }
    switch (t) {
      case 7:
        duration[0] = true;
        break;
      case 30:
        duration[1] = true;
        break;
      case 365:
        duration[2] = true;
        break;
      case 1800:
        duration[3] = true;
        break;
      default:
        duration[0] = true;
    }
    time_period = t;
    if (t > _fullDetails.navList.length) {
      time_period = _fullDetails.navList.length;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:  Text(
          _fullDetails.stocks.schemeName,
          maxLines: 2,
          style: GoogleFonts.montserrat(fontSize: w*0.05),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left:w*0.01,right: w*0.01),
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Container(
                alignment: Alignment.bottomLeft,
                height: h * 0.075,
                width: w,
                child: Row(
                  children: [
                    Text(
                      current_day.toStringAsFixed(2),
                      maxLines: 2,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      width: w * 0.03,
                    ),
                    Text(
                      '(${percent_change().toStringAsFixed(4)}%)',
                      style: TextStyle(color: change_color),
                    )
                  ],
                )),
            Container(
              alignment: Alignment.topLeft,
              height: h * 0.05,
              width: w,
              child: Text(
                _fullDetails.navList[0].toMap()['date'],
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Container(
              height: h,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TabBar(
                      controller: _tabController,
                      indicatorWeight: 3,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.lightBlue,
                      overlayColor: MaterialStateProperty.all(Colors.blue),
                      indicator: BoxDecoration(color: Colors.blue),
                      tabs: [
                        Tab(
                          child: Text(
                            'Performance Chart',
                          ),
                          height: h * 0.05,
                        ),
                        Tab(
                          child: Text('Historical Nav'),
                          height: h * 0.05,
                        )
                      ]),
                  Container(
                    alignment: Alignment.center,
                    height: h * 0.65,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue)),
                            width: w * 0.4,
                            height: h * 0.5,
                            child:
                            Column(
                              children: [
                                SfCartesianChart(
                                    primaryXAxis: CategoryAxis(),
                                    title:
                                    ChartTitle(text: 'Performance Chart'),
                                    legend: Legend(isVisible: false),
                                    tooltipBehavior:
                                    TooltipBehavior(enable: true),
                                    series: <ChartSeries<Data, String>>[
                                      LineSeries<Data, String>(
                                          dataSource: _fullDetails.navList
                                              .sublist(0, time_period)
                                              .reversed
                                              .toList(),
                                          xValueMapper: (Data sales, _) =>
                                          sales.date,
                                          yValueMapper: (Data sales, _) =>
                                              double.tryParse(sales.nav),
                                          name: 'NAV Value',
                                          // Enable data label
                                          dataLabelSettings: DataLabelSettings(
                                              isVisible: false))
                                    ]),
                                Container(
                                  width: w,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(width: w*0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(7);
                                          },
                                          textColor: duration[0]==true ? Colors.white : Colors.blue,
                                          child: Text('1 W'),
                                          color: duration[0]==true ? Colors.blue : Colors.white,

                                        ),
                                      ),
                                      Container(width: w*0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(30);
                                          },
                                          textColor: duration[1]==true ? Colors.white : Colors.blue,
                                          child: Text('1 M'),
                                          color: duration[1]==true ? Colors.blue : Colors.white,

                                        ),
                                      ),  Container(width: w*0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(365);
                                          },
                                          textColor: duration[2]==true ? Colors.white : Colors.blue,
                                          child: Text('1 Y'),
                                          color: duration[2]==true ? Colors.blue : Colors.white,

                                        ),
                                      ),  Container(width: w*0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(1800);
                                          },
                                          textColor: duration[3]==true ? Colors.white : Colors.blue,
                                          child: Text('5 Y'),
                                          color: duration[3]==true ? Colors.blue : Colors.white,

                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          height: h * 0.1,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue)
                          ),
                          child: ListView.builder(padding: EdgeInsets.only(top: h*0.01),
                              itemCount: _fullDetails.navList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: h*0.02,
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(_fullDetails.navList[index]
                                          .toMap()['date']
                                          .toString()),
                                      Text(_fullDetails.navList[index]
                                          .toMap()['nav']
                                          .toString())
                                    ],
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
*/
