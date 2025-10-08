import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/custom_widgets/custom_scaffold.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';

import '../../../utils/common_code.dart';
import 'controller/map_controller.dart';

class SetLocationScreen extends GetView<MapController> {
  const SetLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: '',
      isFullBody: true,
      isBackIcon: false,
      appBarSize: 0,
      scaffoldKey: controller.scaffoldKey,
      body: Stack(
        children: [
          Obx(() {
            return GoogleMap(
              // Remove the manual gesture recognizer setup and use a Set literal
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
              },

              // Enable all gesture controls
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: true,

              // Keep other map properties
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              compassEnabled: true,
              indoorViewEnabled: true,

              onMapCreated: (mapController) {
                controller.googleMapController = mapController;
                controller.mapController.complete(mapController);
              },
              initialCameraPosition: controller.initialPosition,
              markers: Set<Marker>.of(controller.myMarker),
              onTap: controller.updatePosition,
              style: controller.mapStyle.value,
            );
          }),

          // Obx(() {
          //   return GoogleMap(
          //     // minMaxZoomPreference: const MinMaxZoomPreference(10, 20),
          //     gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{}
          //       ..add(Factory<HorizontalDragGestureRecognizer>(
          //           () => HorizontalDragGestureRecognizer()))
          //       ..add(
          //           Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
          //       ..add(Factory<ScaleGestureRecognizer>(
          //           () => ScaleGestureRecognizer()))
          //       ..add(
          //           Factory<TapGestureRecognizer>(() => TapGestureRecognizer()))
          //       ..add(Factory<VerticalDragGestureRecognizer>(
          //           () => VerticalDragGestureRecognizer())),
          //     // myLocationButtonEnabled: false,
          //     // myLocationEnabled: true,
          //     // zoomGesturesEnabled: true,
          //     // zoomControlsEnabled: false,
          //     // compassEnabled: false,
          //     myLocationButtonEnabled: true,
          //     myLocationEnabled: true,
          //     zoomGesturesEnabled: true,
          //     zoomControlsEnabled: true,
          //     compassEnabled: true,
          //     onCameraIdle: () {},
          //     scrollGesturesEnabled: true,
          //     indoorViewEnabled: true,
          //     onMapCreated: (mapController) {
          //       controller.googleMapController = mapController;
          //       controller.mapController.complete(mapController);
          //     },
          //     initialCameraPosition: controller.initialPosition,
          //     markers: Set<Marker>.of(controller.myMarker),
          //     onTap: controller.updatePosition,
          //   );
          // }),

          Positioned(
            top: 70,
            left: 10,
            right: 100,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Text(
                  'Set Location',
                  style: AppStyles.appBarHeadingTextStyle().copyWith(color: kPrimaryColor),
                )
              ],
            ),
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            top: 120.h,
            child: Column(
              children: [
                CustomTextField(
                  isPassword: false,
                  hint: 'Search',
                  controller: controller.searchController,
                  contentPadding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 20.w),
                  onChanged: (value) {
                    controller.fetchSuggestions(value);
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
                Obx(() {
                  return controller.suggestions.isEmpty || controller.searchController.text.trim().isEmpty
                      ? const SizedBox()
                      : Container(
                          height: 200.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: controller.suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(controller.suggestions[index]),
                                onTap: () async {
                                  controller.searchController.text = controller.suggestions[index];
                                  await controller.onSuggestionSelected(controller.suggestions[index]);
                                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                                },
                              );
                            },
                          ),
                        );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomButton(
          width: 150.w,
          height: 50.h,
          title: 'Confirm',
          onPressed: () async {
            if (controller.currentLatLng.value != null) {
              printLogs('=======controller.currentLatLng.value!.latitude ${controller.currentLatLng.value!.latitude}');
              printLogs('=======controller.currentLatLng.value!.longitude ${controller.currentLatLng.value!.longitude}');
              printLogs('=======controller.address.value ${controller.address.value}');
              Get.back(result: {
                'lat': controller.currentLatLng.value!.latitude,
                'long': controller.currentLatLng.value!.longitude,
                'address': controller.address.value
              });
            } else {
              Get.back();
            }
          },
        ),
      ),
    );
  }
}
