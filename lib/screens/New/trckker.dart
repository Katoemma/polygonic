import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

import 'package:maps_toolkit2/maps_toolkit2.dart';

class GardenMap extends StatefulWidget {
  const GardenMap({super.key});

  @override
  _GardenMapState createState() => _GardenMapState();
}

class _GardenMapState extends State<GardenMap> {
  final List<LatLng> _boundaryPoints = [];
  final List<LatLng> _recordedPoints = [];
  final List<double> _recordedPrecisions = [];
  StreamSubscription<Position>? _positionStreamSubscription;
  double precision = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Garden Boundary Tracker'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(2.7732484607562564, 32.306918106343524),
              initialZoom: 19.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: _boundaryPoints,
                    borderColor: Colors.blue,
                    borderStrokeWidth: 3.0,
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10.0,
            left: 10.0,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _recordPoint(),
                  child: const Text('Record Point'),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _boundaryPoints.clear();
                          precision = 0.0;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _startTracking();
                      },
                      child: const Text('Start'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _stopTracking();
                      },
                      child: const Text('Stop'),
                    ),
                    Text('Precision: $precision'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startTracking() {
    _stopTracking(); // Stop any previous tracking
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        precision = position.accuracy;
      });
    });
  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
  }

  void _recordPoint() {
    Geolocator.getCurrentPosition().then((Position position) {
      setState(() {
        _recordedPoints.add(LatLng(position.latitude, position.longitude));
        _recordedPrecisions.add(position.accuracy);

        _showRecordedPointDialog(
            position.latitude, position.longitude, position.accuracy);

        if (_recordedPoints.length == 5) {
          _selectBestPoint();
        }
      });
    });
  }

  void _showRecordedPointDialog(
      double latitude, double longitude, double accuracy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Point Recorded'),
          content: Text(
              'Point: ($latitude, $longitude)\nPrecision: $accuracy meters'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _selectBestPoint() {
    int bestIndex = 0;
    double bestPrecision = _recordedPrecisions[0];

    for (int i = 1; i < _recordedPrecisions.length; i++) {
      if (_recordedPrecisions[i] < bestPrecision) {
        bestPrecision = _recordedPrecisions[i];
        bestIndex = i;
      }
    }

    setState(() {
      _boundaryPoints.add(_recordedPoints[bestIndex]);
      _recordedPoints.clear();
      _recordedPrecisions.clear();
    });

    _showBestPointDialog(bestPrecision);
  }

  void _showBestPointDialog(double bestPrecision) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Best Precision Recorded'),
          content: Text(
              'The best precision for the recorded point is: $bestPrecision meters.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
