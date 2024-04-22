import 'package:maps_toolkit2/maps_toolkit2.dart';

class Calculator {
  //function to find the area of a polygon
  String findArea(points) {
    num areaInSquareMeters = SphericalUtil.computeArea(points);

    return areaInSquareMeters.toStringAsFixed(2);
  }
}
