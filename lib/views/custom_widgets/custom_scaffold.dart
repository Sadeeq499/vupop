import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../utils/app_colors.dart';
import 'custom_app_bar_widget.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final String className;
  final String screenName;
  final int bottomBarIndex;
  final String? subScreenName;
  final Function? onWillPop, gestureDetectorOnTap, gestureDetectorOnPanDown, onNotificationListener;
  VoidCallback? onBackButtonPressed;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget? gridview;
  final bool isBackIcon;
  bool showAppBarProfile = false;
  bool showAppBarBackButton = false;
  bool showActionButton = false;
  bool isFullBody = false;
  bool? centerTitle;
  double? appBarSize;
  Widget? bottomNavigationBar;
  Widget? title;
  Widget? leadingWidget;
  List<PopupMenuItem<int>> listOfPopupMenuItems = [];
  List<Widget>? actions = [];
  Widget? floatingActionButton;
  double leadingWidth = 70;
  Color? backIconColor;
  EdgeInsets padding = EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0);
  Widget? drawer;
  final Function? openDrawerCallback;
  CustomScaffold({
    required this.className,
    this.isBackIcon = true,
    required this.screenName,
    this.subScreenName,
    this.onWillPop,
    this.appBarSize,
    this.centerTitle,
    this.onBackButtonPressed,
    this.gestureDetectorOnPanDown,
    this.gestureDetectorOnTap,
    this.onNotificationListener,
    required this.scaffoldKey,
    required this.body,
    this.padding = const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 0),
    this.gridview,
    this.bottomBarIndex = 0,
    this.showAppBarProfile = false,
    this.showAppBarBackButton = false,
    this.showActionButton = false,
    this.isFullBody = false,
    this.bottomNavigationBar,
    this.title,
    this.floatingActionButton,
    this.leadingWidth = 70,
    this.listOfPopupMenuItems = const [],
    this.actions = const [],
    this.leadingWidget,
    this.drawer,
    this.backIconColor,
    this.openDrawerCallback,
  });

  @override
  _CustomScaffoldState createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
    return WillPopScope(
        onWillPop: () {
          print('=========going back as previous route is ${Get.previousRoute}');
          if (widget.onWillPop != null) {
            return widget.onWillPop!();
          } else {
            return Future.value(true);
          }
        },
        child: GestureDetector(
          onTap: () {
            if (widget.gestureDetectorOnTap != null) {
              widget.gestureDetectorOnTap!();
            }
          },
          onPanDown: (panDetails) {
            if (widget.gestureDetectorOnPanDown != null) {
              widget.gestureDetectorOnPanDown!(panDetails);
            }
          },
          child: NotificationListener(
            onNotification: (notificationInfo) {
              if (widget.onNotificationListener != null) {
                return widget.onNotificationListener!(notificationInfo);
              } else {
                return false;
              }
            },
            child: SafeArea(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: (kBackgroundColor),
                key: widget.scaffoldKey,
                drawer: widget.drawer,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(widget.appBarSize ?? 60),
                  child: CustomAppBar(
                      onBackButtonTap: widget.onBackButtonPressed,
                      title: widget.title,
                      leadingWidth: widget.leadingWidth,
                      backIcon: widget.isBackIcon,
                      actions: widget.actions ?? [],
                      backIconColor: widget.backIconColor ?? kWhiteColor,
                      scaffoldKey: widget.scaffoldKey,
                      centerTitle: widget.centerTitle ?? false,
                      leadingWidget: widget.leadingWidget,
                      screenTitleColor: widget.isFullBody ? kWhiteColor : kPrimaryColor,
                      screenTitle: widget.screenName,
                      className: widget.className),
                ),
                body: widget.isFullBody
                    ? Container(
                        child: widget.body,
                      )
                    : Container(
                        width: Get.width,
                        height: Get.height,
                        padding: widget.padding,
                        decoration: const BoxDecoration(
                          color: kBackgroundColor,
                        ),
                        child: SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(child: Container(child: widget.body)),
                            ],
                          ),
                        ),
                      ),
                extendBodyBehindAppBar: true,
                bottomNavigationBar: widget.bottomNavigationBar != null
                    ? Container(child: widget.bottomNavigationBar)
                    : Container(
                        width: 0,
                        height: 0,
                      ),
                floatingActionButton: widget.floatingActionButton,
                floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
              ),
            ),
          ),
        ));
  }
}
