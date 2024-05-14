import 'dart:async';
import 'dart:convert';

import 'package:dart_airtable/dart_airtable.dart';
import 'package:easy_loading_button/easy_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:polygonic/screens/map_screen.dart';

import '../utilities/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<List<double>> recordedPoints = [];
  List<List<double>> pointsForSubmission = [];
  double recordedPrecision = 0.0;
  int _countdown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    //startCountdown();
  }

  //function to add recorded points to a list
  void addPoint() {
    List<double> locationList = [];
    List<double> coordinatesList = [];
    //print(location);
    double bestPrecision = 100.0;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) async {
      if (_countdown >= 5) {
        timer.cancel();
        //add the list to the list of recorded points
        setState(() {
          recordedPoints.add(locationList);
          pointsForSubmission.add(coordinatesList);
          recordedPrecision = locationList[2];
          _countdown = 0;
        });
        // Navigate to next screen or display something else
      } else {
        //call the geolocator
        String location = await kLocator.getPosition();
        //convert the location to a list
        if (location != "Failed") {
          List<double> locationCheck =
              location.split(', ').map(double.parse).toList();
          if (locationCheck[2] < bestPrecision) {
            bestPrecision = locationCheck[2];
            locationList = locationCheck;
            coordinatesList = [
              locationList[1],
              locationList[0],
              locationList[2]
            ];
            print("Better Point: $bestPrecision at: $_countdown");
          }
          setState(() {
            recordedPrecision = locationList[2];
            _countdown++;
          });
        } else {
          setState(() {
            _countdown = _countdown;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Garden tracking'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.teal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  'https://kijaniforestry.com/wp-content/uploads/2019/03/cropped-Kijani_Logo_BW_Circle-03.png',
                  width: 90,
                  height: 90,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '$_countdown',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (recordedPrecision > 0.0)
                  Text(
                    'Precision: $recordedPrecision',
                    style: const TextStyle(color: Colors.white),
                  ),
                if (recordedPoints.isNotEmpty)
                  Text(
                    'Recorded points: ${recordedPoints.length} --- Precision: $recordedPrecision',
                    style: const TextStyle(color: Colors.white),
                  ),
                const SizedBox(
                  height: 16,
                ),
                EasyButton(
                  buttonColor: Colors.white,
                  borderRadius: 25,
                  height: 50,
                  idleStateWidget: const Text(
                    'Record this point',
                    style: TextStyle(color: Colors.teal),
                  ),
                  loadingStateWidget: const Text('getting coordinates'),
                  onPressed: () {
                    addPoint();
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Colors.black,
                      ),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      )),
                  onPressed: () async {
                    setState(() {
                      recordedPoints.add(recordedPoints.first);
                      pointsForSubmission.add(pointsForSubmission.first);
                    });
                    String polygonData =
                        createGeoJSONPolygon(pointsForSubmission);
                    var response = sendToAirtable(data: polygonData);
                    print(response);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(points: recordedPoints),
                      ),
                    );
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String createGeoJSONPolygon(List<List<double>> points) {
    Map<String, dynamic> geoJSONObject = {
      "type": "Polygon",
      "coordinates": [points]
    };

    return json.encode(geoJSONObject);
  }

  Future<dynamic> sendToAirtable({required String data}) async {
    var apiKey =
        'patsRqLsX7Qj6YTEn.265a5d5b26e78cb3a99489517a9386d1154117ce66542845de3963c216303123';
    var myBaseID = 'appIqWoIxme6lKzL8';
    var tableName = 'MyTable';
    var airtable = Airtable(apiKey: apiKey, projectBase: myBaseID);
    var sent = await airtable.createRecord(
      tableName,
      AirtableRecord(
        fields: [
          AirtableRecordField(
            fieldName: 'Geojson_Data',
            value: data,
          ),
        ],
      ),
      typecast: true,
    );
    print("Created? :$sent");
    return sent ?? "Failed";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
