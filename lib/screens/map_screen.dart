import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:polygonic/utilities/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.points});

  final List points;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> pointsList = [];
  LatLng initialPoint = const LatLng(1.373333, 32.290275);
  String area = '';
  void getPoints() {
    //loop through the points list and convert each point to a LatLng
    for (var point in widget.points) {
      print('MY POINT: $point');

      print('MY first point ${point[0]} and LAST is ${point[1]}');
      //create a new LatLng object with the latitude and longitude from the point
      LatLng latLng = LatLng(point[0], point[1]);
      print('MY LATLNG: $latLng');
      //add the LatLng object to the pointsList
      pointsList.add(latLng);
      print('MY POINTS LIST: $pointsList');
    }
    initialPoint = pointsList.first;
    print('MY INITIAL POINT: $initialPoint');
    //calculate the area
    area = kCalculate.findArea(pointsList);
    print('MY AREA: $area');
    //set the state to update the UI
  }

  //function to show bottom sheet
  void showBottomSheet() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Tracking results',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              leading: const Icon(
                Icons.route,
                color: Colors.green,
              ),
              title: Text('Points drawn: ${widget.points.length}'),
            ),
            ListTile(
              leading: const Icon(
                Icons.crop,
                color: Colors.green,
              ),
              title: Text('Area tracked: ${double.parse(area) / 10000} ha'),
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Text(
                      'Retrack',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Polygon'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: initialPoint, // Coordinates for Uganda
              initialZoom: 20, // Zoom level adjusted for better visibility
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                      points: pointsList,
                      color: Colors.blue.withOpacity(0.5),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blue,
                      isFilled: true),
                ],
              ),
            ],
          ),
          Positioned(
            right: 5.0,
            bottom: 5.0,
            child: TextButton(
              onPressed: () {},
              child: FloatingActionButton(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed: () {
                  showBottomSheet();
                },
                child: const Icon(Icons.send),
              ),
            ),
          )
        ],
      ),
    );
  }
}
