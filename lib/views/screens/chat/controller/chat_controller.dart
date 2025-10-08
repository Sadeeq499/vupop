// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:audio_waveforms/audio_waveforms.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:socials_app/models/user_chat_model.dart';
// import 'package:socials_app/models/usermodel.dart';
// import 'package:socials_app/repositories/chat_repo.dart';
// import 'package:socials_app/repositories/notification_repo.dart';
// // import 'package:socials_app/repositories/chatsocket.dart';
// import 'package:socials_app/services/endpoints.dart';
// import 'package:socials_app/services/session_services.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

// class ChatScreenController extends GetxController {
//   GlobalKey<ScaffoldState> scaffoldKeyChat = GlobalKey<ScaffoldState>();
//   GlobalKey<ScaffoldState> scaffoldKeySingleChat = GlobalKey<ScaffoldState>();
//   TextEditingController searchChat = TextEditingController(),
//       message = TextEditingController();
//   TextEditingController searchNewChat = TextEditingController();
//   void filterSearch(String query) {
//     if (query.isEmpty) {
//       filteredChatUsers.value = allChatUsers;
//     } else {
//       filteredChatUsers.value = allChatUsers
//           .where((user) =>
//               user.name.toLowerCase().contains(query.toLowerCase()) ||
//               user.chat.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     }
//   }

//   RecorderController recorderController = RecorderController();
//   PlayerController audioFileController = PlayerController();
//   @override
//   void onInit() {
//     super.onInit();
//     searchChat.addListener(() {
//       filterSearch(searchChat.text);
//     });
//     log("ChatScreenController Init");

//     Future.delayed(const Duration(seconds: 0), () {
//       getAllchats().then((value) {
//         initializeSocket(kBaseURL, queryParams: {});
//       });
//     }).then((value) {});
//   }

//   RxBool isLoading = false.obs;
//   Future<void> getAllchats() async {
//     isLoading.value = true;
//     final resp = await ChatRepo().getAllChats(SessionService().user?.id ?? '');
//     if (resp.isEmpty) {
//       isLoading.value = false;
//       return;
//     }
//     allChatUsers.clear();
//     allChatUsers.addAll(resp);
//     allChatUsers.refresh();
//     filteredChatUsers.clear();
//     filteredChatUsers.addAll(allChatUsers);
//     filteredChatUsers.refresh();
//     filterSearch(searchChat.text);
//     isLoading.value = false;
//   }

//   io.Socket? socket;
//   // StreamController<List<MessageModel>> singleChatController =
//   //     StreamController.broadcast();
//   RxList<MessageModel> singleChatController = <MessageModel>[].obs;
//   RxList<ChatUser> allChatUsers = <ChatUser>[].obs;
//   RxList<ChatUser> filteredChatUsers = <ChatUser>[].obs;
//   RxBool isSocketConnect = false.obs;
//   void initializeSocket(String uri,
//       {required Map<dynamic, dynamic> queryParams}) {
//     // Configure the socket
//     socket = io.io(
//         uri,
//         io.OptionBuilder()
//             .setTransports(['websocket'])
//             .disableAutoConnect()
//             .build());

//     // Register event listeners
//     socket?.onConnect((_) {
//       log('Connected to socket server');
//       isSocketConnect.value = true;
//       fetchChats();
//     });

//     socket?.onDisconnect((_) {
//       isSocketConnect.value = false;
//       log('Disconnected from socket server');
//       // socket == null;
//       // socket?.connect();
//       // fetchChats();
//     });

//     socket?.onReconnect((_) {
//       log('Reconnected to socket server');
//       fetchChats();
//     });

//     socket?.onError((data) {
//       isSocketConnect.value = false;
//       log('Socket error: $data');
//     });

//     socket?.onConnectError((data) {
//       isSocketConnect.value = false;
//       log('Connection error: $data');
//     });

//     if (socket?.connected == false) {
//       socket?.connect();
//     }

//     // Connect to the server
//     socket?.connect();
//   }

//   void emitEvent(String event, dynamic data) {
//     socket?.emit(event, data);
//   }

//   void fetchChats() {
//     // socket.emit('getChattedUsers', SessionService().user?.id ?? '');
//     // List<ChatUser> chats = [];
//     // socket.on('allChattedUsers', (data) {
//     //   for (var chat in data) {
//     //     chats.clear();
//     //     chats.add(ChatUser.fromJson(chat));
//     //   }
//     //   recentChatController.add(chats);
//     // });
//     if (socket == null || socket?.connected == false) {
//       socket?.connect();
//     }
//     socket?.emit('getChattedUsers', SessionService().user?.id ?? '');
//     socket?.on('allChattedUsers', (data) {
//       log("dadada $data");
//       if (data == null) return;
//       final existingUserIds = allChatUsers.map((user) => user.userId).toSet();
//       log('Existing user ids: ${existingUserIds.length}');
//       final List<ChatUser> newChatUsers = [];
//       if (existingUserIds.isNotEmpty) {
//         for (var chat in data) {
//           final tempChatadata = ChatUser.fromJson(chat);
//           log('tempChatadata: ${tempChatadata.name}');
//           if (!existingUserIds.contains(tempChatadata.userId)) {
//             log('Adding new chat user: ${tempChatadata.name}');
//             newChatUsers.add(tempChatadata);
//             existingUserIds.add(tempChatadata.userId);
//           }
//         }
//       }
//       allChatUsers.addAll(newChatUsers);
//       allChatUsers.refresh();
//     });
//   }

//   RxString chattedUserName = ''.obs;
//   RxString chattedUserImage = ''.obs;
//   RxString chattedUserId = ''.obs;
//   void getChatBetweenTwoUsers(
//       String user1Id, String user2Id, String name, String image) {
//     socket?.emit('getChats', [user1Id, user2Id]);
//     List<MessageModel> chats = [];
//     socket?.on('allChats', (data) {
//       log('zxc user1Id: $user1Id');
//       log('zxc chats: $data');
//       chats.clear();
//       chats.addAll(data
//           .map<MessageModel>((chat) => MessageModel.fromJson(chat))
//           .toList());
//       singleChatController.clear();
//       singleChatController.addAll(chats);
//       singleChatController.refresh();
//       // if (!singleChatController.isClosed) {
//       //   singleChatController.add(chats);
//       // } else {
//       //   log('singleChatController is closed, cannot add new events');
//       // }
//     });
//     socket?.on('receiveChat', (data) {
//       log('zxc receiveChat: $data');
//       singleChatController.clear();
//       singleChatController.add(MessageModel.fromJson(data));
//       singleChatController.refresh();
//     });
//     chattedUserName.value = name;
//     chattedUserImage.value = image;
//     chattedUserId.value = user2Id;
//   }

//   RxBool isAudioMesgSending = false.obs;
//   void sendMessage(
//     String text, {
//     required String sender,
//     required String receiver,
//     required bool isAudioFile,
//   }) async {
//     if (isAudioFile) {
//       isAudioMesgSending.value = true;
//       final msg = MessageModel(
//         sender: sender,
//         receiver: receiver,
//         isRead: true,
//         audioMessage: text,
//         id: 'temp',
//         date: DateTime.now(),
//         version: 1,
//       );
//       singleChatController.add(msg);
//       singleChatController.refresh();
//       File file = File(text);
//       Uint8List fileBytes = await file.readAsBytes();

//       socket?.emit('sendChat', [
//         sender,
//         receiver,
//         false,
//         fileBytes,
//       ]);
//       NotificationRepo().sendNotification(
//           userId: receiver, title: "New Audio Message", body: "Audio Message");
//       clearRecording();
//       isAudioMesgSending.value = false;

//       // ChatRepo()
//       //     .sendAudioMessage(
//       //   text,
//       //   sender: sender,
//       //   receiver: receiver,
//       // )
//       //     .then((value) {
//       //   clearRecording();
//       //   if (value is MessageModel) {
//       //     // log('QWERTY: ${value.message}');
//       //     // message.clear();
//       //     // var chats = singleChatController.stream;
//       //     // singleChatController.add([value]);

//       //     NotificationRepo().sendNotification(
//       //         userId: receiver,
//       //         title: "New Audio Message",
//       //         body: "Audio Message");
//       //   }
//       //   isAudioMesgSending.value = false;
//       //   List<MessageModel> chats = [];
//       //   socket?.on('allChats', (data) {
//       //     chats.clear();
//       //     chats.addAll(data
//       //         .map<MessageModel>((chat) => MessageModel.fromJson(chat))
//       //         .toList());
//       //     singleChatController.clear();
//       //     singleChatController.addAll(chats);
//       //   });
//       // });
//       clearRecording();
//       isAudioMesgSending.value = false;
//     } else {
//       socket?.emit('sendChat', [
//         sender,
//         receiver,
//         text,
//       ]);
//       socket?.on('allChats', (data) {
//         singleChatController.add(MessageModel.fromJson(data));
//         singleChatController.refresh();
//       });
//       NotificationRepo()
//           .sendNotification(userId: receiver, title: "New Message", body: text);
//       message.clear();
//     }
//   }

//   RxBool isRecording = false.obs;
//   RxBool isRecordingCompleted = false.obs;
//   RxString path = ''.obs;
//   void startOrStopRecording() async {
//     try {
//       if (isRecording.value) {
//         recorderController.reset();
//         path.value = await recorderController.stop(false) ?? '';
//         if (path.value.isNotEmpty) {
//           isRecordingCompleted.value = true;
//           debugPrint(path.value);
//           printLogs("Recorded file size: ${File(path.value).lengthSync()}");
//         }
//       } else {
//         await getDir().then((value) async {
//           await recorderController.record(
//             path: path.value,
//             androidEncoder: AndroidEncoder.aac,
//             androidOutputFormat: AndroidOutputFormat.aac_adts,
//             iosEncoder: IosEncoder.kAudioFormatAMR,
//           );
//         });
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     } finally {
//       isRecording.value = !isRecording.value;
//     }
//   }

//   Future<void> getDir() async {
//     final appDirectory = await getApplicationDocumentsDirectory();
//     path.value = "${appDirectory.path}/recording.m4a";
//   }

//   // clear the recording file and values after sending the audio
//   void clearRecording() {
//     isRecordingCompleted.value = false;
//     path.value = '';
//     isRecording.value = false;
//     recorderController.reset();
//   }

//   RxList<UserDetailModel> followingUesrs = <UserDetailModel>[].obs;
//   void filterBottomSheetSearch(String value) {
//     if (value.isEmpty) {
//       followingUesrs.value = SessionService().following;
//     } else {
//       followingUesrs.value = SessionService()
//           .following
//           .where(
//               (user) => user.name.toLowerCase().contains(value.toLowerCase()))
//           .toList();
//     }
//   }

//   @override
//   void onClose() {
//     socket?.disconnect();
//     socket?.destroy();
//     // recentChatController.close();
//     singleChatController.close();
//     super.onClose();
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socials_app/models/user_chat_model.dart';
import 'package:socials_app/models/usermodel.dart';
import 'package:socials_app/repositories/chat_repo.dart';
import 'package:socials_app/repositories/notification_repo.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/session_services.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../models/community_all_chats_model.dart';
import '../../../../models/community_message_model.dart';
import '../../../../models/post_models.dart';
import '../../../../models/user_communities_model.dart';
import '../../../../services/custom_snackbar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/common_code.dart';
import '../../home/controller/home_controller.dart';
import '../../notification/components/join_chat_dialog_widget.dart';
import '../../notification/controller/notification_controller.dart';

class ChatScreenController extends GetxController {
  GlobalKey<ScaffoldState> scaffoldKeyChat = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySingleChat = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySingleCommunityChat = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> scaffoldKeySwipe = GlobalKey<ScaffoldState>();
  TextEditingController searchChat = TextEditingController(), message = TextEditingController();
  TextEditingController searchNewChat = TextEditingController();

  RecorderController recorderController = RecorderController();
  PlayerController audioFileController = PlayerController();

  RxBool isLoading = false.obs;
  RxBool isFirstTimeLoad = true.obs;
  RxList<MessageModel> singleChatController = <MessageModel>[].obs;
  RxList<ChatUser> allChatUsers = <ChatUser>[].obs;
  RxList<ChatUser> filteredChatUsers = <ChatUser>[].obs;
  RxBool isSocketConnect = false.obs;
  RxString chattedUserName = ''.obs;
  RxString chattedUserImage = ''.obs;
  RxString chattedUserId = ''.obs;
  RxBool isAudioMesgSending = false.obs;
  RxBool isRecording = false.obs;
  RxBool isRecordingCompleted = false.obs;
  RxString path = ''.obs;
  RxBool isPlaying = false.obs;

  CachedVideoPlayerPlus? videoController;
  // VideoPlayerController? videoController;
  bool _isPlaying = false;

  RxBool isRatingTapped = false.obs;
  RxBool isVideoLoading = false.obs;

  //Community chats
  RxList<CommunityChatMessages> singleCommunityChatMessagesController = <CommunityChatMessages>[].obs;
  Rx<Community?> communityModel = Rx(Community());
  Rx<CommunityMessagesDataModel?> communityMessagesModel = Rx(CommunityMessagesDataModel());
  final messageText = ''.obs;

  RxList<CommunityAllChatsModelData> allCommunityChatUsers = <CommunityAllChatsModelData>[].obs;
  RxList<CommunityAllChatsModelData> filteredCommunityChats = <CommunityAllChatsModelData>[].obs;
  RxBool isCommunityChatsLoading = false.obs;

  final scrollController = ScrollController();
  // Add RxBool to track scroll position
  RxBool showScrollButton = false.obs;
  RxBool isLoadingFullScreen = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Future.delayed(const Duration(seconds: 0), () {
    //   getAllchats().then((value) {
    //     ChatSocketService.instance.initializeSocket(kBaseURL, queryParams: {});
    //     setupSocketListeners();
    //   });
    // });
  }

  void initializeAllMethods() {
    searchChat.addListener(() {
      // filterSearch(searchChat.text);
      filterSearchCommunity(searchChat.text);
    });
    message.addListener(() {
      messageText.value = message.text;
    });
    // currentPage.value = 1;

    log("ChatScreenController Init");
    Future.delayed(const Duration(seconds: 0), () async {
      try {
        // ChatSocketService.instance.initializeSocket(kBaseURL, queryParams: {});
        // setupSocketListeners();

        // Initialize the CommunityChatSocket connection
        if (CommunityChatSocketService.instance.socket == null) {
          CommunityChatSocketService.instance.initializeSocket(kSocketChatURL, queryParams: {});
          // CommunityChatSocketService.instance.initializeSocket("https://staging-backend.vupop.io/chat", queryParams: {});
          // CommunityChatSocketService.instance.initializeSocket("https://backend.vupop.io/chat", queryParams: {});
          // setupCommunityChatSocketListeners();
        }
      } catch (error, stackTrace) {
        log("Error in onInit: $error");
        log("StackTrace: $stackTrace");
      }
    });
  }

  Future<void> getAllchats() async {
    isLoading.value = true;
    final resp = await ChatRepo().getAllChats(SessionService().user?.id ?? '');
    if (resp.isEmpty) {
      isLoading.value = false;
      return;
    }
    allChatUsers.clear();
    allChatUsers.value = (resp);
    allChatUsers.refresh();
    filteredChatUsers.clear();
    filteredChatUsers.addAll(allChatUsers);
    filteredChatUsers.refresh();
    filterSearch(searchChat.text);
    isLoading.value = false;
  }

  Future<void> getAllCommunityChats() async {
    isCommunityChatsLoading.value = true;
    final resp = await ChatRepo().getAllCommunities(SessionService().user?.id ?? '');
    // List<CommunityChatUserModel> resp = [];
    // resp.add(CommunityChatUserModel(
    //     image: kCNN,
    //     community: '67ac65cee9e64d015cfa52e3',
    //     lastMessageTime: DateTime.parse("2025-02-16T09:36:05.881Z"),
    //     lastMessage: "i am user 2 msg2 i am user 2 msg2",
    //     name: "Qasim QasimQasimQasim Qasim",
    //     senderId: "672be0caa2179d2f0c77965b",
    //     unreadCount: 1));
    // resp.add(CommunityChatUserModel(
    //     image: kCNN,
    //     community: '67ac65cee9e64d015cfa52e3',
    //     lastMessageTime: DateTime.parse("2025-02-16T02:50:20.940Z"),
    //     lastMessage: "bue",
    //     name: "Sadaf",
    //     senderId: "66f43359afe0c2b995a4b93f",
    //     unreadCount: 0));
    // resp.add(CommunityChatUserModel(
    //     image: kProfileImage,
    //     community: '67ac65cee9e64d015cfa52e3',
    //     lastMessageTime: DateTime.parse("2025-02-16T01:27:11.020Z"),
    //     lastMessage: "test message test message test message test message test message test message",
    //     name: "Qasim",
    //     senderId: "672be0caa2179d2f0c77965b",
    //     unreadCount: 5));
    // if (resp.isEmpty) {
    //   isCommunityChatsLoading.value = false;
    //   return;
    // }
    if (resp != null) {
      allCommunityChatUsers.clear();
      filteredCommunityChats.clear();
      allCommunityChatUsers.value = (resp.data ?? []);
      printLogs('========getAllCommunityChats resp  check ${resp.data}');
      printLogs('========getAllCommunityChats resp allCommunityChatUsers check ${allCommunityChatUsers.isEmpty}');
      allCommunityChatUsers.refresh();

      printLogs('========getAllCommunityChats resp allCommunityChatUsers before refresh check ${allCommunityChatUsers.isEmpty}');

      printLogs('========getAllCommunityChats resp allCommunityChatUsers aftere refresh check ${allCommunityChatUsers.isEmpty}');
      // filteredCommunityChats.addAll(allCommunityChatUsers);
      filteredCommunityChats.value = List.from(allCommunityChatUsers);
      printLogs('========getAllCommunityChats resp filteredCommunityChats before refresh check ${filteredCommunityChats.isEmpty}');
      filteredCommunityChats.refresh();

      printLogs('========getAllCommunityChats resp filteredCommunityChats after refresh check ${filteredCommunityChats.isEmpty}');
      printLogs('========getAllCommunityChats allCommunityChatUsers check ${allCommunityChatUsers.isEmpty}');
      printLogs('========getAllCommunityChats filteredCommunityChats check ${filteredCommunityChats.isEmpty}');

      isCommunityChatsLoading.value = false;
      printLogs('========getAllCommunityChats filteredCommunityChats isCommunityChatsLoading ${filteredCommunityChats.isEmpty}');
      printLogs('========getAllCommunityChats  isCommunityChatsLoading ${isCommunityChatsLoading.value}');
      filterSearchCommunity(searchChat.text);
    }
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      filteredChatUsers.value = allChatUsers;
    } else {
      filteredChatUsers.value = allChatUsers
          .where((user) => user.name.toLowerCase().contains(query.toLowerCase()) || user.chat.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void filterSearchCommunity(String query) {
    printLogs('========filterSearchCommunity allCommunityChatUsers check ${allCommunityChatUsers.isEmpty}');
    printLogs('========filterSearchCommunity filteredCommunityChats check ${filteredCommunityChats.isEmpty}');
    if (query.isEmpty) {
      filteredCommunityChats.value = allCommunityChatUsers;
    } else {
      filteredCommunityChats.value = allCommunityChatUsers
          .where((user) =>
              user.name != null && user.name!.toLowerCase().contains(query.toLowerCase()) ||
              user.description != null && user.description!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    printLogs('========filteredCommunityChats ${filteredCommunityChats.isEmpty}');
  }

  void setupSocketListeners() {
    final socket = ChatSocketService.instance.socket;

    socket?.onConnect((_) {
      isSocketConnect.value = true;
      fetchChats();
    });

    socket?.onDisconnect((_) {
      isSocketConnect.value = false;
    });

    socket?.onReconnect((_) {
      fetchChats();
    });

    socket?.onError((data) {
      isSocketConnect.value = false;
    });

    socket?.onConnectError((data) {
      isSocketConnect.value = false;
    });
  }

  Future<void> fetchChats() async {
    final socket = ChatSocketService.instance.socket;
    List<ChatUser> newChatUsers = [];
    allChatUsers.clear();
    newChatUsers = await ChatRepo().getAllChats(SessionService().user?.id ?? '');
    // printLogs("==============newChatUsers date check ${newChatUsers[0].userId} --- ${newChatUsers[0].date} ---${newChatUsers[0].name}");
    allChatUsers.value = (newChatUsers);
    allChatUsers.refresh();
    /*socket?.emit('getChattedUsers', SessionService().user?.id ?? '');
    socket?.on('allChattedUsers', (data) {
      log("Received all chatted users: $data");
      if (data == null) return;
      final existingUserIds = allChatUsers.map((user) => user.userId).toSet();
      final List<ChatUser> newChatUsers = [];
      for (var chat in data) {
        final tempChatadata = ChatUser.fromJson(chat);
        if (!existingUserIds.contains(tempChatadata.userId)) {
          newChatUsers.add(tempChatadata);
          existingUserIds.add(tempChatadata.userId);
        }
      }
      allChatUsers.addAll(newChatUsers);
      allChatUsers.refresh();
    });*/
  }

  ///fn to get All users chats by userid with sockets
  void fetchChatsSockets() {
    final socket = ChatSocketService.instance.socket;
    socket?.emit('getChattedUsers', SessionService().user?.id ?? '');
    socket?.on('allChattedUsers', (data) {
      log("Received all chatted users: $data");
      if (data == null) return;
      final existingUserIds = allChatUsers.map((user) => user.userId).toSet();
      final List<ChatUser> newChatUsers = [];
      for (var chat in data) {
        final tempChatadata = ChatUser.fromJson(chat);
        if (!existingUserIds.contains(tempChatadata.userId)) {
          newChatUsers.add(tempChatadata);
          existingUserIds.add(tempChatadata.userId);
        }
      }
      allChatUsers.addAll(newChatUsers);
      allChatUsers.refresh();
    });
  }

  Future<void> getChatBetweenTwoUsers(String user1Id, String user2Id, String name, String image) async {
    final socket = ChatSocketService.instance.socket;
    // socket?.emit('getChats', [user1Id, user2Id]);
    List<MessageModel> chats = [];
    /*socket?.on('allChats', (data) async {
      log('Chats between users: $data');
      chats.addAll(data
          .map<MessageModel>((chat) => MessageModel.fromJson(chat))
          .toList());
      singleChatController.clear();
      singleChatController.addAll(chats);
      singleChatController.refresh();
    });
    socket?.on('receiveChat', (data) {
      log('Received chat: $data');
      singleChatController.add(MessageModel.fromJson(data));
      singleChatController.refresh();
    });*/
    chats.clear();
    chats = await ChatRepo().getAllChatsByReceiverId(user1Id, user2Id);

    singleChatController.clear();
    singleChatController.addAll(chats);
    singleChatController.refresh();

    chattedUserName.value = name;

    chattedUserImage.value = image;
    chattedUserId.value = user2Id;
  }

  ///fn with sockets
  ///not in use
  void getChatBetweenTwoUsersSockets(String user1Id, String user2Id, String name, String image) {
    final socket = ChatSocketService.instance.socket;
    socket?.emit('getChats', [user1Id, user2Id]);
    List<MessageModel> chats = [];

    socket?.on('allChats', (data) {
      printLogs('Chats between users: $data');
      chats.clear();
      chats.addAll(data.map<MessageModel>((chat) => MessageModel.fromJson(chat)).toList());
      singleChatController.clear();
      singleChatController.addAll(chats);
      singleChatController.refresh();
    });
    socket?.on('receiveChat', (data) {
      printLogs('Received chat: $data');
      singleChatController.add(MessageModel.fromJson(data));
      singleChatController.refresh();
    });
    chattedUserName.value = name;
    chattedUserImage.value = image;
    chattedUserId.value = user2Id;
  }

  void sendMessage(
    String text, {
    required String sender,
    required String receiver,
    required String receiverName,
    required bool isAudioFile,
  }) async {
    final socket = ChatSocketService.instance.socket;

    if (isAudioFile) {
      /*isAudioMesgSending.value = true;
      final msg = MessageModel(
        sender: sender,
        receiver: receiver,
        isRead: true,
        audioMessage: text,
        id: 'temp',
        date: DateTime.now(),
        version: 1,
      );
      singleChatController.add(msg);
      singleChatController.refresh();
      File file = File(text);
      Uint8List fileBytes = await file.readAsBytes();

      socket?.emit('sendChat', [
        sender,
        receiver,
        false,
        fileBytes,
      ]);
      NotificationRepo().sendNotification(userId: receiver, title: "New Audio Message", body: "Audio Message");
      clearRecording();
      isAudioMesgSending.value = false;*/
    } else {
      socket?.emit('sendChat', [
        sender,
        receiver,
        "",
        "",
        text,
      ]);

      /*socket?.on('allChats', (data) {
        singleChatController.add(MessageModel.fromJson(data));
        singleChatController.refresh();
      });*/
      NotificationRepo().sendNotification(userId: receiver, title: "New Message", body: "${SessionService().user?.name} has shared a post with you");
      CustomSnackbar.showSnackbar('Shared with $receiverName');
      message.clear();
    }
  }

  void startOrStopRecording() async {
    try {
      if (isRecording.value) {
        recorderController.reset();
        path.value = await recorderController.stop(false) ?? '';
        if (path.value.isNotEmpty) {
          isRecordingCompleted.value = true;
          printLogs(path.value);
          printLogs("Recorded file size: ${File(path.value).lengthSync()}");
        }
      } else {
        await getDir().then((value) async {
          await recorderController.record(
            path: path.value,
            androidEncoder: AndroidEncoder.aac,
            androidOutputFormat: AndroidOutputFormat.aac_adts,
            iosEncoder: IosEncoder.kAudioFormatAMR,
          );
        });
      }
    } catch (e) {
      printLogs(e.toString());
    } finally {
      isRecording.value = !isRecording.value;
    }
  }

  Future<void> getDir() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    path.value = "${appDirectory.path}/recording.m4a";
  }

  void clearRecording() {
    isRecordingCompleted.value = false;
    path.value = '';
    isRecording.value = false;
    recorderController.reset();
  }

  RxList<UserDetailModel> followingUsers = <UserDetailModel>[].obs;
  void filterBottomSheetSearch(String value) {
    if (value.isEmpty) {
      followingUsers.value = SessionService().following;
    } else {
      followingUsers.value = SessionService().following.where((user) => user.name.toLowerCase().contains(value.toLowerCase())).toList();
    }
  }

  @override
  void onClose() {
    ChatSocketService.instance.disconnectSocket();
    super.onClose();
    videoController?.dispose();
    _timer?.cancel();
  }

  void initializeVideoController(String videoUrl) {
    videoController = CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl));
    // videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    videoController?.initialize().then((_) {
      videoController?.controller.play();
      videoController?.controller.setLooping(true);
      Get.toNamed(kChatVideoViewPostsRoute);
      Get.find<HomeScreenController>().updateViewCount(
        postId: Get.find<HomeScreenController>().posts[index].id,
        index: index,
      );
      update();
    });
  }

  // HomeScreenController homeScreenController = Get.find<HomeScreenController>();
  PostModel? post;
  int index = 0;
  onMessageTap(MessageModel message) {
    index = Get.find<HomeScreenController>().posts.indexWhere((element) => element.id == message.sharedPost.id);
    post = Get.find<HomeScreenController>().posts[index];
    initializeVideoController(message.sharedPost.video);
  }

  RxInt totalPages = 1.obs;
  RxInt currentPage = 1.obs;
  loadMoreData(String communityId) {
    printLogs('current page in load mmore ${currentPage.value}');
    if (currentPage.value <= totalPages.value) {
      getCommunityMessages(communityId);
    }
  }

  RxBool isLoadingMoreData = false.obs;
  getCommunityMessages(String communityId) async {
    if (currentPage.value == 1) {
      isLoading.value = true;
    } else {
      isLoadingMoreData.value = true;
    }
    if (currentPage.value <= totalPages.value) {
      CommunityMessagesDataModel? latestMessages = await ChatRepo().getCommunityMessages(SessionService().user!.id, communityId, currentPage.value);
      printLogs('============latestMessages $latestMessages');
      if (latestMessages != null) {
        totalPages.value = latestMessages.totalPages ?? 1;

        printLogs('=============current page ${currentPage.value}');
        printLogs('=============totalPages page ${totalPages.value}');
        if (currentPage.value == 1) {
          communityMessagesModel.value = latestMessages;
          communityModel.value = communityMessagesModel.value?.community;
          singleCommunityChatMessagesController.value = communityMessagesModel.value?.chats ?? [];
          singleCommunityChatMessagesController.sort((a, b) => a.date!.compareTo(b.date!));
        } else {
          communityMessagesModel.value = latestMessages;
          communityModel.value = communityMessagesModel.value?.community;
          if (communityMessagesModel.value != null && communityMessagesModel.value?.chats != null) {
            singleCommunityChatMessagesController.addAll(communityMessagesModel.value!.chats!);
          }
          singleCommunityChatMessagesController.sort((a, b) => a.date!.compareTo(b.date!));
        }
        currentPage.value++;
        if (totalPages > 1 && singleCommunityChatMessagesController.length < 20) {
          loadMoreData(communityId);
        }
      }
    }
    isLoading.value = false;
    isLoadingMoreData.value = false;
  }

  RxBool isCommunityMessageSent = true.obs;
  sendCommunityMessage({required String text, required String communityID}) async {
    message.clear();
    isCommunityMessageSent.value = true;
    final socket = CommunityChatSocketService.instance.socket;
    if (socket == null) {
      printLogs('CommunityChatSocketService Socket is not initialized');
      return;
    }
    printLogs('==============socket $socket');
    //Manager ID
    var arg1 = {"community": communityID, "senderId": SessionService().user?.id, "message": text, "senderType": "User"};

    printLogs('======arg1 $arg1');

    socket.on('communitiesJoined', (data) {
      printLogs('communitiesJoined response: $data');
    });

    socket.on('communityChats', (data) {
      printLogs('communityChats before sending message response: $data');
      if (data != null) {
        message.clear();
        messageText.value = '';
        // communityMessagesModel.value = communityMessagesModelFromJson(jsonEncode(data));
        CommunityMessagesDataModel latestMessages = CommunityMessagesDataModel.fromJson(data);
        communityMessagesModel.value = latestMessages;
        communityModel.value = communityMessagesModel.value?.community;
        singleCommunityChatMessagesController.value = communityMessagesModel.value?.chats ?? [];
        singleCommunityChatMessagesController.sort((a, b) => a.date!.compareTo(b.date!));
        currentPage.value = 1;
      }
    });

    socket.on('error', (data) {
      printLogs('Error: $data');
    });

    socket.emit('sendCommunityChat', [
      arg1,
    ]);

    socket.on('disconnect', (_) {
      printLogs('Socket disconnected');
    });

    socket.on('communitiesJoined', (data) {
      printLogs('After event managerNotification response: $data');
    });

    socket.on('communityChats', (data) {
      printLogs('communityChats after sending response: $data');
      if (data != null) {
        isCommunityMessageSent.value = true;
        message.clear();
        messageText.value = '';
        //CommunityMessagesDataModel.fromJson
        CommunityMessagesDataModel latestMessages = CommunityMessagesDataModel.fromJson(data);
        communityMessagesModel.value = latestMessages;
        // communityMessagesModel.value = communityMessagesModelFromJson(jsonEncode(data));
        communityModel.value = communityMessagesModel.value?.community;
        singleCommunityChatMessagesController.value = communityMessagesModel.value?.chats ?? [];
        singleCommunityChatMessagesController.sort((a, b) => a.date!.compareTo(b.date!));
        currentPage.value = 1;
      }
      printLogs('communityChats after sending response singleCommunityChatMessagesController: ${singleCommunityChatMessagesController.length}');
    });

    printLogs('===========sendCommunityChat emitted');
  }

  // Group messages by date
  Map<String, List<CommunityChatMessages>> groupMessagesByDate(List<CommunityChatMessages> messages) {
    final groups = <String, List<CommunityChatMessages>>{};

    for (var message in messages) {
      final date = DateFormat('MMMM dd, yyyy').format((message.date!));
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(message);
    }

    return groups;
  }

  initScrollController() {
    // Initialize scroll listener
    scrollController.addListener(() {
      // Show button if scrolled up (not at bottom)
      if (scrollController.hasClients) {
        final isAtBottom = scrollController.position.pixels == scrollController.position.minScrollExtent;
        showScrollButton.value = !isAtBottom;
      }
      if (((scrollController.position.pixels == scrollController.position.maxScrollExtent) || singleCommunityChatMessagesController.length <= 20) &&
          totalPages > 1) {
        loadMoreData(communityModel.value!.id ?? "");
      }
    });
  }

  // Function to scroll to bottom
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> leaveCommunityChat({required String communityId}) async {
    isLoading.value = true;
    bool isLeaveCommunityChat = await ChatRepo().leaveCommunity(SessionService().user?.id ?? "", communityId ?? "");
    printLogs('======================leaveCommunityChat $isLeaveCommunityChat');

    if (isLeaveCommunityChat != null) {
      isFirstTimeLoad.value = true;
      Get.back();
      getAllCommunityChats();
    }
    isLoading.value = false;
  }

  onCommunityTap({required CommunityAllChatsModelData notification}) async {
    isFirstTimeLoad.value = true;
    if (notification.members != null &&
        notification.members!.isNotEmpty &&
        notification.members!.indexWhere((element) => element.memberId == SessionService().user!.id && element.isLeft == false) != -1) {
      isAlreadyMemeber.value = true;
      await joinCommunityChat(notification: notification);
    } else {
      isAlreadyMemeber.value = false;
      Get.dialog(JoinChatDialog(
          image: notification.image,
          isLoading: isJoinCommunityLoading,
          btnLabel: 'Join Chat',
          titleText: notification.name!.toUpperCase(),
          endTime: notification.endTime,
          onTap: () {
            // Get.back();
            joinCommunityChat(notification: notification);
          },
          description: notification.description ?? "No Description Found"
          // '🏆 The ultimate showdown is here! Join the live chat for ${notification.name?.toUpperCase()} and experience the action with fellow fans—debate, celebrate, and share every moment! 🔥💬',
          ));
    }
  }

  RxBool isJoinCommunityLoading = false.obs;
  RxBool isAlreadyMemeber = false.obs;
  Future<void> joinCommunityChat({required CommunityAllChatsModelData notification}) async {
    isLoadingFullScreen.value = true;
    isJoinCommunityLoading.value = true;
    Community? joinedCommunity;
    UserCommunitiesModelData? userCommunitiesModelData;
    if (isAlreadyMemeber.isFalse) {
      joinedCommunity = await ChatRepo().joinCommunity(SessionService().user?.id ?? "", notification.id ?? "");
      getAllCommunityChats();
    } else {
      userCommunitiesModelData = await ChatRepo().getUserCommunities(SessionService().user?.id ?? "");
      if (userCommunitiesModelData != null) {
        int index = userCommunitiesModelData.communities?.indexWhere((element) => element.id == notification.id) ?? -1;
        if (index != -1) {
          UserCommunity userCommunity = userCommunitiesModelData.communities![index];
          joinedCommunity = Community(
            name: userCommunity.name,
            image: userCommunity.image,
            id: userCommunity.id,
            endTime: userCommunity.endTime,
          );
        }
      }
    }

    printLogs('======================joinedCommunity $joinedCommunity');

    if (joinedCommunity != null) {
      if (isAlreadyMemeber.isFalse) {
        Get.back();
        isJoinCommunityLoading.value = false;
        isLoadingFullScreen.value = false;
        Get.dialog(
          JoinChatDialog(
            isLoading: isJoinCommunityLoading,
            endTime: null,
            btnLabel: 'View Chat',
            titleText: 'Chat Joined',
            image: notification.image,
            onTap: () {
              Get.back();
              Get.toNamed(kSingleCommunityChatScreen, arguments: {"joinedCommunity": joinedCommunity});
            },
            description: 'You’ve successfully joined the “${joinedCommunity.name}” community chat',
          ),
          barrierColor: Colors.black.withOpacity(0.55),
        );
      } else {
        Get.back();
        isJoinCommunityLoading.value = false;
        isLoadingFullScreen.value = false;
        Get.toNamed(kSingleCommunityChatScreen, arguments: {"joinedCommunity": joinedCommunity});
      }
    } else {
      isJoinCommunityLoading.value = false;
      isLoadingFullScreen.value = false;
    }
  }

  ///chat timer
  final Rx<DateTime> endTime = Rx<DateTime>(DateTime.parse("2025-02-18T01:57:28.000Z"));
  final RxString timeText = "".obs;
  Timer? _timer;
  //
  // @override
  // void onInit() {
  //   super.onInit();
  //   updateTimeText(); // Initial update
  //   startTimer();
  // }
  //
  // @override
  // void onClose() {
  //   _timer?.cancel();
  //   super.onClose();
  // }

  void startTimer() {
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTimeText();

      // printLogs("===========checking time now local ${DateTime.now().toLocal()}");
      // printLogs("===========checking time now without local ${DateTime.now()}");
      // printLogs("===========checking time endTime.value local ${endTime.value.toLocal()}");
      // printLogs("===========checking time endTime.value without local ${endTime.value}");
      // Check if time has expired
      DateTime now = DateTime.now().isUtc ? DateTime.now() : DateTime.now().toUtc();
      if (now.isAfter(endTime.value)) {
        _timer?.cancel();
        timeText.value = "This Chat has ended";
      }
    });
  }

  void updateTimeText() {
    final now = DateTime.now().isUtc ? (DateTime.now()) : (DateTime.now().toUtc());

    final nowString = DateTime.parse(now.toIso8601String());

    printLogs('=========now (endTime.value) now ${now}');
    printLogs('=========now (endTime.value) nowString ${nowString}');
    printLogs('=========now.isBefore(endTime.value) ${now.isBefore(endTime.value)}');
    printLogs('=========now.isAfter(endTime.value) ${now.isAfter(endTime.value)}');
    printLogs('=========(endTime.value) timeZoneName ${(endTime.value.timeZoneName)}');
    printLogs('=========(endTime.value) ${(endTime.value)}');
    printLogs('=========(endTime.value) local ${(endTime.value.toLocal())}');
    printLogs('=========(endTime.value)compare  ${(endTime.value.compareTo(now))}');
    bool isBefore = now.millisecondsSinceEpoch <= endTime.value.millisecondsSinceEpoch;
    printLogs('==========difference isBefore $isBefore');
    // Calculate remaining time
    if (now.isBefore(endTime.value)) {
      final difference = endTime.value.difference(now);
      printLogs('==========difference $difference');
      int days = difference.inDays;
      int hours = difference.inHours.remainder(24);
      int minutes = difference.inMinutes.remainder(60);
      printLogs('==========days $days , hours: $hours, minutes : $minutes');
      if (days > 0) {
        timeText.value = "This Chat will end in $days day${days > 1 ? 's' : ''}";
      } else if (hours > 0 && minutes > 0) {
        timeText.value = "This Chat will end in $hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}";
      } else if (hours > 0) {
        timeText.value = "This Chat will end in $hours hour${hours > 1 ? 's' : ''}";
      } else if (minutes > 0) {
        timeText.value = "This Chat will end in $minutes minute${minutes > 1 ? 's' : ''}";
      } else {
        int seconds = difference.inSeconds.remainder(60);
        timeText.value = "This Chat will end in $seconds second${seconds > 1 ? 's' : ''}";
      }
      CustomSnackbar.showTimerSnackbar(timeText.value);
    } else {
      // printLogs("===========checking time now local ********* ${DateTime.now().toLocal()}");
      // printLogs("===========checking time now without local ********* ${DateTime.now()}");
      // printLogs("===========checking time now without local ********* ${DateTime.now().toUtc()}");
      // printLogs("===========checking time endTime.value local ********* ${endTime.value.toLocal()}");
      // printLogs("===========checking time endTime.value without local ********* ${endTime.value}");
      // printLogs("===========checking time endTime.value without local ********* ${endTime.value.toUtc()}");
      timeText.value = "This Chat has ended";
      CustomSnackbar.showTimerSnackbar(timeText.value);
    }
  }

  // Helper method to set a new end time if needed
  void setEndTime(DateTime isoString) {
    try {
      printLogs('==========isoString $isoString');
      endTime.value = isoString;
      // endTime.value = DateTime.parse(isoString);
      updateTimeText();
    } catch (e) {
      printLogs("Invalid date format: $e");
    }
  }

  showIntroMessage(String message) {
    Get.dialog(
      barrierColor: kBlackColor.withOpacity(0.5),
      AlertDialog(
        // contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        backgroundColor: kBlackColor.withOpacity(0.8),
        content: Text(
          message,
          style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 14.sp),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'OK',
                style: AppStyles.labelTextStyle().copyWith(color: kPrimaryColor, fontSize: 16.sp, fontWeight: FontWeight.w700),
              ))
        ],
      ),
    );
  }
}

class ChatSocketService {
  static final ChatSocketService _instance = ChatSocketService._internal();

  io.Socket? socket;

  ChatSocketService._internal();

  static ChatSocketService get instance => _instance;

  void initializeSocket(String uri, {required Map<dynamic, dynamic> queryParams}) {
    socket = io.io(uri, io.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build());

    socket?.connect();
    printLogs("Socket initialized and connected");
  }

  void disconnectSocket() {
    socket?.disconnect();
    socket = null;
    if (kDebugMode) {
      printLogs("Socket disconnected");
    }
  }
}
