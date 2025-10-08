import 'dart:convert';

import 'package:socials_app/models/community_all_chats_model.dart';
import 'package:socials_app/models/user_chat_model.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/http_client.dart';

import '../models/community_message_model.dart';
import '../models/user_communities_model.dart';
import '../utils/common_code.dart';

class ChatRepo {
  late HTTPClient _httpClient;
  static final _instance = ChatRepo._constructor();

  factory ChatRepo() {
    return _instance;
  }

  ChatRepo._constructor() {
    _httpClient = HTTPClient();
  }
/*
  Future<MessageModel?> sendMessage(
    String message, {
    required String sender,
    required String receiver,
  }) async {
    final response = await _httpClient.postRequestWithHeader(
      url: kSendMessageURL,
      body: jsonEncode({
        'message': message,
        'sender': sender,
        'receiver': receiver,
      }),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.data);

      return MessageSendResponseModel.fromJson(jsonData['data']).data;
    } else {
      return null;
    }
  }


  Future<MessageModel?> sendAudioMessage(
    String audioPath, {
    required String sender,
    required String receiver,
  }) async {
    final response = await _httpClient.postMultipartRequestFile(
      url: kSendAudioURL,
      filePath: audioPath,
      isFile: true,
      filed: 'file',
      body: {
        'sender': sender,
        'receiver': receiver,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.data);

      return MessageSendResponseModel.fromJson(jsonData['data']).data;
    } else {
      return null;
    }
  }
*/

  Future<List<ChatUser>> getAllChats(String userId) async {
    final response = await _httpClient.getRequest(url: "$kGetAllChatURL/$userId");
    if (response.statusCode == 200) {
      // Map<String, dynamic> jsonData = jsonDecode(response.data);

      // printLogs('=========chats ${response.data['data']['chats']}');
      List<ChatUser> chats = response.data['data']['chats'].map<ChatUser>((chat) => ChatUser.fromJson(chat)).toList();
      return chats;
    } else {
      return [];
    }
  }

  Future<List<MessageModel>> getAllChatsByReceiverId(String userId, String receiverId) async {
    final response = await _httpClient.getRequest(url: "$kGetAllChatMessagesURL/$userId/$receiverId");
    if (response.statusCode == 200) {
      // Map<String, dynamic> jsonData = jsonDecode(response.data);

      // printLogs('=========chats ${response.data['data']['chats']}');
      List<MessageModel> chats = response.data['data']['chats'].map<MessageModel>((chat) => MessageModel.fromJson(chat)).toList();
      return chats;
    } else {
      return [];
    }
  }

  Future<Community?> joinCommunity(String userId, String communityID) async {
    final response = await _httpClient.putRequestWithHeader(
      url: kJoinCommunityURL,
      body: jsonEncode({"reciever": userId, "community": communityID}),
    );
    bool isSuccess = false;
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.data);

      printLogs("=========chats ${jsonData['success']}");
      isSuccess = jsonData["success"];
      return Community.fromJson(jsonData["data"]);
    } else {
      return null;
    }
  }

  Future<bool> leaveCommunity(String userId, String communityID) async {
    try {
      final response = await _httpClient.putRequestWithHeader(
        url: kLeaveCommunityURL,
        body: jsonEncode({"reciever": userId, "community": communityID}),
      );
      bool isSuccess = false;
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.data);

        printLogs("=========leaveCommunity chats ${jsonData['success']}");
        isSuccess = jsonData["success"];
        return isSuccess; //Community.fromJson(jsonData["data"]);
      } else {
        return false;
      }
    } catch (e) {
      printLogs("leaveCommunity exception $e");
      return false;
    }
  }

  Future<CommunityAllChatsModel?> getAllCommunities(String userId) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetCommunitiesURL?active=true&page=1&limit=50");

    printLogs('===========getAllCommunities response $response');
    printLogs('===========getAllCommunities response.code ${response.statusCode}');
    printLogs('===========getAllCommunities response.data ${response.data}');
    if (response.statusCode == 200) {
      // Map<String, dynamic> jsonData = jsonDecode(response.data);

      // printLogs('=========chats ${response.data['data']['chats']}');
      // List<ChatUser> chats = response.data['data']['chats'].map<ChatUser>((chat) => ChatUser.fromJson(chat)).toList();
      return communityAllChatsModelFromJson((response.data));
    } else {
      return null;
    }
  }

  Future<UserCommunitiesModelData?> getUserCommunities(String userId) async {
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserCommunitiesURL?active=true&page=1&limit=30&senderId=$userId");

    printLogs('===========getAllCommunities response $response');
    printLogs('===========getAllCommunities response.code ${response.statusCode}');
    printLogs('===========getAllCommunities response.data ${response.data}');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.data);

      // printLogs('=========chats ${response.data['data']['chats']}');
      // List<ChatUser> chats = response.data['data']['chats'].map<ChatUser>((chat) => ChatUser.fromJson(chat)).toList();
      return UserCommunitiesModelData.fromJson((jsonData["data"]));
    } else {
      return null;
    }
  }

  Future<CommunityMessagesDataModel?> getCommunityMessages(String userId, String communityId, int pageNo) async {
    final response = await _httpClient.getRequestWithHeader(
        url: "$kGetCommunityMessagesURL?active=true&page=$pageNo&limit=30&userId=$userId&communityId=$communityId");

    printLogs('===========getCommunityMessages response $response');
    printLogs('===========getCommunityMessages response.code ${response.statusCode}');
    printLogs('===========getCommunityMessages response.data ${response.data}');
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.data);

      // printLogs('=========chats ${response.data['data']['chats']}');
      // List<ChatUser> chats = response.data['data']['chats'].map<ChatUser>((chat) => ChatUser.fromJson(chat)).toList();
      return CommunityMessagesDataModel.fromJson((jsonData["data"]));
    } else {
      return null;
    }
  }
}
