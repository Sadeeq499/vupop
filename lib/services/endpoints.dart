const bool isStaging = true;

const String kBaseURL = isStaging ? "https://staging-backend.vupop.io/v1" : "https://backend.vupop.io/v1";
const String kBaseNotificationURLSocket = isStaging ? "https://staging-backend-notifications.vupop.io" : "https://backend-notifications.vupop.io";
// const String kBaseNotificationURLSocket = "https://backend-notifications.vupop.io";
// const String kBaseURL = "https://backend.vupop.io/v1";

/***********************************************************Start BASE_URL_USER***********************************************************/

//////......User Urls......//////
const String kUserURLBase = isStaging ? "https://staging-user.vupop.io/v1/user/service" : "https://user.vupop.io/v1/user/service";
const String kUserURL = "$kUserURLBase/user";
const String kRegisterUserURL = "$kUserURL/register";
const String kLoginUserURL = "$kUserURL/login";
const String kCheckUser = "$kUserURL/checkUser";
const String kDeleteUser = "$kUserURL/deleteUser";
const String kGetActiveBroadcasters = "$kUserURLBase/manager/getBroadCasters";

/////.....Profile Urls..../////
const String kFollowUserURL = "$kUserURL/follow";
const String kUnFollowURL = "$kUserURL/unFollow";
const String kChangeProfileImgURL = "$kUserURL/updateImage";
const String kGetUserPorilfeImguURL = "$kUserURL/image";
const String kGetUser = "$kUserURL/getUser";
const String kUpdateUser = "$kUserURL/updateUser";

//////......OTP Urls......//////
const String kOtpURL = "$kUserURLBase/otp";
const String kSendOtpToEmail = "$kOtpURL/sendOTPToEmail";
const String kVerifyOtp = "$kOtpURL/verifyEmail";

//////......Block/Report Urls......//////
const String kBlockReportURL = "$kUserURLBase/block";
const String kReportingClipURL = "$kBlockReportURL/reportPost";
const String kBlockingUserURL = "$kBlockReportURL/blockUser";
const String kBlockingReportingReasonsURL = "$kBlockReportURL/blockReport";

////.......Get Passions Urls....../////
const String kGetPassionURL = "$kUserURLBase/Passion/get";
const String kGetUserPassionURL = "$kUserURL/passion";

/***********************************************************Ends BASE_URL_USER***********************************************************/

/***********************************************************Start BASE_URL_CONTENT***********************************************************/
//////......Post Urls......//////
const String kPostURL = isStaging ? "https://staging-content.vupop.io/v1/content/service/post" : "https://content.vupop.io/v1/content/service/post";
const String kCreatePostURL = "$kPostURL/createPost";
const String kSetPostRatingURL = "$kPostURL/rating";
const String kGetUserPostUrl = "$kPostURL/userPost";
const String kGetUserArchivedPostUrl = "$kPostURL/userPost?archive=true";
const String kUpdateUserActivity = "$kPostURL/updateUserActivity";
const String kGetPreSignedUrl = "$kPostURL/presignedUrl";
const String kGetTrendingHashtags = "$kPostURL/trendingHashtags";
const String kGetUserFeedPosts = "$kPostURL/userFeed";
const String kGetPostViews = "$kPostURL/postViews";
const String kGetPostsByUserId = "$kPostURL/archivePosts";

////.......Highlight Urls....../////
const String kGetUserHighlithedReelsURL = "$kPostURL/highlight/get";
const String kCreateHighlightReelURL = "$kPostURL/highlight/add";
const String kUpdateHighlightReelURL = "$kPostURL/highlight/update";
const String kDeleteHighlightReelURL = "$kPostURL/highlight/delete";

/////.....Favourite Urls..../////
const String kGetUserFavClipsURL = "$kPostURL/favourite/get";
const String kAddFavClipURL = "$kPostURL/favourite/add";
const String kDeleteFavClipURL = "$kPostURL/favourite/delete";
const String kUpdateFavClipURL = "$kPostURL/favourite/update";

/***********************************************************Ends BASE_URL_CONTENT***********************************************************/

/***********************************************************Start BASE_URL_PAYMENT***********************************************************/

/////....Payment Urls..../////
const String kPaymentURL = isStaging ? "https://staging-payment.vupop.io/v1/payment/service" : "https://payment.vupop.io/v1/payment/service";
const String kPaymentMethodURL = "$kPaymentURL/paymentMethod";

const String kAddPaymentMethodURL = "$kPaymentMethodURL/addPaymentMethodbroadcaster";
const String kGetPaymentMethodURL = "$kPaymentMethodURL/getPaymentMethod";

/////....Wallet Urls..../////
const String kWalletURL = "$kPaymentURL/wallet";
const String kRequestPaymentURL = "$kWalletURL/requestPayment";
const String kRequestPaymentToAdminURL = "$kWalletURL/requestPaymettoAdmin";
const String kGetWalletBalanceURL = "$kWalletURL/getWallet";

/***********************************************************Ends BASE_URL_PAYMENT***********************************************************/

/***********************************************************Start BASE_URL_SUPPORT***********************************************************/

//// Supoort Urls
const String kSupportURL =
    isStaging ? "https://staging-support.vupop.io/v1/support/service/help" : "https://support.vupop.io/v1/support/service/help";

/***********************************************************End BASE_URL_SUPPORT***********************************************************/

/***********************************************************Start BASE_URL_CHAT***********************************************************/

////.....Chat Urls..../////
const String kChatURL = isStaging ? "https://staging-chat.vupop.io/v1/chat/service/chat" : "https://chat.vupop.io/v1/chat/service/chat";
const String kGetAllChatURL = "$kChatURL/chattedUsers";
const String kGetAllChatMessagesURL = "$kChatURL/allChats";

////.....Community Chat Urls..../////
const String kCommunityChatURL =
    isStaging ? "https://staging-chat.vupop.io/v1/chat/service/communityChat" : "https://chat.vupop.io/v1/chat/service/communityChat";
const String kGetCommunitiesURL = "$kCommunityChatURL/getCommunities";
const String kJoinCommunityURL = "$kCommunityChatURL/joinCommunity";
const String kLeaveCommunityURL = "$kCommunityChatURL/leaveCommunity";
const String kGetUserCommunitiesURL = "$kCommunityChatURL/getUserCommunities";
const String kGetCommunityMessagesURL = "$kCommunityChatURL/getMessages";

/***********************************************************Ends BASE_URL_CHAT***********************************************************/

/***********************************************************Start BASE_URL_NOTIFICATION***********************************************************/

////.....Notification Urls..../////
const String kNotificationURL =
    isStaging ? "https://staging-notifications.vupop.io/v1/notification/service" : "https://notifications.vupop.io/v1/notification/service";
const String kSendNotificationURL = "$kNotificationURL/notification/sendNotification";
const String kGetAllNotificationsURL = "$kNotificationURL/notification/getBroadcasterNotification";
const String kGetAllCommunityChatNotificationsURL = "$kNotificationURL/communityNotification/getCommunityNotification";
const String kGetAllExportNotificationsURL = "$kNotificationURL/notification/exportNotification";
const String kGetPayoutNotificationsURL = "$kNotificationURL/payoutNotification/payoutNotification";
const String kVerifyPayoutNotificationsURL = "$kNotificationURL/payoutNotification/verifyPayoutNotification";

/***********************************************************Ends BASE_URL_NOTIFICATION***********************************************************/

// const String kSocketNotificationURL = "wss:///staging-backend.vupop.io/notification";
const String kSocketNotificationURL = isStaging ? "https://staging-notifications.vupop.io" : "https://notifications.vupop.io";
const String kSocketChatURL = isStaging ? "wss://staging-chat.vupop.io/chat" : "wss://chat.vupop.io/chat";
const String kSocketPostURL = isStaging ? "https://staging-content.vupop.io/v1/" : "https://content.vupop.io/v1/";

/***********************************************************Start BASE_URL_CONTENT_ISSUE***********************************************************/
const String kPostIssueURL = isStaging ? "https://staging-content.vupop.io/v1/content/service" : "https://content.vupop.io/v1/content/service";

//////......Raise An Issue Urls......//////
const String kGetAllIssueReasons = '$kPostIssueURL/issueReason';
const String kReportVideoClip = '$kPostIssueURL/reportVideo';

/***********************************************************End BASE_URL_CONTENT***********************************************************/
