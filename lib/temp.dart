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
  String sign = '+';
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
      sign = '-';
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
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.02),
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Center(
              child: Text(
                _fullDetails.stocks.schemeName,
                style: GoogleFonts.montserrat(fontSize: w * 0.05),
              ),
            ),
            Container(padding: EdgeInsets.symmetric(vertical: h*0.01),
              alignment: Alignment.centerLeft,
              child: Text(
                _fullDetails.stocks.fund_house,
                style: TextStyle(color: Colors.grey),textAlign:TextAlign.left,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: h * 0.075,
              width: w,
              child:Text(
                current_day.toStringAsFixed(2),
                maxLines: 2,
                style: TextStyle(fontSize: w*0.1),
              ),),
            Container(
              alignment: Alignment.topCenter,
              height: h * 0.075,
              width: w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$sign'
                      '${(current_day-previous_day).abs().toStringAsFixed(3)}',
                    style: TextStyle(color: change_color,fontSize: w*0.05),
                  ),
                  SizedBox(width: w*0.02,),
                  Container(decoration: BoxDecoration(color: change_color,borderRadius: BorderRadius.circular(w*0.01)),
                    padding: EdgeInsets.all(w*0.005),
                    child: Text(
                      '(${percent_change().abs().toStringAsFixed(4)}%)',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
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
                            child: Column(
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
                                      Container(
                                        width: w * 0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(7);
                                          },
                                          textColor: duration[0] == true
                                              ? Colors.white
                                              : Colors.blue,
                                          child: Text('1 W'),
                                          color: duration[0] == true
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: w * 0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(30);
                                          },
                                          textColor: duration[1] == true
                                              ? Colors.white
                                              : Colors.blue,
                                          child: Text('1 M'),
                                          color: duration[1] == true
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: w * 0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(365);
                                          },
                                          textColor: duration[2] == true
                                              ? Colors.white
                                              : Colors.blue,
                                          child: Text('1 Y'),
                                          color: duration[2] == true
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: w * 0.2,
                                        child: MaterialButton(
                                          onPressed: () {
                                            change_time_period(1800);
                                          },
                                          textColor: duration[3] == true
                                              ? Colors.white
                                              : Colors.blue,
                                          child: Text('5 Y'),
                                          color: duration[3] == true
                                              ? Colors.blue
                                              : Colors.white,
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
                              border: Border.all(color: Colors.blue)),
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: h * 0.01),
                              itemCount: _fullDetails.navList.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: h * 0.02,
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
// Monday, November 22, 2021 12:05:39 PM GMT+05:30
/*
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'model2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Details extends StatefulWidget {
  final String schemeCode;
  const Details({Key? key, required this.schemeCode}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  List<int> month_days=[];
  List keys_list=[];
  int i=0;
  Map str_lis = new Map<String, List<String>>();
  List<DateTime> list_dt = [];
  int selectedIndex=0;
  FullDetails _fullDetails = FullDetails(
      stocks: StockDetails(
          schemeCode: 0,
          schemeName: '',
          fund_house: '',
          scheme_type: '',
          scheme_category: ''),
      navList: [Data(date: '', nav: '')],
      status: '');
  late ZoomPanBehavior zoomPan;
  List<bool> duration = [true, false, false, false];
  String time = '1 week';
  Color change_color = Colors.green.shade600;
  double current_day = 0.0, previous_day = 0.0;
  int time_period = 7;
  String sign = '+';
  DateTime selectedDate = DateTime.now();


  ScrollController _scrollController =ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData2();

    zoomPan = ZoomPanBehavior(
        enablePinching: true,
        enableSelectionZooming: true,
        enableMouseWheelZooming: true,
        enablePanning: true,
        zoomMode: ZoomMode.xy);
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
    for(int j=0;j<list_dt.length;j++){
      if(selectedDate == list_dt[j]){
        selectedIndex=j;
      }

    }

  }

  int flag(){return i++;}
  double percent_change() {
    double change;
    change = current_day - previous_day;
    change = (change * 100) / previous_day;
    if (change < 0) {
      sign = '-';
      change_color = Colors.red.shade600;
      setState(() {});
    }
    return change;
  }

  listByDate ()  {
    List<DateTime> dtList = [];
    List<String> str_list = [];
    List<String> str_date_list = [];
    List<String> unq_str_list =[];


    for (int i = 0; i < _fullDetails.navList.length; i++) {
      dtList.add(DateTime.parse(
          _fullDetails.navList[i].date.split('-').reversed.join('-')));
    }
    dtList.forEach((x) {str_date_list.add('${DateFormat('yyyy').format(x)}-${DateFormat('MM').format(x)}-${DateFormat('dd').format(x)}');
    str_list.add('${DateFormat('yyyy').format(x)}-${DateFormat('MM').format(x)}-01'); });
    unq_str_list = str_list.toSet().toList();
    unq_str_list.forEach((x) {
      str_lis[DateFormat('MMMM yyyy').format(DateTime.parse(x))] = <String>[];
      str_date_list.forEach((y) {
        if (x.contains(y.substring(0,7).toString())) {
          str_lis[DateFormat('MMMM yyyy').format(DateTime.parse(x))].add(DateFormat('dd MMMM, yyyy').format(DateTime.parse(y)));
        }
      });
    });

    list_dt = dtList;
    setState(() { });

    //print(str_lis);

/*
print(dtList.length);
    dtList1 =dtList;
    List<String> month_year = [];


     for (int i = 0; i < _fullDetails.navList.length; i++) {
       month_year.add(dtList[i].year.toString()+DateFormat("MM").format(dtList[i]) +"-01");
    }
     List<String> unq_month_year =[];
     unq_month_year = month_year.toSet().toList();
     List<DateTime> unq_dtList = [];

     unq_month_year.forEach((x) {unq_dtList.add(DateTime.parse(x));});
     uniq_dtList = unq_dtList;

List<DateTime> sub_dtList = [];
    setState(() {});
    int i=0,j=0;
    while(j<dtList.length&&i<unq_dtList.length){
      sub_dtList.add(dtList[j]);
      if(dtList[j].month!=unq_dtList[i].month){
       month_days.add(sub_dtList.length);

        sub_dtList.clear();
        i++;
        continue;
      }
      j++;
    }
*/


    //list_dtList.forEach((x) {print(x.length); });
    //print(list_dtList.length);
    //print("hello");

  }

  void fetchData2() async {
    String url1 = 'https://api.mfapi.in/mf/${widget.schemeCode}';

    final response = await http.get(Uri.parse(url1));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      _fullDetails = FullDetails.fromMap(jsonResponse);
      print(_fullDetails.navList[0].toMap()['date']);
      //DateTime dt = DateTime.parse(_fullDetails.navList[0].toMap()['date']);
      current_day = double.parse(_fullDetails.navList[0].toMap()['nav']);
      previous_day = double.parse(_fullDetails.navList[1].toMap()['nav']);
      percent_change();
      setState(() {});
      listByDate();
      /*DateTime start=DateTime.parse(_fullDetails.navList[0].date.split('-').reversed.join('-'));
      DateTime end=DateTime.parse(_fullDetails.navList[_fullDetails.navList.length-1].date.split('-').reversed.join('-'));
      daysBetween(start, end);*/

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

    /*print(_fullDetails.navList[0].date);
    print(_fullDetails.navList[0].date.split('-').reversed.join('-'));
    DateTime dt = DateTime.parse(_fullDetails.navList[0].date.split('-').reversed.join('-'));
    print(DateFormat('dd MMMM, yyyy').format(dt));
    */

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.02),
        child: SingleChildScrollView(
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Center(
              child: Text(
                _fullDetails.stocks.schemeName,
                style: GoogleFonts.montserrat(fontSize: w * 0.05),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: h * 0.01),
              alignment: Alignment.centerLeft,
              child: Text(
                _fullDetails.stocks.fund_house,
                style: GoogleFonts.montserrat(color: Colors.grey),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: h * 0.075,
              width: w,
              child: Text(
                current_day.toStringAsFixed(2),
                maxLines: 2,
                style: GoogleFonts.montserrat(fontSize: w * 0.1),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              height: h * 0.075,
              width: w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$sign'
                        '${(current_day - previous_day).abs().toStringAsFixed(3)}',
                    style: GoogleFonts.montserrat(
                        color: change_color, fontSize: w * 0.05),
                  ),
                  SizedBox(
                    width: w * 0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: change_color,
                        borderRadius: BorderRadius.circular(w * 0.01)),
                    padding: EdgeInsets.all(w * 0.005),
                    child: Text(
                      '(${percent_change().abs().toStringAsFixed(4)}%)',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: w * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Performance Chart',
                    style: GoogleFonts.montserrat(fontSize: w * 0.045),
                  ),
                  Container(
                    width: w * 0.31,
                    height: h * 0.04,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0, horizontal: w * 0.045),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(w * 0.05))),
                      hint: Text('1 week'),
                      value: time,
                      items: <String>['1 week', '1 month', '1 year', '5 year']
                          .map((String time) {
                        return DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        time = value!;
                        int t;

                        if (time.compareTo('1 month') == 0) {
                          t = 30;
                        } else if (time.compareTo('1 year') == 0) {
                          t = 365;
                        } else if (time.compareTo('5 year') == 0) {
                          t = 1800;
                        } else
                          t = 7;
                        zoomPan.reset();
                        change_time_period(t);

                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: h * 0.01),
              width: w,
              height: h * 0.4,
              child: Column(
                children: [
                  SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    primaryXAxis: CategoryAxis(
                        interactiveTooltip: InteractiveTooltip(enable: true),
                        majorGridLines: MajorGridLines(width: 0)),
                    primaryYAxis:
                    NumericAxis(majorGridLines: MajorGridLines(width: 0)),
                    legend: Legend(isVisible: false),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <ChartSeries<Data, String>>[
                      AreaSeries<Data, String>(
                          dataSource: _fullDetails.navList
                              .sublist(0, time_period)
                              .reversed
                              .toList(),
                          gradient: LinearGradient(
                              colors: [
                                change_color.withAlpha(255),
                                change_color.withAlpha(200),
                                change_color.withAlpha(150)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                          xValueMapper: (Data sales, _) => sales.date,
                          yValueMapper: (Data sales, _) =>
                              double.tryParse(sales.nav),
                          name: 'NAV Value',
                          // Enable data label
                          dataLabelSettings:
                          DataLabelSettings(isVisible: false))
                    ],
                    zoomPanBehavior: zoomPan,
                  ),
                ],
              ),
            ),
            Container(
              height: h * 0.6,
              margin: EdgeInsets.all(w * 0.01),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Container(
                      margin: EdgeInsets.all(w * 0.01),
                      height: h * 0.075,
                      width: w,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: h * 0.005, horizontal: w * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Historical NAVs',
                            style: GoogleFonts.montserrat(
                                fontSize: w * 0.05, color: Colors.white),
                          ),
                          IconButton(
                              onPressed: () {_selectDate(context);   _scrollController.animateTo(selectedIndex*h*0.01, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);print(selectedIndex);
                              },
                              icon: Icon(
                                Icons.calendar_today,
                                size: w * 0.05,
                                color: Colors.white,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: h * 0.08,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: w * 0.01),
                        height: h * 0.51,
                        width: w * 0.95,
                        child: ListView.builder(controller: _scrollController,

                            padding: EdgeInsets.only(top: h * 0.01),
                            itemCount: str_lis.length,
                            itemBuilder: (context, index) {

                              return Column(
                                children: [
                                  Container(
                                    height: h * 0.05,
                                    width: w * 0.95,
                                    margin: EdgeInsets.symmetric(vertical: 1),
                                    color: Colors.blue.shade300,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: w * 0.05),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          str_lis.keys.elementAt(index),
                                          style: GoogleFonts.montserrat(
                                              fontSize: w * 0.03,
                                              color: Colors.white),
                                        ),

                                      ],
                                    ),
                                  ),
                                  Container(
                                      height: h * 0.04*str_lis.values.elementAt(index).length,
                                      width: w * 0.95,
                                      margin: EdgeInsets.symmetric(vertical: 1),
                                      child: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: str_lis.values.elementAt(index).length,
                                          itemBuilder: (context, x) {
                                            return Container(
                                              height: h * 0.04,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: w * 0.05),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(str_lis.values.elementAt(index)[x]),
                                                  Text('${_fullDetails.navList[flag()].nav}',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                          fontSize:
                                                          w * 0.03,
                                                          color:
                                                          Colors.blue)),
                                                ],
                                              ),
                                            );

                                          })),
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
                  Positioned(
                      right: w * 0.025,
                      bottom: w * 0.025,
                      child: CircleAvatar(
                        radius: w * 0.04,
                        backgroundColor: Colors.white,
                        child: IconButton(padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_circle_up,
                            size: w * 0.08,
                          ),
                          onPressed: (){_scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);},
                        ),
                      ))
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

