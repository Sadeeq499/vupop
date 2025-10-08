import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socials_app/models/notification_model.dart';
import 'package:socials_app/models/payout_notification_model.dart';
import 'package:socials_app/repositories/chat_repo.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socials_app/utils/app_images.dart';
import 'package:socials_app/utils/app_strings.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../models/community_chat_noification_model.dart';
import '../../../../models/community_message_model.dart';
import '../../../../models/export_notifications_model.dart';
import '../../../../models/payment_models/get_payment_methods_model.dart';
import '../../../../repositories/payment_repo.dart';
import '../../../../services/custom_snackbar.dart';
import '../../../../services/endpoints.dart';
import '../../../../utils/common_code.dart';
import '../../../custom_widgets/custom_app_dialogs.dart';
import '../components/join_chat_dialog_widget.dart';

class NotificationsController extends GetxController {
  GlobalKey<ScaffoldState> notificationKey = GlobalKey<ScaffoldState>();
  RxDouble progress = 86.0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingCommunityChats = false.obs;
  RxBool isLoadingPostNotifications = false.obs;
  RxBool isLoadingMorePostNotifications = false.obs;
  RxBool isLoadingPayoutNotifications = false.obs;
  Rxn<PayoutNotification> payoutNotification = Rxn<PayoutNotification>();
  final ScrollController scrollController = ScrollController();
  RxInt pageNo = 1.obs;

  @override
  void onInit() {
    super.onInit();
    // getAllNotifications();
    // Add listener to detect when user reaches bottom of the list
    // getUserPaymentMethod();
    getPayoutNotifications();
    scrollController.addListener(() {
      printLogs(
          "======scrollController.position.pixels == scrollController.position.maxScrollExtent ${scrollController.position.pixels == scrollController.position.maxScrollExtent}");
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent) {
        // User reached the bottom, load more notifications
        loadMorePostNotification();
      }
    });
  }

  RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  RxList<ChatNotification> communityNotifications = <ChatNotification>[].obs;
  // RxList<NotificationData> postsNotifications = <NotificationData>[].obs;
  RxList<PostNotification> postsNotifications = RxList();

  Future<void> getAllNotifications() async {
    final userId = SessionService().user?.id;
    isLoading.value = true;
    try {
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .getAllNotifications(userId ?? '');
      notifications.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to get notifications');
    } finally {
      isLoading.value = false;
    }
  }

  RxInt currentPageNo = 1.obs;
  Future<void> getAllCommunityChatNotifications() async {
    printLogs('================getAllCommunityChatNotifications called');
    final userId = SessionService().user?.id;
    isLoadingCommunityChats.value = true;
    try {
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .getAllCommunityChatNotifications(userId: userId ?? '', pageNo: currentPageNo.value);
      printLogs('=================getAllCommunityChatNotifications data ${data}');
      communityNotifications.value = data?.chatNotification ?? [];
    } catch (e) {
      printLogs('===========getAllCommunityChatNotifications exception $e');
      Get.snackbar('Error', 'Failed to get notifications');
    } finally {
      isLoadingCommunityChats.value = false;
    }
  }

  RxBool isJoinCommunityLoading = false.obs;
  Future<void> joinCommunityChat({required ChatNotification notification}) async {
    isJoinCommunityLoading.value = true;
    Community? joinedCommunity = await ChatRepo().joinCommunity(SessionService().user?.id ?? "", notification.community ?? "");
    printLogs('======================joinedCommunity $joinedCommunity');

    if (joinedCommunity != null) {
      Get.back();
      isJoinCommunityLoading.value = false;
      Future.delayed(const Duration(seconds: 0), () async {
        try {
          // Initialize the socket connection
          CommunityChatSocketService.instance.initializeSocket(kSocketChatURL, queryParams: {});
          // CommunityChatSocketService.instance.initializeSocket("https://staging-backend.vupop.io/chat", queryParams: {});
          // CommunityChatSocketService.instance.initializeSocket("https://backend.vupop.io/chat", queryParams: {});
          setupCommunityChatSocketListeners();
          startListeningToCommunityChatSocket();
        } catch (error, stackTrace) {
          printLogs("Error in onInit: $error");
          printLogs("StackTrace: $stackTrace");
        }
      });
      Get.dialog(
        JoinChatDialog(
          isLoading: isJoinCommunityLoading,
          btnLabel: 'View Chat',
          titleText: 'Chat Joined',
          image: kChatJoinedIcon,
          onTap: () {
            Get.back();
            Get.toNamed(kSingleCommunityChatScreen, arguments: {"joinedCommunity": joinedCommunity});
          },
          description: 'You’ve successfully joined the “${joinedCommunity.name}” community chat',
          notification: notification,
          endTime: null,
        ),
        barrierColor: Colors.black.withOpacity(0.55),
      );
    }
  }

  startListeningToCommunityChatSocket() {
    final socket = CommunityChatSocketService.instance.socket;
    if (socket == null) {
      printLogs('NotificationCont CommunityChatSocketService Socket is not initialized');
      return;
    }

    socket?.on('communitiesJoined', (data) {
      printLogs('startListeningToCommunityChatSocket communitiesJoined response: $data');
    });

    socket?.on('communityChats', (data) {
      printLogs('startListeningToCommunityChatSocket communityChats response: $data');
    });

    socket.on('error', (data) {
      printLogs('startListeningToCommunityChatSocket Error: $data');
    });

    socket.on('disconnect', (_) {
      printLogs('startListeningToCommunityChatSocket Socket disconnected');
    });

    printLogs('===========startListeningToCommunityChatSocket emitted');
  }

  RxBool isSocketConnect = false.obs;
  void setupCommunityChatSocketListeners() {
    final socket = CommunityChatSocketService.instance.socket;

    socket?.onConnect((_) {
      isSocketConnect.value = true;
      //fetchChats();
      printLogs("=======CommunityChat socket connected");
    });

    socket?.onDisconnect((_) {
      isSocketConnect.value = false;
      printLogs("=======CommunityChat socket disconnected");
    });

    socket?.onReconnect((_) {
      printLogs("=======CommunityChat socket reconnected");
    });

    socket?.onError((data) {
      isSocketConnect.value = false;
      printLogs("=======CommunityChat socket error");
    });

    socket?.onConnectError((data) {
      isSocketConnect.value = false;
      printLogs("=======CommunityChat socket connect error");
    });
  }

  //post notifications
  /*Future<void> getAllExportPostNotifications() async {
    printLogs('================getAllExportPostNotifications called');
    final userId = SessionService().user?.id;
    isLoadingPostNotifications.value = true;
    try {
      postsNotifications.value = SessionService().exportPostNotificationData ?? [];

      printLogs('=================getAllExportPostNotifications data ${postsNotifications.length}');
    } catch (e) {
      printLogs('===========getAllExportPostNotifications exception $e');
      Get.snackbar('Error', 'Failed to get notifications');
    } finally {
      isLoadingPostNotifications.value = false;
    }
  }*/

  RxInt currentPostsPageNo = 1.obs;
  RxInt totalPostsPageNo = 1.obs;
  loadMorePostNotification() {
    printLogs("currentPageNo.value < totalPostsPageNo.value ${currentPostsPageNo.value < totalPostsPageNo.value}");
    printLogs("totalPostsPageNo.value ${totalPostsPageNo.value}");
    printLogs("currentPageNo.value${currentPostsPageNo.value}");
    if (currentPostsPageNo.value <= totalPostsPageNo.value) {
      getAllExportPostNotifications();
    }
  }

  Future<void> getAllExportPostNotifications() async {
    printLogs('================getAllExportPostNotifications called ${currentPostsPageNo.value}');
    final userId = SessionService().user?.id;
    if (currentPostsPageNo.value == 1) {
      isLoadingPostNotifications.value = true;
    } else {
      isLoadingMorePostNotifications.value = true;
    }
    try {
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .getAllPostExportNotifications(userId: userId ?? '', pageNo: currentPostsPageNo.value);
      printLogs('=================getAllExportPostNotifications data ${data}');
      totalPostsPageNo.value = data?.pages ?? 1;
      if (currentPostsPageNo.value == 1) {
        postsNotifications.value = data?.notification ?? [];
      } else {
        postsNotifications.addAll(data?.notification ?? []);
      }
      currentPostsPageNo.value++;
    } catch (e) {
      printLogs('===========getAllExportPostNotifications exception $e');
      Get.snackbar('Error', 'Failed to get post notifications');
    } finally {
      isLoadingPostNotifications.value = false;
      isLoadingMorePostNotifications.value = false;
    }
  }

  RxBool isEmailVerified = false.obs;
  RxBool isAccountDetailsAdded = false.obs;
  getUserPaymentMethod() async {
    try {
      final userID = SessionService().user!.id;
      // isEmailVerified.value = SessionService().isEmailVerified ?? false;
      PaymentMethodData? paymentMethodData = await PaymentRepo().getUserPaymentMethod(userId: userID, showSnackbar: false);
      if (paymentMethodData != null) {
        isAccountDetailsAdded.value = true;
      }
    } catch (e) {
      printLogs('getUserPaymentMethod Exception : $e');
    }
  }

  Future<void> getPayoutNotifications() async {
    printLogs('================getPayoutNotifications called');
    final userId = SessionService().user?.id;

    isLoadingPayoutNotifications.value = true;

    try {
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .getPayoutNotifications(
        userId: userId ?? '',
      );
      printLogs('=================getPayoutNotifications data ${data}');

      if (data != null && data.payoutNotification.isNotEmpty) {
        payoutNotification.value = data.payoutNotification[0];
        isEmailVerified.value = payoutNotification.value?.isVerified ?? false;
        getUserPaymentMethod();
      } else {
        isEmailVerified.value = true;
        // isAccountDetailsAdded.value = false;
      }
    } catch (e) {
      printLogs('===========getPayoutNotifications exception $e');
      Get.snackbar('Error', 'Failed to get Payout notifications');
    } finally {
      isLoadingPayoutNotifications.value = false;
    }
  }

  RxBool isVerifyingPayout = false.obs;
  Future<void> verifyPayouts({required String notificationId}) async {
    try {
      isVerifyingPayout.value = true;
      final data = await NotificationRepo()

          ///66b3953cf4a2d4388ef05833
          .verifyPayoutNotification(
        notificationId: notificationId ?? '',
      );
      printLogs('=================getPayoutNotifications data ${data}');

      if (data != null && data) {
        CustomSnackbar.showSnackbar("Payout details has been verified successfully");
        isEmailVerified.value = true;
        showCongratulationsDialogNew(
          isFromProfile: false,
          // customerName: paymentMethodData?.userName ?? "-",
          // iban: paymentMethodData?.iban ?? "-",
          // amountToWithdraw: walletPaymentData.value?.readyToWithdrawAmount?.toStringAsFixed(2) ?? "0",
          requestStatus: 'Success',
        );
      } else {
        CustomSnackbar.showSnackbar("Failed to verify payout details, please try again");
      }
    } catch (e) {
      printLogs('===========getPayoutNotifications exception $e');
      CustomSnackbar.showSnackbar("Failed to verify payout details, please try again");
    } finally {
      isVerifyingPayout.value = false;
    }
  }
}

class CommunityChatSocketService {
  static final CommunityChatSocketService _instance = CommunityChatSocketService._internal();

  io.Socket? socket;

  CommunityChatSocketService._internal();

  static CommunityChatSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();

    /*socket?.onConnect((_) {
      printLogs('Socket connected');
    });*/
    printLogs("CommunityChat Socket initialized and connected for posts");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("CommunityChat Socket disconnected");
    }
  }
}
