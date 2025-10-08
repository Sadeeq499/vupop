import 'package:get/get.dart';
import 'package:socials_app/views/go_cardless/go_cardless_controller.dart';
import 'package:socials_app/views/screens/archive/raise_issue/controller/raise_issue_controller.dart';
import 'package:socials_app/views/screens/chat/controller/chat_controller.dart';
import 'package:socials_app/views/screens/discover/controller/discover_controller.dart';
import 'package:socials_app/views/screens/followers_profile_screen/controller/followers_profile_controller.dart';
import 'package:socials_app/views/screens/home/controller/home_controller.dart';
import 'package:socials_app/views/screens/home/controller/video_player_controller.dart';
import 'package:socials_app/views/screens/home_recordings/controller/recording_cont.dart';
import 'package:socials_app/views/screens/profile/controller/profile_controller.dart';
import 'package:socials_app/views/screens/set_location/controller/map_controller.dart';

import '../services/in_app_subscriptions/in_app_subscription_service.dart';
import '../views/screens/account_details/controller/account_details_controller.dart';
import '../views/screens/archive/controller/archive_controller.dart';
import '../views/screens/auth/controller/auth_controller.dart';
import '../views/screens/bottom/controller/bottom_bar_controller.dart';
import '../views/screens/edit_profile/controller/edit_profile_controller.dart';
import '../views/screens/help_and_support/controller/help_and_support_controller.dart';
import '../views/screens/notification/controller/notification_controller.dart';
import '../views/screens/profile/controller/create_highlight_controller.dart';
import '../views/screens/request_payment/controller/request_payment_controller.dart';
import '../views/screens/social_wallet/controller/social_wallet_controller.dart';

class ScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => DiscoverController());
    Get.lazyPut(() => RecordingController(), fenix: true);
    Get.lazyPut(() => BottomBarController());
    Get.lazyPut(() => HomeScreenController());
    Get.lazyPut(() => ChatScreenController());
    Get.lazyPut(() => ProfileScreenController());
    Get.lazyPut(() => HelpAndSupportController());
    Get.lazyPut(() => AccountDetailsController());
    Get.lazyPut(() => EditProfileController());
    Get.lazyPut(() => RequestPaymentController());
    Get.lazyPut(() => SocialWalletController());
    Get.lazyPut(() => NotificationsController(), fenix: true);
    Get.lazyPut(() => VideoPlayerControllerX());
    Get.lazyPut(() => ArchiveController());
    Get.lazyPut(() => GoCardlessAuthController());
    Get.lazyPut(() => FollowersProfileController());
    Get.lazyPut(() => MapController());
    Get.lazyPut(() => CreateHighlightedPostController());
    Get.lazyPut(() => RaiseIssueController());
    Get.put(SubscriptionService(), permanent: true);
  }
}
