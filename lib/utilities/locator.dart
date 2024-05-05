import 'dart:async';

import 'package:geolocator/geolocator.dart';

class Locator {
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);

      return position;
    } catch (e) {
      print('LOCATOR EROOR: $e');
      return null;
    }
  }

  Future<String> getPosition() async {
    String locationString = "Failed";
    Position? currentPosition = await _getCurrentPosition();
    if (currentPosition != null) {
      locationString =
          '${currentPosition.latitude}, ${currentPosition.longitude}, ${currentPosition.accuracy}';
      //print("location: $locationString");
    }
    //await Future.delayed(const Duration(seconds: 2));
    print("Precision: ${currentPosition?.accuracy}");
    return locationString;
  }
}
