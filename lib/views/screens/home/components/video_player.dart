import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/services/custom_snackbar.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_colors.dart';
import 'package:socials_app/utils/app_dialogs.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/views/custom_widgets/CustomImage.dart';
import 'package:socials_app/views/custom_widgets/custom_textfield.dart';
import 'package:socials_app/views/custom_widgets/user_follow_row.dart';
import 'package:socials_app/views/custom_widgets/viewedby.dart';
import 'package:socials_app/views/screens/home/components/reasons_bottom_modal.dart';
import 'package:socials_app/views/screens/home/components/video_reaction_bar.dart';

import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';
import '../controller/home_controller.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final HomeScreenController homeController;
  // final Rx<CachedVideoPlayerPlusController> videoController;
  final PostModel post;
  final int index;
  final bool isFollowed;
  final VoidCallback onFollowButtonTap;
  final String? btnText;
  final VoidCallback onProfileTap;
  final String followedUserId;
  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.homeController,
    // required this.videoController,
    required this.post,
    required this.index,
    required this.isFollowed,
    required this.onFollowButtonTap,
    this.btnText,
    required this.onProfileTap,
    required this.followedUserId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  void initState() {
    super.initState();
    printLogs('=============index in video player init ${widget.index}');
// Ensure controllers are initialized before accessing
//     if (widget.homeController.videoControllers.isEmpty) {
//       return;
//     }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.index == 0) {
        widget.homeController.videoControllers[widget.index].value.controller.setLooping(true);
        await widget.homeController.videoControllers[widget.index].value.controller.play();
        widget.homeController.isPlaying.value = true;
      }

      // widget.homeController.videoControllers[widget.index].value
      //     .initialize()
      //     .then((_) {
      //   setState(() {});
      // });
    });
    listener();
  }

  void listener() {
    printLogs('=============index in VideoPlayer listener ${widget.index}');
    printLogs('=============index in post  contorller length ${widget.homeController.posts.length}');
    printLogs('=============index in VideoPlayer listener contorller length ${widget.homeController.videoControllers.length}');
    printLogs(
        "=======VideoPlayer listener widget.homeController.videoControllers[widget.index].value.controller.value.size.width ${widget.homeController.videoControllers[widget.index].value.controller.value.size.width}");
    printLogs(
        "=======VideoPlayer listener widget.homeController.videoControllers[widget.index].value.controller.value.size.height ${widget.homeController.videoControllers[widget.index].value.controller.value.size.height}");
    // if (widget.index >= widget.homeController.videoControllers.length) {
    //   printLogs('Invalid index or controllers not initialized');
    //   return;
    // }

    try {
      widget.homeController.videoControllers[widget.index].value.controller.addListener(() {});
    } catch (e) {
      widget.homeController.onInit();
      printLogs("=============VideoPlayer listener exception $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: widget.homeController.videoControllers[widget.index].value.controller.value.size.width,
        height: widget.homeController.videoControllers[widget.index].value.controller.value.size.height,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              // Obx(() =>
              // widget.homeController.moreLoading.value
              //     ? Center(
              //         child: ModalProgressHUD(
              //         inAsyncCall: widget.homeController.moreLoading.value,
              //         child: SizedBox(
              //           height: Get.height,
              //           width: Get.width,
              //           child: CachedImage(
              //             isCircle: false,
              //             url: widget.post.thumbnail ?? '',
              //             height: Get.height,
              //             width: Get.width,
              //           ),
              //         ),
              //       ))
              //     :
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Obx(() => ClipRRect(
                        borderRadius: BorderRadius.circular(18.0),
                        child: SizedBox(
                          width: widget.homeController.videoControllers[widget.index].value.controller.value.size.width,
                          height: widget.homeController.videoControllers[widget.index].value.controller.value.size.height,
                          child: AspectRatio(
                            aspectRatio: widget.homeController.videoControllers[widget.index].value.controller.value.aspectRatio,
                            child: GestureDetector(
                              onTap: () {
                                printLogs('Video Tapped');
                                if (widget.homeController.videoControllers[widget.index].value.controller.value.isPlaying) {
                                  widget.homeController.videoControllers[widget.index].value.controller.pause();
                                  widget.homeController.isPlaying.value = false;
                                }
                                widget.homeController.videoControllers[widget.index].refresh();
                              },
                              child: VideoPlayer(widget.homeController.videoControllers[widget.index].value.controller),
                            ),
                          ),
                        ),
                      )),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.homeController.videoControllers[widget.index].value.controller.value.isPlaying) {
                    widget.homeController.videoControllers[widget.index].value.controller.pause();
                    widget.homeController.isPlaying.value = false;
                  } else {
                    widget.homeController.videoControllers[widget.index].value.controller.setVolume(1.0);
                    widget.homeController.videoControllers[widget.index].value.controller.setLooping(true);
                    widget.homeController.videoControllers[widget.index].value.controller.play();
                    widget.homeController.isPlaying.value = true;
                  }
                  widget.homeController.videoControllers[widget.index].refresh();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    margin: EdgeInsets.only(
                      top: 16.0,
                      right: 4,
                    ),
                    padding: const EdgeInsets.only(top: 2.0, right: 4, left: 4, bottom: 2),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      color: kPrimaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.homeController.videoControllers[widget.index].value.controller.value.isPlaying) {
                    widget.homeController.videoControllers[widget.index].value.controller.pause();
                    widget.homeController.isPlaying.value = false;
                  } else {
                    widget.homeController.videoControllers[widget.index].value.controller.setVolume(1.0);
                    widget.homeController.videoControllers[widget.index].value.controller.setLooping(true);
                    widget.homeController.videoControllers[widget.index].value.controller.play();
                    widget.homeController.isPlaying.value = true;
                  }
                  widget.homeController.videoControllers[widget.index].refresh();
                },
                child: Obx(() => Visibility(
                      visible: !widget.homeController.isPlaying.value,
                      child: Center(
                        child: Image.asset(
                          kplayButton,
                          width: 50.w,
                          height: 50.h,
                        ),
                      ),
                    )),
              ),
              Obx(
                () => Visibility(
                  visible: true,
                  child: Stack(children: [
                    Positioned(
                      left: 8.w,
                      bottom: 110.h,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: CachedImage(
                              url: widget.homeController.posts[widget.index].userId.image ?? '',
                              isCircle: true,
                              height: 30.h,
                              width: 30.w,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: widget.onProfileTap,
                            child: Text(
                              widget.post.userId.name,
                              style: AppStyles.labelTextStyle()
                                  .copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ),

                          /// 4 hours ago
                          const SizedBox(width: 8),
                          Text(
                            widget.homeController.posts[widget.index].date != null
                                ? (DateTime.now().difference(widget.homeController.posts[widget.index].date!).inMinutes < 60
                                    ? '${(DateTime.now().difference(widget.homeController.posts[widget.index].date!).inMinutes).abs()}m'
                                    : (DateTime.now().difference(widget.homeController.posts[widget.index].date!).inHours < 24
                                        ? '${(DateTime.now().difference(widget.homeController.posts[widget.index].date!).inHours).abs()}h'
                                        : '${(DateTime.now().difference(widget.homeController.posts[widget.index].date!).inDays).abs()}d'))
                                : 'h',
                            style: AppStyles.labelTextStyle()
                                .copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 10),

                          /// follow button
                          GestureDetector(
                            onTap: () {
                              if (widget.homeController.isFollowStatusLoading.value) {
                                return;
                              }
                              widget.onFollowButtonTap();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              decoration: BoxDecoration(
                                  color: SessionService().isFollowingById(widget.followedUserId) ? kPrimaryColor : kBlackColor.withAlpha(70),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: SessionService().isFollowingById(widget.followedUserId) ? Colors.transparent : kPrimaryColor,
                                    width: 0.5,
                                  )),
                              child: Obx(
                                () => widget.homeController.isFollowStatusLoading.isTrue
                                    ? Center(
                                        child: Text(
                                          SessionService().isFollowingById(widget.followedUserId) ? 'Following' : widget.btnText ?? 'Follow',
                                          style: AppStyles.labelTextStyle().copyWith(
                                              fontSize: 12.sp,
                                              color: SessionService().isFollowingById(widget.followedUserId) ? kBlackColor : kPrimaryColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          SessionService().isFollowingById(widget.followedUserId) ? 'Following' : widget.btnText ?? 'Follow',
                                          style: AppStyles.labelTextStyle().copyWith(
                                              fontSize: 12.sp,
                                              color: SessionService().isFollowingById(widget.followedUserId) ? kBlackColor : kPrimaryColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// removed as suggested by Dave
                    /*Positioned(
                      // left: 0.w,
                      bottom: 115.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          !widget.homeController.isPlaying.value && !widget.homeController.moreLoading.value
                              ? Container(
                                  padding: const EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
                                  child: Text(
                                    widget.homeController.posts[widget.index].area ?? '',
                                    style: AppStyles.labelTextStyle()
                                        .copyWith(fontSize: 16.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                                  ),
                                )
                              : SizedBox.shrink(),

                          /// like and viewed by

                          if (widget.homeController.posts[widget.index].views != null &&
                              widget.homeController.posts[widget.index].views?.isNotEmpty == true)
                            Container(
                              padding: const EdgeInsets.only(left: 8, right: 18, top: 0, bottom: 0),
                              child: Text(
                                "Liked and Viewed by ${widget.homeController.posts[widget.index].views?.first.name} and ${(widget.homeController.posts[widget.index].views?.length ?? 1) - 1}+ broadcasters",
                                style: AppStyles.labelTextStyle()
                                    .copyWith(fontSize: 14.sp, color: kWhiteColor, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                              ),
                            ),
                        ],
                      ),
                    ),*/
                  ]),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 0,
                child: Obx(
                  () => ValueListenableBuilder(
                    valueListenable: widget.homeController.videoControllers[widget.index].value.controller,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: widget.homeController.videoControllers[widget.index].value.controller.value.duration.inMilliseconds != 0.0
                            ? (widget.homeController.videoControllers[widget.index].value.controller.value.position.inMilliseconds /
                                widget.homeController.videoControllers[widget.index].value.controller.value.duration.inMilliseconds)
                            : 0.0,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      );
                    },
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: !widget.homeController.isPlaying.value && !widget.homeController.moreLoading.value,
                  child: Positioned(
                    right: 5,
                    bottom: 160,
                    child: VideoReactionsBar(
                      controller: widget.homeController,
                      index: widget.index,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 8.w,
                bottom: 40.h,
                child: ViewedBy(
                  viewedBy: widget.homeController.posts[widget.index].views ?? [],
                  onTap: () {
                    widget.homeController.onTapPost(widget.homeController.tappedPostIndex.value);
                    widget.homeController.getUsersFromPostId(widget.homeController.posts[widget.index].id);
                    // widget.homeController.getUsersFromIds(widget.homeController.posts[widget.index].views!.map((e) => e.id).toList());
                    showModalBottomSheet(
                        context: context,
                        backgroundColor: kBackgroundColor,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.7,
                            child: SizedBox(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                                child: Obx(
                                  () => widget.homeController.isViewedUsersLoading.value
                                      ? const Center(child: CircularProgressIndicator())
                                      : Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                'Plays and Reaction',
                                                style: AppStyles.labelTextStyle().copyWith(
                                                  color: Colors.white,
                                                  fontSize: 18.sp,
                                                  fontFamily: 'League Spartan',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20.h),
                                            CustomTextField(
                                              isPassword: false,
                                              hint: "Search",
                                              controller: widget.homeController.searchController,
                                              icon: Icons.search,
                                              onChanged: (value) {
                                                widget.homeController.filterBottomSheetSearch(value);
                                              },
                                            ),
                                            SizedBox(height: 20.h),
                                            Center(
                                              child: SizedBox(
                                                width: Get.width,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      kVideoImage,
                                                      color: kWhiteColor,
                                                      scale: 5.0,
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Text(
                                                      ' ${widget.homeController.posts[widget.index].views?.length} plays',
                                                      style: AppStyles.labelTextStyle().copyWith(fontSize: 14.sp, fontWeight: FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20.h),
                                            SizedBox(
                                              width: Get.width,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Liked by',
                                                    style: AppStyles.labelTextStyle().copyWith(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                  Text(
                                                    ' ${widget.homeController.posts[widget.index].likesCount} likes',
                                                    style: AppStyles.labelTextStyle().copyWith(
                                                      color: kGreyRecentSearch,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 20.h),
                                            Expanded(
                                              child: Obx(() => widget.homeController.searchBottomSheetList.isEmpty
                                                  ? Center(
                                                      child: Text('No Viewer Found',
                                                          style: AppStyles.labelTextStyle().copyWith(
                                                            color: kGreyRecentSearch,
                                                            fontSize: 14.sp,
                                                            fontWeight: FontWeight.w400,
                                                          )))
                                                  : ListView.builder(
                                                      itemCount: widget.homeController.searchBottomSheetList.length,
                                                      itemBuilder: (context, index) {
                                                        final user = widget.homeController.searchBottomSheetList[index];
                                                        bool isFollowed = widget.homeController.searchBottomSheetList[index].followers
                                                            .contains(SessionService().user?.id);

                                                        return Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: Obx(
                                                            () => UserFollowRow(
                                                              onProfileTap: () {
                                                                Get.back();
                                                                widget.homeController.onOtherUserView(user.id);
                                                              },
                                                              name: user.name,
                                                              imageUrl: user.image ?? '',
                                                              isFollowed: isFollowed.obs,
                                                              isFollowLoading: widget.homeController.followLoadingMap[user.id] ?? false.obs,
                                                              btnText: isFollowed ? 'Following' : 'Follow',
                                                              onTap: () {
                                                                widget.homeController.updateFollowStatus(
                                                                    followedUserId: user.id, index: index, isFromBottomSheet: true);
                                                              },
                                                              onBlockTap: () {
                                                                printLogs('on reasons lst === ${widget.homeController.blockingReasons}');
                                                                widget.homeController.isRatingTapped.value = false;
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => Obx(
                                                                    () => ReasonBottomSheet(
                                                                      titleText: 'Block User',
                                                                      reasons: widget.homeController.blockingReasons,
                                                                      onCloseButton: () {
                                                                        widget.homeController.selectedReason.value = 'Select Reason';
                                                                        Get.back();
                                                                      },
                                                                      onButtonTap: () {
                                                                        if (widget.homeController.selectedReason.value != "Select Reason") {
                                                                          AppDialogs().showBlockUserConfirmationDialog(onPressed: () async {
                                                                            Get.back();
                                                                            await widget.homeController.blockUser(
                                                                                blockedUserId: user.id,
                                                                                reason: widget.homeController.selectedReason.value);
                                                                          });
                                                                        } else {
                                                                          CustomSnackbar.showSnackbar("Select reason");
                                                                        }
                                                                      },
                                                                      onChange: widget.homeController.onReasonDropDownChange,
                                                                      selectedReason: widget.homeController.selectedReason.value,
                                                                      btnText: 'Block',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          );
                        }).then((ab) {
                      widget.homeController.searchController.clear();
                    });
                  },
                ),
              ),
              Positioned(
                right: 55,

                // top: 100,
                bottom: 320,
                child: Obx(() => Visibility(
                    visible: widget.homeController.isRatingTapped.value,
                    child: Container(
                      width: 270.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Obx(
                        () => StarRating(
                          rating: widget.homeController.ratingValue.value.toDouble(),
                          starCount: 5,
                          size: 50.0,
                          allowHalfRating: false,
                          filledIcon: Icons.star,
                          halfFilledIcon: Icons.star_half,
                          emptyIcon: Icons.star_border,
                          color: kPrimaryColor,
                          borderColor: Colors.grey,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          onRatingChanged: (rating) async {
                            printLogs("rating ${widget.index}");
                            await widget.homeController.setRating(rating, widget.index);
                            widget.homeController.isRatingTapped.value = false;
                          },
                        ),
                      ),
                    ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
