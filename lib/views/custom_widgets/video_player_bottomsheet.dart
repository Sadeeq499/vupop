import 'dart:developer';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/custom_widgets/CustomImage.dart';
import 'package:socials_app/views/screens/archive/controller/archive_controller.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';
import 'package:socials_app/views/screens/followers_profile_screen/controller/followers_profile_controller.dart';

import '../../utils/app_styles.dart';
import 'sharing_icon.dart';
import 'viewedby.dart';

class VideoPlayerBottomSheet extends StatelessWidget {
  VideoPlayerBottomSheet(
      {super.key,
      required this.videoController,
      required this.post,
      required this.likeDislikeTapped,
      required this.ratingTapped,
      required this.shareTapped,
      required this.reportTapped,
      required this.progress,
      required this.ratings,
      required this.isRatingTapped,
      required this.onRatingChanged,
      required this.userRating,
      required this.uploadedUserPic,
      required this.uploadedUserName,
      this.isBottomSheet = true,
      this.isCloseIconVisible = true,
      this.onViewTapped,
      this.isRatingDisabled = false,
      this.isLikeDisabled = false,
      required this.ratingDisappear,
      required this.onFollowButtonTap,
      required this.isFollowed,
      this.isProfileView = false,
      required this.onDownloadClick,
      required this.isDowloadButtonShow,
      required this.blockUserTapped,
      required this.isPlaying,
      required this.onPlayButtonTap,
      required this.onProfileTap,
      required this.followedUserId,
      this.discoverController,
      this.followersProfileController,
      this.isOwnPost = false,
      this.index = 0,
      this.archiveController});
  // final VideoPlayerController videoController;
  final CachedVideoPlayerPlus videoController;
  final PostModel post;
  final VoidCallback likeDislikeTapped;
  final VoidCallback ratingTapped;
  final VoidCallback shareTapped;
  final VoidCallback reportTapped;
  final double progress;
  final double ratings;
  final bool isRatingTapped;
  final Function(double) onRatingChanged;
  final double userRating;
  final bool isBottomSheet;
  final bool isCloseIconVisible;
  final VoidCallback? onViewTapped;
  final String uploadedUserPic;
  final String uploadedUserName;
  final bool isRatingDisabled;
  final bool isLikeDisabled;
  final Function(bool value) ratingDisappear;
  final bool isFollowed;
  final String? btnText = 'Follow';
  final VoidCallback onFollowButtonTap;
  final bool isProfileView;
  final VoidCallback onDownloadClick;
  final bool isDowloadButtonShow;
  final VoidCallback blockUserTapped;
  final bool isPlaying;
  final bool isOwnPost;
  final Function(bool value) onPlayButtonTap;
  final VoidCallback onProfileTap;
  final String followedUserId;
  DiscoverController? discoverController;
  FollowersProfileController? followersProfileController;
  final ArchiveController? archiveController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return isBottomSheet
        ? FractionallySizedBox(
            heightFactor: 1.0,
            widthFactor: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: kHintGreyColor,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: _mainWidgets(context),
            ),
          )
        : _mainWidgets(context);
  }

  _mainWidgets(BuildContext context) {
    //TODO: comment it back if doesnt work
    // printLogs("videoController.value.size.width, ${videoController.value.size.width}");
    // printLogs("videoController.value.size.height, ${videoController.value.size.height}");
    // printLogs('=========videoController.value.isPlaying ${videoController.value.isPlaying}');
    // if (videoController.value.isInitialized && !videoController.value.isPlaying) {
    //   videoController.play();
    // }
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: videoController.controller.value.size.width,
                height: videoController.controller.value.size.height,
                child: GestureDetector(
                  onTap: () {
                    if (videoController.controller.value.isPlaying) {
                      videoController.controller.pause();
                      onPlayButtonTap(false);
                    } else {}
                    ratingDisappear(false);
                  },
                  child: SizedBox(
                    width: videoController.controller.value.size.width,
                    height: videoController.controller.value.size.height,
                    child: AspectRatio(
                      aspectRatio: videoController.controller.value.aspectRatio,
                      // child: VideoPlayer(videoController),
                      child: VideoPlayer(videoController.controller),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            if (videoController.controller.value.isPlaying) {
              videoController.controller.pause();
              onPlayButtonTap(false);
            } else {
              videoController.controller.setVolume(1.0);
              videoController.controller.setLooping(true);
              videoController.controller.play();
              onPlayButtonTap(true);
            }

            ratingDisappear(false);
          },
          child: Visibility(
            visible: !isPlaying,
            child: Center(
              child: Image.asset(
                kplayButton,
                width: 50.w,
                height: 50.h,
              ),
            ),
          ),
        ),

        Positioned(
          top: 2,
          left: 20,
          right: 20,
          child: ValueListenableBuilder(
            valueListenable: videoController.controller,
            builder: (context, value, child) {
              final duration = value.duration.inMilliseconds;
              final position = value.position.inMilliseconds;
              final progress = duration > 0 ? position / duration : 0.0;
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
              );
            },
          ),
        ),
        Visibility(
          visible: true,
          child: Stack(children: [
            Positioned(
              left: 8,
              bottom: 130,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onProfileTap,
                    child: CachedImage(
                      url: uploadedUserPic,
                      isCircle: true,
                      height: 30.h,
                      width: 30.w,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: Text(
                      uploadedUserName,
                      style:
                          AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ),

                  /// 4 hours ago
                  const SizedBox(width: 8),
                  Text(
                    post.date != null
                        ? (DateTime.now().difference(post.date!).inMinutes < 60
                            ? '${(DateTime.now().difference(post.date!).inMinutes).abs()}m'
                            : DateTime.now().difference(post.date!).inHours < 24
                                ? '${(DateTime.now().difference(post.date!).inHours).abs()}h'
                                : '${(DateTime.now().difference(post.date!).inDays).abs()}d')
                        : 'h',
                    style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(width: 10),

                  /// follow button
                  Visibility(
                    visible: !isOwnPost,
                    child: GestureDetector(
                      onTap: () {
                        if (discoverController != null && discoverController!.isFollowStatusLoading.value) {
                          return;
                        } else if (followersProfileController != null && followersProfileController!.isFollowStatusLoading.value) {
                          return;
                        }
                        onFollowButtonTap();
                      },
                      child: discoverController != null || followersProfileController != null
                          ? Obx(
                              () => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                    color: SessionService().isFollowingById(followedUserId) ? kPrimaryColor : kBlackColor.withAlpha(70),
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: SessionService().isFollowingById(followedUserId) ? Colors.transparent : kPrimaryColor,
                                      width: 0.5,
                                    )),
                                child: (discoverController != null && discoverController!.isFollowStatusLoading.isTrue) ||
                                        (followersProfileController != null && followersProfileController!.isFollowStatusLoading.isTrue)
                                    ? Center(
                                        child: Text(
                                          SessionService().isFollowingById(followedUserId) ? 'Following' : btnText ?? 'Follow',
                                          style: AppStyles.labelTextStyle().copyWith(
                                              fontSize: 12.sp,
                                              color: SessionService().isFollowingById(followedUserId) ? kBlackColor : kPrimaryColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          SessionService().isFollowingById(followedUserId) ? 'Following' : btnText ?? 'Follow',
                                          style: AppStyles.labelTextStyle().copyWith(
                                              fontSize: 12.sp,
                                              color: SessionService().isFollowingById(followedUserId) ? kBlackColor : kPrimaryColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                  color: SessionService().isFollowingById(followedUserId) ? kPrimaryColor : kBlackColor.withAlpha(70),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: SessionService().isFollowingById(followedUserId) ? Colors.transparent : kPrimaryColor,
                                    width: 0.5,
                                  )),
                              child: (discoverController != null && discoverController!.isFollowStatusLoading.isTrue) ||
                                      (followersProfileController != null && followersProfileController!.isFollowStatusLoading.isTrue)
                                  ? Center(
                                      child: Text(
                                        SessionService().isFollowingById(followedUserId) ? 'Following' : btnText ?? 'Follow',
                                        style: AppStyles.labelTextStyle().copyWith(
                                            fontSize: 12.sp,
                                            color: SessionService().isFollowingById(followedUserId) ? kBlackColor : kPrimaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        SessionService().isFollowingById(followedUserId) ? 'Following' : btnText ?? 'Follow',
                                        style: AppStyles.labelTextStyle().copyWith(
                                            fontSize: 12.sp,
                                            color: SessionService().isFollowingById(followedUserId) ? kBlackColor : kPrimaryColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
        Stack(
          children: [
            Visibility(
              visible: !isPlaying,
              child: Positioned(
                right: 120,
                bottom: 380,
                child: Visibility(
                  visible: isRatingTapped,
                  child: Container(
                    width: 300.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: StarRating(
                      rating: userRating,
                      starCount: 5,
                      size: 50.0,
                      allowHalfRating: false,
                      filledIcon: Icons.star,
                      halfFilledIcon: Icons.star_half,
                      emptyIcon: Icons.star_border,
                      color: kPrimaryColor,
                      borderColor: Colors.grey,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      onRatingChanged: onRatingChanged,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !isPlaying,
              child: Positioned(
                right: 5,
                bottom: 280,
                child: Container(
                  width: 50.w,
                  height: Get.height * 0.33,
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
                  decoration: ShapeDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: SharingIcon(
                            iconPath: kLikeIcon,
                            text: post.likesCount.toString(),
                            isTapped: post.likes.contains(SessionService().user?.id ?? ''),
                            onTap:
                                likeDislikeTapped /*() {
                                  ratingDisappear(false);
                                  likeDislikeTapped;
                                },*/
                            ),
                      ),
                      Expanded(
                        child: SharingIcon(
                          iconPath: kRatingStar,
                          text: post.averageRating.toDouble().toStringAsFixed(1),
                          onTap: ratingTapped,
                        ),
                      ),
                      Expanded(
                        child: SharingIcon(
                          iconPath: kSendIcon,
                          text: post.share.length.toString(),
                          onTap: shareTapped,
                        ),
                      ),
                      Expanded(
                        child: SharingIcon(
                          iconPath: kReportClip,
                          text: '',
                          onTap: reportTapped,
                        ),
                      ),
                      Visibility(
                        visible: !isProfileView,
                        child: Expanded(
                          child: SharingIcon(
                            iconPath: kBlockUser,
                            text: '',
                            onTap: blockUserTapped,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        /// highlight caption

        Positioned(
          left: 5,
          bottom: 60,
          child: GestureDetector(
            onTap: () {
              if (videoController.controller.value.isPlaying) {
                videoController.controller.pause();
              }
              onViewTapped?.call();
              ratingDisappear(false);
            },
            child: ViewedBy(
              viewedBy: post.views ?? [],
              onTap: onViewTapped,
            ),
          ),
        ),

        /// close icon
        Positioned(
          top: -10,
          right: 0,
          child: Visibility(
            visible: isCloseIconVisible,
            child: GestureDetector(
              onTap: () {
                log("Close Icon Tapped");
                onPlayButtonTap(true);
                videoController.controller.pause();
                Navigator.of(context).pop();
                videoController.dispose();
              },
              child: Image.asset(
                kCloseIcon,
                width: 30.w,
                height: 30.h,
              ),
            ),
          ),
        ),

        /// User Image and name

        /// download icon
        Visibility(
          visible: isDowloadButtonShow,
          child: Obx(
            () => Positioned(
              top: 40,
              right: 10,
              child: archiveController?.isPostDownloading[index].value == true
                  ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24.w,
                            height: 24.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: archiveController!.downloadProgress[index].value / 100,
                                  valueColor: AlwaysStoppedAnimation(kPrimaryColor),
                                  strokeWidth: 2.0,
                                  backgroundColor: Colors.grey.withOpacity(0.3),
                                ),
                                Text(
                                  "${archiveController?.downloadProgress[index].value.toInt()}%",
                                  style: TextStyle(
                                    color: kWhiteColor,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GestureDetector(
                      onTap: onDownloadClick,
                      child: Image.asset(kdownloadIcon, fit: BoxFit.fill),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// class VideoPlayerBottomSheet extends StatelessWidget {
//   const VideoPlayerBottomSheet({
//     super.key,
//     required this.videoController,
//     required this.post,
//     required this.likeDislikeTapped,
//     required this.ratingTapped,
//     required this.shareTapped,
//     required this.reportTapped,
//     required this.progress,
//     required this.ratings,
//     required this.isRatingTapped,
//     required this.onRatingChanged,
//     required this.userRating,
//     required this.uploadedUserPic,
//     required this.uploadedUserName,
//     this.isBottomSheet = true,
//     this.isCloseIconVisible = true,
//     this.onViewTapped,
//     this.isRatingDisabled = false,
//     this.isLikeDisabled = false,
//     required this.ratingDisappear,
//     required this.onFollowButtonTap,
//     required this.isFollowed,
//     this.isProfileView = false,
//     required this.onDownloadClick,
//     required this.isDowloadButtonShow,
//     required this.blockUserTapped,
//   });
//   final CachedVideoPlayerPlusController videoController;
//   final PostModel post;
//   final VoidCallback likeDislikeTapped;
//   final VoidCallback ratingTapped;
//   final VoidCallback shareTapped;
//   final VoidCallback reportTapped;
//   final double progress;
//   final double ratings;
//   final bool isRatingTapped;
//   final Function(double) onRatingChanged;
//   final double userRating;
//   final bool isBottomSheet;
//   final bool isCloseIconVisible;
//   final VoidCallback? onViewTapped;
//   final String uploadedUserPic;
//   final String uploadedUserName;
//   final bool isRatingDisabled;
//   final bool isLikeDisabled;
//   final Function(bool value) ratingDisappear;
//   final bool isFollowed;
//   final String? btnText = 'Follow';
//   final VoidCallback onFollowButtonTap;
//   final bool isProfileView;
//   final VoidCallback onDownloadClick;
//   final bool isDowloadButtonShow;
//   final VoidCallback blockUserTapped;

//   @override
//   Widget build(BuildContext context) {
//     return isBottomSheet
//         ? FractionallySizedBox(
//             heightFactor: 0.9,
//             widthFactor: 1.0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: kHintGreyColor,
//                 borderRadius: BorderRadius.circular(30.r),
//               ),
//               child: _mainWidgets(context),
//             ),
//           )
//         : _mainWidgets(context);
//   }

//   _mainWidgets(BuildContext context) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         Center(
//           child: FittedBox(
//             fit: BoxFit.contain,
//             child: SizedBox(
//               width: videoController.value.size.width,
//               height: videoController.value.size.height,
//               child: GestureDetector(
//                 onTap: () {
//                   if (videoController.value.isPlaying) {
//                     videoController.pause();
//                   } else {
//                     videoController.play();
//                   }
//                   ratingDisappear(false);
//                 },
//                 child: SizedBox(
//                   width: videoController.value.size.width,
//                   height: videoController.value.size.height,
//                   child: AspectRatio(
//                     aspectRatio: videoController.value.aspectRatio,
//                     child: CachedVideoPlayerPlus(videoController),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // Positioned(
//         //     top: 28,
//         //     right: 20,
//         //     child: GestureDetector(
//         //         onTap: onFollowButtonTap,
//         //         child: Container(
//         //           padding:
//         //               const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//         //           decoration: BoxDecoration(
//         //               color: isFollowed
//         //                   ? kPrimaryColor
//         //                   : kBlackColor.withAlpha(70),
//         //               borderRadius: BorderRadius.circular(10.r),
//         //               border: Border.all(
//         //                 color: isFollowed ? Colors.transparent : kPrimaryColor,
//         //                 width: 1,
//         //               )),
//         //           child: Center(
//         //             child: Text(
//         //               isFollowed ? 'Following' : btnText ?? 'Follow',
//         //               style: AppStyles.labelTextStyle().copyWith(
//         //                   fontSize: 14.sp,
//         //                   color: isFollowed ? kBlackColor : kPrimaryColor,
//         //                   fontWeight: FontWeight.w700),
//         //             ),
//         //           ),
//         //         ))),

//         Positioned(
//             top: 2,
//             left: 20,
//             right: 20,
//             // bottom: 0,
//             child: LinearProgressIndicator(
//               value: videoController.value.duration.inMilliseconds != 0.0
//                   ? (videoController.value.position.inMilliseconds / videoController.value.duration.inMilliseconds)
//                   : 0.0,
//               backgroundColor: Colors.transparent,
//               valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
//             )),
//         Positioned(
//           right: 120,
//           bottom: 380,
//           child: Visibility(
//             visible: isRatingTapped,
//             child: Container(
//               width: 300.w,
//               height: 90.h,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: StarRating(
//                 rating: userRating,
//                 starCount: 5,
//                 size: 50.0,
//                 allowHalfRating: false,
//                 filledIcon: Icons.star,
//                 halfFilledIcon: Icons.star_half,
//                 emptyIcon: Icons.star_border,
//                 color: kPrimaryColor,
//                 borderColor: Colors.grey,
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 onRatingChanged: onRatingChanged,
//               ),
//             ),
//           ),
//         ),
//         Positioned(
//           right: 5,
//           bottom: 280,
//           child: Container(
//             width: 50.w,
//             height: Get.height * 0.33,
//             padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
//             decoration: ShapeDecoration(
//               color: Colors.black.withOpacity(0.3),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: SharingIcon(
//                       iconPath: kLikeIcon,
//                       text: post.likesCount.toString(),
//                       isTapped: post.likes.contains(SessionService().user?.id ?? ''),
//                       onTap:
//                           likeDislikeTapped /*() {
//                                 ratingDisappear(false);
//                                 likeDislikeTapped;
//                               },*/
//                       ),
//                 ),
//                 Expanded(
//                   child: SharingIcon(
//                     iconPath: kRatingStar,
//                     text: post.averageRating.toDouble().toStringAsFixed(1),
//                     onTap: ratingTapped,
//                   ),
//                 ),
//                 Expanded(
//                   child: SharingIcon(
//                     iconPath: kSendIcon,
//                     text: post.share.length.toString(),
//                     onTap: shareTapped,
//                   ),
//                 ),
//                 Expanded(
//                   child: SharingIcon(
//                     iconPath: kReportClip,
//                     text: '',
//                     onTap: reportTapped,
//                   ),
//                 ),
//                 Visibility(
//                   visible: !isProfileView,
//                   child: Expanded(
//                     child: SharingIcon(
//                       iconPath: kBlockUser,
//                       text: '',
//                       onTap: blockUserTapped,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Positioned(
//           left: 5,
//           bottom: 50,
//           child: GestureDetector(
//             onTap: () {
//               if (videoController.value.isPlaying) {
//                 videoController.pause();
//               }
//               onViewTapped?.call();
//               ratingDisappear(false);
//             },
//             child: ViewedBy(
//               viewedBy: post.views ?? [],
//               onTap: onViewTapped,
//             ),
//           ),
//         ),

//         /// close icon
//         Positioned(
//           top: -10,
//           right: 10,
//           child: Visibility(
//             visible: isCloseIconVisible,
//             child: GestureDetector(
//               onTap: () {
//                 log("Close Icon Tapped");
//                 videoController.pause();
//                 Navigator.of(context).pop();
//               },
//               child: Image.asset(
//                 kCloseIcon,
//                 width: 30.w,
//                 height: 30.h,
//               ),
//             ),
//           ),
//         ),

//         /// User Image and name
//         Positioned(
//           left: 10,
//           bottom: 150,
//           child: Row(
//             children: [
//               CachedImage(
//                 url: uploadedUserPic,
//                 isCircle: true,
//                 height: 30.h,
//                 width: 30.w,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 uploadedUserName,
//                 style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
//               ),

//               /// 4 hours ago
//               const SizedBox(width: 8),
//               Text(
//                 post.date != null
//                     ? (DateTime.now().difference(post.date!).inMinutes < 60
//                         ? '${(DateTime.now().difference(post.date!).inMinutes).abs()}m'
//                         : '${(DateTime.now().difference(post.date!).inHours).abs()}h')
//                     : 'h',
//                 style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.bold, letterSpacing: 0.5),
//               ),
//               const SizedBox(width: 10),

//               /// follow button
//               Visibility(
//                 visible: !isProfileView,
//                 child: GestureDetector(
//                   onTap: onFollowButtonTap,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                     decoration: BoxDecoration(
//                         color: isFollowed ? kPrimaryColor : kBlackColor.withAlpha(70),
//                         borderRadius: BorderRadius.circular(10.r),
//                         border: Border.all(
//                           color: isFollowed ? Colors.transparent : kPrimaryColor,
//                           width: 0.5,
//                         )),
//                     child: Center(
//                       child: Text(
//                         isFollowed ? 'Following' : btnText ?? 'Follow',
//                         style: AppStyles.labelTextStyle()
//                             .copyWith(fontSize: 12.sp, color: isFollowed ? kBlackColor : kPrimaryColor, fontWeight: FontWeight.w700),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         /// highlight caption
//         Positioned(
//           left: 0,
//           bottom: 105,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
//                 child: Text(
//                   post.area ?? '',
//                   style: AppStyles.labelTextStyle().copyWith(fontSize: 16.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
//                 ),
//               ),

//               /// like and viewed by
//               if (post.views != null && post.views?.isNotEmpty == true)
//                 Container(
//                   padding: const EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
//                   child: Text(
//                     "Liked and Viewed by ${post.views?.first.name} and ${(post.views?.length ?? 1) - 1}+ broadcasters",
//                     style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
//                   ),
//                 ),
//             ],
//           ),
//         ),

//         /// download icon
//         Visibility(
//           visible: isDowloadButtonShow,
//           child: Positioned(
//             top: 40,
//             right: 10,
//             child: GestureDetector(
//               onTap: onDownloadClick,
//               child: Image.asset(kdownloadIcon, fit: BoxFit.fill),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
