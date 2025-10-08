import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_styles.dart';
import 'package:socials_app/views/custom_widgets/custom_button.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';

import '../../../utils/common_code.dart';
import '../../custom_widgets/custom_scaffold.dart';

class FilterScreen extends GetView<DiscoverController> {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isLoading.value,
        child: CustomScaffold(
          className: runtimeType.toString(),
          screenName: "Filters",
          isBackIcon: true,
          isFullBody: false,
          appBarSize: 30,
          centerTitle: false,
          showAppBarBackButton: true,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: GestureDetector(
                onTap: () {
                  controller.clearFilter();
                },
                child: Text(
                  'Clear all',
                  style: AppStyles.labelTextStyle()
                      .copyWith(fontSize: 16.sp, color: kPrimaryColor, decoration: TextDecoration.underline, decorationColor: kPrimaryColor),
                ),
              ),
            )
          ],
          padding: EdgeInsets.only(left: 10.w),
          scaffoldKey: controller.scaffoldKeyFilter,
          onNotificationListener: (notificationInfo) {
            if (notificationInfo.runtimeType == UserScrollNotification) {
              CommonCode().removeTextFieldFocus();
            }
            return false;
          },
          gestureDetectorOnTap: () {
            CommonCode().removeTextFieldFocus;
            controller.isExpanded.value = false;
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: Text(
                  //     'Location',
                  //     style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  //   ),
                  // ),
                  // SizedBox(height: 10.h),
                  // Obx(() => controller.isExpanded.isFalse
                  //     ? GestureDetector(
                  //         onTap: () {
                  //           controller.isExpanded.value = !controller.isExpanded.value;
                  //         },
                  //         child: Container(
                  //           width: Get.width,
                  //           height: 36.h,
                  //           constraints: BoxConstraints(
                  //             maxWidth: Get.width * 0.85,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: kGreyContainerColor,
                  //             borderRadius: BorderRadius.circular(4.r),
                  //           ),
                  //           child: Padding(
                  //             padding: EdgeInsets.only(left: 10.h, right: 10.h),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //               children: [
                  //                 SizedBox(
                  //                   width: Get.width * 0.7,
                  //                   child: Text(
                  //                     controller.selectedLocation.value,
                  //                     style: AppStyles.labelTextStyle().copyWith(
                  //                       fontSize: 16.sp,
                  //                       color: kPrimaryColor,
                  //                       fontWeight: FontWeight.w600,
                  //                     ),
                  //                     // maxLines: 3,
                  //                     overflow: TextOverflow.ellipsis,
                  //                   ),
                  //                 ),
                  //                 Icon(
                  //                   Icons.keyboard_arrow_down,
                  //                   size: 25,
                  //                   color: kPrimaryColor,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //     : Container(
                  //         width: Get.width,
                  //         height: 480.h,
                  //         decoration: BoxDecoration(
                  //           color: kGreyContainerColor,
                  //           borderRadius: BorderRadius.circular(4.r),
                  //         ),
                  //         child: Padding(
                  //           padding: EdgeInsets.only(left: 15.w, right: 15.w),
                  //           child: Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               SizedBox(
                  //                 height: 15.h,
                  //               ),
                  //               Container(
                  //                 width: Get.width * 0.85,
                  //                 height: 50.h,
                  //                 decoration: BoxDecoration(
                  //                   borderRadius: BorderRadius.circular(4.r),
                  //                   border: Border.all(color: kPrimaryColor, width: 2.0),
                  //                 ),
                  //                 child: Row(
                  //                   children: [
                  //                     Padding(
                  //                       padding: EdgeInsets.symmetric(horizontal: 10.w),
                  //                       child: Icon(
                  //                         Icons.search,
                  //                         color: kHintGreyColor,
                  //                         size: 25,
                  //                       ),
                  //                     ),
                  //                     Expanded(
                  //                       child: TextFormField(
                  //                         controller: controller.locationSearch,
                  //                         autofocus: false,
                  //                         style: AppStyles.labelTextStyle().copyWith(
                  //                           fontSize: 14.sp,
                  //                           fontWeight: FontWeight.w500,
                  //                           color: kWhiteColor,
                  //                         ),
                  //                         onChanged: (value) {
                  //                           controller.filterLocations(value);
                  //                           controller.locationSearch.text = value;
                  //                           // controller.addRecentSearch(value);
                  //                         },
                  //                         decoration: InputDecoration(
                  //                           hintText: "Search location",
                  //                           hintStyle: AppStyles.labelTextStyle().copyWith(
                  //                             fontSize: 14.sp,
                  //                             fontWeight: FontWeight.w500,
                  //                             color: kHintGreyColor,
                  //                           ),
                  //                           border: InputBorder.none,
                  //                           contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     IconButton(
                  //                       onPressed: () => controller.sliderSwitch(),
                  //                       icon: Icon(
                  //                         Icons.filter_alt_outlined,
                  //                         color: kPrimaryColor,
                  //                         size: 25,
                  //                       ),
                  //                     ),
                  //                     GestureDetector(
                  //                       onTap: () {
                  //                         controller.locationSearch.clear();
                  //
                  //                         /// also clear the selected location
                  //                         controller.selectedLocation.value = 'Select Location';
                  //                         controller.selectedLocationName.value = '';
                  //                         controller.radius.value = 0.0;
                  //                       },
                  //                       child: Padding(
                  //                         padding: EdgeInsets.only(right: 10.w),
                  //                         child: Text(
                  //                           'Clear',
                  //                           style: AppStyles.labelTextStyle().copyWith(
                  //                             fontSize: 16.sp,
                  //                             color: kPrimaryColor,
                  //                             decoration: TextDecoration.underline,
                  //                             decorationColor: kPrimaryColor,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //               SizedBox(
                  //                 height: 15.h,
                  //               ),
                  //               Obx(() => Visibility(
                  //                   visible: controller.isFilterSLiderTapped.value,
                  //                   child: Text(
                  //                     'Select Radius',
                  //                     style: AppStyles.labelTextStyle().copyWith(
                  //                       fontSize: 16.sp,
                  //                       color: kPrimaryColor,
                  //                     ),
                  //                   ))),
                  //               Obx(
                  //                 () => Visibility(
                  //                   visible: controller.isFilterSLiderTapped.value,
                  //                   child: SliderTheme(
                  //                     data: SliderTheme.of(context).copyWith(
                  //                       thumbColor: kPrimaryColor,
                  //                       activeTrackColor: kPrimaryColor,
                  //                       inactiveTrackColor: kGreyContainerColor,
                  //                       overlayColor: kBlackColor.withOpacity(0.2),
                  //                       valueIndicatorColor: kPrimaryColor,
                  //                       valueIndicatorTextStyle: TextStyle(
                  //                         color: kBlackColor,
                  //                       ),
                  //                     ),
                  //                     child: Obx(
                  //                       () => Slider(
                  //                         inactiveColor: kWhiteColor,
                  //                         value: controller.radius.value,
                  //                         onChanged: (v) => controller.onRadiusChange(v),
                  //                         min: controller.radiusMinLimit.value,
                  //                         max: controller.radiusMaxLimit.value,
                  //                         divisions: 5,
                  //                         label: controller.radius.value < 1
                  //                             ? '${(controller.radius.value * 1000).toInt()} m'
                  //                             : '${(controller.radius.value / 1000).toStringAsFixed(1)} km',
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ),
                  //               GestureDetector(
                  //                 onTap: () {
                  //                   // controller.getLatLong();
                  //                   controller.selectedLocation.value = controller.address.value;
                  //                   controller.selectedLocationName.value = controller.address.value;
                  //                   controller.selectedLat.value = controller.lat.value;
                  //                   controller.selectedLong.value = controller.long.value;
                  //                   controller.filterPostByLocation(controller.address.value);
                  //                   controller.isExpanded.value = !controller.isExpanded.value;
                  //                 },
                  //                 child: Row(
                  //                   children: [
                  //                     Image.asset(
                  //                       kCurrentLocation,
                  //                       width: 20.w,
                  //                     ),
                  //                     SizedBox(
                  //                       width: 8.w,
                  //                     ),
                  //                     Text(
                  //                       'Use current location',
                  //                       style: AppStyles.labelTextStyle().copyWith(
                  //                         fontSize: 16.sp,
                  //                         color: kPrimaryColor,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //               ),
                  //               SizedBox(
                  //                 height: 22.h,
                  //               ),
                  //               Obx(() => controller.filteredList.isEmpty
                  //                   ? InkWell(
                  //                       onTap: () {
                  //                         controller.selectedLocation.value = controller.address.value;
                  //                         controller.selectedLocationName.value = controller.address.value;
                  //                         controller.selectedLat.value = controller.lat.value;
                  //                         controller.selectedLong.value = controller.long.value;
                  //                         controller.filterPostByLocation(controller.address.value);
                  //                         controller.isExpanded.value = !controller.isExpanded.value;
                  //                       },
                  //                       child: Text(
                  //                         'see all in ${controller.address.value}',
                  //                         style: AppStyles.labelTextStyle().copyWith(
                  //                           fontSize: 16.sp,
                  //                           color: kPrimaryColor,
                  //                         ),
                  //                       ),
                  //                     )
                  //                   : Container()),
                  //               SizedBox(
                  //                 height: 22.h,
                  //               ),
                  //               InkWell(
                  //                 onTap: () async {
                  //                   // log('Selected Location: ${controller.address.value}');
                  //
                  //                   await Get.toNamed(kSetLocationScreen)?.then((value) {
                  //                     if (value != null) {
                  //                       controller.address.value = value['address'];
                  //                       controller.lat.value = value['lat'];
                  //                       controller.long.value = value['long'];
                  //                       controller.selectedLocation.value = controller.address.value;
                  //                       controller.selectedLocationName.value = controller.address.value;
                  //                       controller.locationSearch.text = controller.address.value;
                  //                       controller.search.text = controller.address.value;
                  //                       controller.selectedLat.value = controller.lat.value;
                  //                       controller.selectedLong.value = controller.long.value;
                  //                       controller.filterPostByLocation(controller.address.value);
                  //                       controller.isExpanded.value = !controller.isExpanded.value;
                  //                     }
                  //                   });
                  //                 },
                  //                 child: Text(
                  //                   'Search Location',
                  //                   style: AppStyles.labelTextStyle().copyWith(
                  //                     fontSize: 16.sp,
                  //                     color: kPrimaryColor,
                  //                   ),
                  //                 ),
                  //               ),
                  //               Obx(() => controller.filteredList.isEmpty
                  //                   ? SizedBox(
                  //                       height: 30.h,
                  //                     )
                  //                   : Container()),
                  //               Obx(() => controller.filteredList.isEmpty
                  //                   ? Text(
                  //                       'Recent searches',
                  //                       style: AppStyles.labelTextStyle().copyWith(color: kGreyRecentSearch, fontWeight: FontWeight.w300),
                  //                     )
                  //                   : Container()),
                  //               Obx(() => controller.filteredList.isEmpty
                  //                   ? SizedBox(
                  //                       height: 14.h,
                  //                     )
                  //                   : Container()),
                  //               Obx(
                  //                 () => controller.filteredList.isEmpty
                  //                     ? controller.recentSearchList.isEmpty
                  //                         ? Text(
                  //                             'No Recent Searches',
                  //                             style: AppStyles.labelTextStyle()
                  //                                 .copyWith(color: kGreyRecentSearch, fontSize: 18.sp, fontWeight: FontWeight.w300),
                  //                           )
                  //                         : Expanded(
                  //                             child: Obx(() => ListView.builder(
                  //                                   itemCount: controller.recentSearchList.length,
                  //                                   itemBuilder: (context, index) {
                  //                                     final search = controller.recentSearchList[index];
                  //                                     return InkWell(
                  //                                       onTap: () {
                  //                                         controller.selectedLocation.value = search;
                  //                                         controller.isExpanded.value = false;
                  //                                         controller.selectedLocationName.value = search;
                  //
                  //                                         controller.filterPostByLocation(search);
                  //                                       },
                  //                                       child: SizedBox(
                  //                                         height: 50.h,
                  //                                         width: Get.width,
                  //                                         child: Row(
                  //                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                                           children: [
                  //                                             Row(
                  //                                               children: [
                  //                                                 Icon(Icons.history, color: kGreyRecentSearch),
                  //                                                 SizedBox(
                  //                                                   width: 15.w,
                  //                                                 ),
                  //                                                 Container(
                  //                                                   constraints: BoxConstraints(maxWidth: Get.width * 0.6),
                  //                                                   child: Text(
                  //                                                     search,
                  //                                                     style: AppStyles.labelTextStyle().copyWith(
                  //                                                       fontSize: 16.sp,
                  //                                                       color: kGreyRecentSearch,
                  //                                                     ),
                  //                                                     maxLines: 2,
                  //                                                     overflow: TextOverflow.ellipsis,
                  //                                                   ),
                  //                                                 ),
                  //                                               ],
                  //                                             ),
                  //                                             GestureDetector(
                  //                                               onTap: () {
                  //                                                 controller.removeRecentSearch(search);
                  //                                               },
                  //                                               child: Icon(
                  //                                                 Icons.close,
                  //                                                 color: kGreyRecentSearch,
                  //                                                 size: 20,
                  //                                               ),
                  //                                             ),
                  //                                           ],
                  //                                         ),
                  //                                       ),
                  //                                     );
                  //                                   },
                  //                                 )),
                  //                           )
                  //                     : Expanded(
                  //                         child: Obx(
                  //                           () => ListView.builder(
                  //                             shrinkWrap: true,
                  //                             itemCount: controller.filteredList.length,
                  //                             itemBuilder: (context, index) {
                  //                               final search = controller.filteredList[index];
                  //                               final query = controller.locationSearch.text;
                  //                               final start = search.toLowerCase().indexOf(query.toLowerCase());
                  //                               if (start == -1) {
                  //                                 // Handle the case where the query is not found
                  //                                 return SizedBox.shrink();
                  //                               }
                  //                               final end = start + query.length;
                  //
                  //                               return GestureDetector(
                  //                                 onTap: () {
                  //                                   controller.selectedLocation.value = search;
                  //                                   controller.isExpanded.value = false;
                  //                                   controller.selectedLocationName.value = search;
                  //
                  //                                   controller.filterPostByLocation(search);
                  //                                   controller.addRecentSearch(search);
                  //                                 },
                  //                                 child: SizedBox(
                  //                                   height: 50.h,
                  //                                   child: RichText(
                  //                                     text: TextSpan(
                  //                                       children: [
                  //                                         TextSpan(
                  //                                           text: search.substring(0, start),
                  //                                           style: AppStyles.labelTextStyle().copyWith(
                  //                                             fontSize: 16.sp,
                  //                                             color: kGreyRecentSearch,
                  //                                           ),
                  //                                         ),
                  //                                         TextSpan(
                  //                                           text: search.substring(start, end),
                  //                                           style: AppStyles.labelTextStyle().copyWith(
                  //                                             fontSize: 16.sp,
                  //                                             // color: kPrimaryColor,
                  //                                             fontWeight: FontWeight.bold,
                  //                                           ),
                  //                                         ),
                  //                                         TextSpan(
                  //                                           text: search.substring(end),
                  //                                           style: AppStyles.labelTextStyle().copyWith(
                  //                                             fontSize: 16.sp,
                  //                                             color: kGreyRecentSearch,
                  //                                           ),
                  //                                         ),
                  //                                       ],
                  //                                     ),
                  //                                   ),
                  //                                 ),
                  //                               );
                  //                             },
                  //                           ),
                  //                         ),
                  //                       ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       )),
                  // SizedBox(height: 32.h),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Hashtags',
                      style: AppStyles.labelTextStyle().copyWith(fontWeight: FontWeight.w600, fontSize: 16.sp),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Obx(
                    () => Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: controller.selectedHashtags.map((hashtag) {
                        return IntrinsicWidth(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: kGreyContainerColor,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    hashtag,
                                    style: AppStyles.labelTextStyle().copyWith(
                                      fontSize: 16.sp,
                                      color: kPrimaryColor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    controller.selectedHashtags.remove(hashtag);
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    color: kPrimaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// textfield for hashtag
                  TextFormField(
                    controller: TextEditingController(),
                    autofocus: false,
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: kWhiteColor,
                    ),
                    // onChanged: (value) => controller.searchHashTag(value),
                    onFieldSubmitted: (value) {
                      if (value.startsWith('#')) {
                        controller.selectedHashtags.addIf(!controller.selectedHashtags.contains(value), value);
                      } else {
                        controller.selectedHashtags.addIf(!controller.selectedHashtags.contains('#$value'), '#$value');
                      }

                      FocusScope.of(context).unfocus();
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please add hashtags';
                      }
                      if (value.length < 2) {
                        return 'Please add at least 2 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Add hashtags",
                      hintStyle: AppStyles.labelTextStyle().copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: kHintGreyColor,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: kHintGreyColor,
                        size: 25,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                      fillColor: kGreyContainerColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: Get.width,
                    child: const Divider(
                      color: kPrimaryColor,
                      thickness: 2,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(left: 25.w, right: 20.w, bottom: 20),
            child: CustomButton(
              width: Get.width * 0.8,
              height: 44.h,
              title: 'Apply',
              onPressed: () {
                printLogs('Selected Location: ${controller.selectedLocationName.value}');
                printLogs('Selected Hashtags: ${controller.selectedHashtags}');
                controller.filterPostByLocationAndTag(
                  controller.selectedHashtags,
                  controller.selectedLocationName.value,
                );
                // Get.back();
              },
            ),
          ),
        ),
      ),
    );
  }
}
