import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'model2.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class Details extends StatefulWidget {
  final String schemeCode;
  const Details({Key? key, required this.schemeCode}) : super(key: key);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
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

  double scrollExtent = 0;
  List<bool> duration = [true, false, false, false];
  String time = '1 week';
  Color change_color = Colors.green.shade600;
  double current_day = 0.0, previous_day = 0.0;
  int time_period = 7;
  String sign = '+';

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
    for (int i = 0; i < _fullDetails.navList.length; i++) {
      dtList.add(DateTime.parse(
          _fullDetails.navList[i].date.split('-').reversed.join('-')));
    }
    //dtList.reversed;
    //print(dtList);
    List<String> month_year = [];

    //print(month_year);

     for (int i = 0; i < _fullDetails.navList.length-1; i++) {
       month_year.add("01-"+DateFormat("MM").format(dtList[i]) +"-"+ dtList[i].year.toString());
    }
     List<String> unq_month_year =[];
     unq_month_year = month_year.toSet().toList();
     print(unq_month_year);

    print(month_year.length);
    print("hello");
    //print(month_year);

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
      listByDate();
      /*DateTime start=DateTime.parse(_fullDetails.navList[0].date.split('-').reversed.join('-'));
      DateTime end=DateTime.parse(_fullDetails.navList[_fullDetails.navList.length-1].date.split('-').reversed.join('-'));
      daysBetween(start, end);*/

    } else {
      throw Exception('Unexpected error occurred!');
    }
  }

  /*void daysBetween(DateTime from, DateTime to) {
    print(from.weekday);
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    _fullDetails.navList.forEach((x) {print(x.date); });

    print((to.difference(from).inHours / 24).round().abs());
    print(_fullDetails.navList.length);
  }*/
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
              height: h * 0.57,
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
                              onPressed: () {},
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
                        child: ListView.builder(
                            padding: EdgeInsets.only(top: h * 0.01),
                            itemCount: 6,
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
                                          'November',
                                          style: GoogleFonts.montserrat(
                                              fontSize: w * 0.03,
                                              color: Colors.white),
                                        ),
                                        SizedBox(
                                          width: w * 0.01,
                                        ),
                                        Text('2021',
                                            style: GoogleFonts.montserrat(
                                                fontSize: w * 0.03,
                                                color: Colors.white))
                                      ],
                                    ),
                                  ),
                                  Container(
                                      height: h * 0.15,
                                      width: w * 0.95,
                                      margin: EdgeInsets.symmetric(vertical: 1),
                                      child: ListView.builder(
                                          itemCount: 3,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              height: h * 0.04,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: w * 0.05),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('13 November, 2021'),
                                                  Text('10.345',
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize:
                                                                  w * 0.03,
                                                              color:
                                                                  Colors.blue))
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
                        child: Icon(
                          Icons.arrow_circle_up,
                          size: w * 0.08,
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
