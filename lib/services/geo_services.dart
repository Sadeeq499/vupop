import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socials_app/models/post_models.dart' as p;
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/utils/app_strings.dart';

import '../utils/common_code.dart';

class GeoServices {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // CustomSnackbar.showSnackbar('Location services are disabled.');
      permission = await Geolocator.requestPermission();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomSnackbar.showSnackbar('Location permissions are denied');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  static Future<Placemark> getPlacemark() async {
    Position position = await determinePosition();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks[0];
  }

  static Future<String> getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    final address =
        "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].country}";
    return address;
  }

  static Future<String> getCountryCode(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0].isoCountryCode!;
  }

  static Future<String> getCity(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0].locality!;
  }

  static calculateDistance(double lat, double lng, p.Location aLocation) {
    return Geolocator.distanceBetween(lat, lng,
        aLocation.coordinates?[0] ?? 0.0, aLocation.coordinates?[1] ?? 0.0);
  }

  static double calculateNearDistance({
    required double lat,
    required double long,
    required p.Location aLocation,
    int radius = 10,
  }) {
    final double distanceInMeters = Geolocator.distanceBetween(
      lat,
      long,
      aLocation.coordinates?[0] ?? 0.0,
      aLocation.coordinates?[1] ?? 0.0,
    );

    if (distanceInMeters > radius) {
      return 0;
    } else {
      return distanceInMeters;
    }
  }

  static Future<String> placeApi(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    return placemarks[0].locality!;
  }

  static Future<List<String>> fetchSuggestions(String input) async {
    List<String> suggestions = [];
    try {
      if (input.isEmpty) return [];

      final String request =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$kGOOGLEMAPSAPIKEY';

      final response = await Dio().get(request);
      printLogs('${response.statusCode} response: ${response.data}');
      if (response.statusCode == 200) {
        final json = response.data;
        printLogs('json: $json');
        for (var element in json['predictions']) {
          suggestions.add(element['description']);
        }
        return suggestions;
      }
    } catch (e) {
      printLogs('fetchSuggestions Exception : $e');
    }
    return suggestions;
  }

  static Future<LatLng> getLatLngFromPlace(String place) async {
    final String request =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$place&key=$kGOOGLEMAPSAPIKEY';
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['results'][0]['geometry']['location'];

      return LatLng(location['lat'], location['lng']);
    } else {
      throw Exception('Failed to fetch location');
    }
  }
}
