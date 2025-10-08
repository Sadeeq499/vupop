import 'package:get/get.dart';
import 'package:socials_app/views/go_cardless/go_cardless_screen.dart';
import 'package:socials_app/views/screens/archive/raise_issue/raise_issue_screen.dart';
import 'package:socials_app/views/screens/bottom/bottom_bar_screen.dart';
import 'package:socials_app/views/screens/chat/chat_screen.dart';
import 'package:socials_app/views/screens/chat/chat_view_post.dart';
import 'package:socials_app/views/screens/chat/single_chat_screen.dart';
import 'package:socials_app/views/screens/discover/discover_screen.dart';
import 'package:socials_app/views/screens/discover/filter_screen.dart';
import 'package:socials_app/views/screens/discover/search_screen.dart';
import 'package:socials_app/views/screens/discover/swipe_view_post.dart';
import 'package:socials_app/views/screens/followers_profile_screen/components/follower_highlighted_post_view.dart';
import 'package:socials_app/views/screens/followers_profile_screen/components/follower_swipe_view.dart';
import 'package:socials_app/views/screens/followers_profile_screen/followers_profile_screen.dart';
import 'package:socials_app/views/screens/help_and_support/screen/help_and_support_screen.dart';
import 'package:socials_app/views/screens/home/home_screen.dart';
import 'package:socials_app/views/screens/home_recordings/hashtag_screen.dart';
import 'package:socials_app/views/screens/home_recordings/mention_screen.dart';
import 'package:socials_app/views/screens/home_recordings/recording_screen.dart';
import 'package:socials_app/views/screens/home_recordings/share_post_screen.dart';
import 'package:socials_app/views/screens/profile/components/create_highlighted_post.dart';
import 'package:socials_app/views/screens/profile/components/highlighted_post_view.dart';
import 'package:socials_app/views/screens/profile/components/profile_swip_view.dart';
import 'package:socials_app/views/screens/set_location/set_location_screen.dart';

import '../splash_screen.dart';
import '../views/screens/account_details/screen/account_details_screen.dart';
import '../views/screens/archive/archive_screen.dart';
import '../views/screens/archive/components/archive_swipe_view.dart';
import '../views/screens/auth/sign_in_screen.dart';
import '../views/screens/chat/single_community_chat_screen.dart';
import '../views/screens/edit_profile/screen/edit_profile_screen.dart';
import '../views/screens/notification/screen/notification_screen.dart';
import '../views/screens/profile/screen/profile_screen.dart';
import '../views/screens/request_payment/screen/request_payment_screen.dart';
import '../views/screens/social_wallet/screen/social_wallet_screen.dart';
import 'app_strings.dart';
import 'custom_route_transations.dart';
import 'screen_bindings.dart';

class RouteGenerator {
  static List<GetPage> getPages() {
    return [
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kSplashRoute,
          page: () => const SplashScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kSignInRoute,
          page: () => const SignInScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kRecordingRoute,
          page: () => RecordingScreen(isFromBottomBar: false),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kDiscoverRoute,
          page: () => const DiscoverScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kFilterRoute,
          page: () => const FilterScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kDiscoverSearchRoute,
          page: () => const SearchScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: false, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kBottomNavBar,
          page: () => const BottomNavigationScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kHomeScreenRoute,
          page: () => const HomeScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: false, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kChatScreenRoute,
          page: () => const ChatScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kProfileScreenRoute,
          page: () => const ProfileScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kSingleChatScreenRoute,
          page: () => const SingleChatScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kProfileRoute,
          page: (() => const ProfileScreen()),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kHelpAndSupportRoute,
          page: () => const HelpAndSupportScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kAccountDetailsRoute,
          page: () => const AccountDetailsScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kEditProfileRoute,
          page: () => const EditProfileScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kSocialWalletRoute,
          page: () => const SocialWalletScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kRequestPaymentRoute,
          page: () => const RequestPaymentScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kNotificationRoute,
          page: () => const NotificationScreen(),
          binding: ScreenBindings()),
      GetPage(
          // transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kMentionScreenRoute,
          page: () => const MentionScreen(),
          binding: ScreenBindings(),
          transition: Transition.downToUp),
      GetPage(
          // transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kHashTagScreenRoute,
          page: () => const HashTagScreen(),
          binding: ScreenBindings(),
          transition: Transition.downToUp),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kDiscoverSwipeViewRoute,
          page: () => const DiscoverSwipeViewPosts(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kChatVideoViewPostsRoute,
          page: () => const ChatVideoViewPosts(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kProfileSwipeViewPosts,
          page: () => const ProfileSwipeViewPosts(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kArchivePostsScreen,
          page: () => const ArchiveScreen(),
          binding: ScreenBindings()),
      GetPage(
          transition: Transition.cupertino,
          transitionDuration: Duration(milliseconds: 300),
          preventDuplicates: false,
          popGesture: true, // Ensure this is true
          customTransition: SwipeablePageTransition(),
          name: kArchiveSwipeViewPosts,
          page: () => const ArchiveSwipeViewPosts(),
          binding: ScreenBindings()),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kPostHighlightedView,
        page: () => const HighlightedPostView(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kGoCardlessAuthView,
        page: () => GoCardlessAuthView(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kFollowersProfileScreen,
        page: () => const FollowersProfileScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kFollowerSwipeViewPosts,
        page: () => const FollowerSwipeViewPosts(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kFollowerHighlightedPostView,
        page: () => const FollowerHighlightedPostView(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kCreateHighlightedPost,
        page: () => CreateHighlightedPost(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kSetLocationScreen,
        page: () => SetLocationScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kSharePostScreen,
        page: () => SharePostScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: false, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kSingleCommunityChatScreen,
        page: () => SingleCommunityChatScreen(),
        binding: ScreenBindings(),
      ),
      GetPage(
        transition: Transition.cupertino,
        transitionDuration: Duration(milliseconds: 300),
        preventDuplicates: false,
        popGesture: true, // Ensure this is true
        customTransition: SwipeablePageTransition(),
        name: kRaiseAnIssueScreen,
        page: () => RaiseIssueScreen(),
        binding: ScreenBindings(),
      ),
    ];
  }
}
