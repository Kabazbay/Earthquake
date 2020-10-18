import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
//import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(new MaterialApp(home: SplashScreen()));

class DateUtil {
  static String formatDate(DateTime dateTime) {
    return DateFormat("EEE, MMM d,  h:mm a").format(dateTime);
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 5),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => EarthQuakeApp())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Earth",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 55.0,
                  ),
                ),
                Text(
                  "QUAKE",
                  style: TextStyle(
                      color: Colors.red, fontSize: 55.0, fontFamily: "Rustico"),
                ),
              ],
            ),
            Container(
              height: 80.0,
              child: Image.asset(
                'assets/splash.png',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EarthQuakeApp extends StatefulWidget {
  EarthQuakeApp({Key key}) : super(key: key);

  @override
  _EarthQuakeAppState createState() => _EarthQuakeAppState();
}

class _EarthQuakeAppState extends State<EarthQuakeApp> {
  String url =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson';

  List data = [];

  Future makeRequest() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    setState(() {
      var extractdata = json.decode(response.body);
      data = extractdata["features"];
    });
  }

  @override
  void initState() {
    super.initState();
    this.makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 10.0,
        title: Text(
          'Earthquake',
          style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.green[50],
      body: Center(
        child: data.length == 0
            ? SpinKitThreeBounce(color: Colors.green, size: 80.0)
            : ListView.builder(
                padding: EdgeInsets.all(4.0),
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, i) {
                  var location = data[i]["properties"]["place"];
                  var mag = data[i]["properties"]["mag"].toString();
                  var magType = data[i]["properties"]["magType"];
                  var magTY = ("$magType $mag");
                  var geoUrl = data[i]["properties"]["url"];

                  var lat = data[i]["geometry"]["coordinates"][0].toString();
                  var long = data[i]["geometry"]["coordinates"][1].toString();

                  var time = (DateUtil.formatDate(
                      DateTime.fromMillisecondsSinceEpoch(
                          data[i]["properties"]["time"] * 1000)));

                  debugPrint(geoUrl);
                  debugPrint(lat);
                  debugPrint(long);

                  return new ListTile(
                    title: Text(
                      location,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: Colors.green),
                    ),
                    subtitle: Text(
                      time,
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                    trailing: Text(
                      magTY,
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new SecondPage(data[i])));
                    },
                  );
                },
              ),
      ),
    );
  }
}

// class SecondPage extends StatefulWidget {
//   SecondPage(this.data);
//   final data;

//   @override
//   _SecondPageState createState() => _SecondPageState();
// }

// class _SecondPageState extends State<SecondPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         centerTitle: true,
//         title: Text(" "),
//       ),
//     );
//   }
// }

class SecondPage extends StatelessWidget {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  SecondPage(this.data);

  final data;

  // const SecondPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(data["properties"]["place"]),
      ),
      body: (WebView(
        initialUrl: data["properties"]["url"],
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      )),
    );
  }
}
