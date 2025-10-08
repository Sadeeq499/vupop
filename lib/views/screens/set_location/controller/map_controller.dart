import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socials_app/services/custom_snackbar.dart';

import '../../../../services/geo_services.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/common_code.dart';

class MapController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> mapController = Completer();
  var mapStyle = ''.obs;
  late GoogleMapController googleMapController;
  final RxList<Marker> myMarker = RxList();
  final CameraPosition initialPosition = const CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 11);

  TextEditingController tecBuildingName = TextEditingController();
  TextEditingController tecApartmentNo = TextEditingController();
  TextEditingController tecNotes = TextEditingController();
  TextEditingController searchController = TextEditingController();

  FocusNode fnBuildingName = FocusNode();
  FocusNode fnApartmentNo = FocusNode();
  FocusNode fnNotes = FocusNode();

  RxString selectedLabel = 'Other'.obs;
  RxDouble maxChildSize = 0.0.obs;

  final LatLng center = const LatLng(-23.5557714, -46.6395571);
  // void onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  // }

  RxSet<Circle> circles = RxSet();
  Future<Position> getUserLocation({bool fromAddress = false}) async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) {
      printLogs('error $error');
    });
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }

  packData() async {
    String style = await rootBundle.loadString(kdarkMapStyle);
    mapStyle.value = style;
    getUserLocation(fromAddress: true).then((value) async {
      printLogs('My Location');
      printLogs('${value.latitude} ${value.longitude}');
      myMarker.add(Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          markerId: const MarkerId('UserLocation'),
          position: LatLng(value.latitude, value.longitude)));
      CameraPosition cameraPosition = CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14);
      circles = <Circle>{
        Circle(
          circleId: const CircleId("id"),
          center: LatLng(value.latitude, value.longitude),
          radius: 4000,
        )
      }.obs;
      final GoogleMapController controller = await mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      currentLatLng.value = LatLng(value.latitude, value.longitude);
      selectedLatLng.value = currentLatLng.value;
    });
  }

  @override
  void onInit() {
    // TODO: implement onInit
    packData();
    super.onInit();
  }

  ////.....code for Additional Details BottomSheet.....////
  RxString currentLocationAddress = 'n/a'.obs;
  Rx<LatLng?> currentLatLng = Rx<LatLng?>(null);
  Rx<LatLng?> selectedLatLng = Rx<LatLng?>(null);
  //fn for getting address from latlng
  Future<void> getAddressFromLatLng() async {
    if (selectedLatLng.value != null) {
      await GeoServices.getAddress(selectedLatLng.value!.latitude, selectedLatLng.value!.longitude).then((value) {
        currentLocationAddress.value = value;
        address.value = value;
      });
    } else {
      if (currentLatLng.value == null) {
        await getUserLocation(fromAddress: true).then((value) => currentLatLng.value = LatLng(value.latitude, value.longitude));
      }
      GeoServices.getAddress(currentLatLng.value!.latitude, currentLatLng.value!.longitude).then((value) {
        currentLocationAddress.value = value;
      });
    }
  }

  ////.....code for updating postition through changed location.....////
  RxString address = ''.obs;
  Future<void> updatePosition(LatLng latLng) async {
    myMarker.clear();
    myMarker.add(
        Marker(icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), markerId: const MarkerId('UserLocation'), position: latLng));
    selectedLatLng.value = latLng;
    currentLatLng.value = latLng;
    mapController.future.then((value) {
      value.animateCamera(CameraUpdate.newLatLng(latLng));
    });
    await getAddressFromLatLng();
    printLogs('address to search field ${searchController.text}');
    searchController.text = address.value;
  }

  // fn to get place api suggestions
  RxList<String> suggestions = <String>[].obs;
  Future<List<String>?> fetchSuggestions(String input) async {
    Get.log("location search............ $input");
    suggestions.clear();
    GeoServices.fetchSuggestions(input).then((value) {
      suggestions.addAll(value);
    }).onError((error, stackTrace) {
      CustomSnackbar.showSnackbar('Error fetching suggestions');
    });
    return suggestions;
  }

// fn when selects any suggestions
  Future<void> onSuggestionSelected(String suggestion) async {
    final LatLng location = await getLatLngFromPlace(suggestion);
    await updatePosition(location);

    // searchController.clear();
    suggestions.clear();
  }

  Future<LatLng> getLatLngFromPlace(String place) async {
    return GeoServices.getLatLngFromPlace(place);
  }
}
