class ChatUser {
  String userId;
  String name;
  String? image;
  String chat;
  DateTime date;
  bool isRead;
  int unReadMessages;

  ChatUser({
    required this.userId,
    required this.name,
    this.image,
    required this.chat,
    required this.date,
    required this.isRead,
    required this.unReadMessages,
  });

  // Factory constructor to create an instance from JSON
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'],
      chat: json['chat'] ?? '',
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
      unReadMessages: json['unReadMessages'] ?? 0,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'image': image,
      'chat': chat,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'unReadMessages': unReadMessages,
    };
  }
}

class MessageSendResponseModel {
  bool success;
  MessageModel data;

  MessageSendResponseModel({
    required this.success,
    required this.data,
  });

  // Factory constructor to create an instance from JSON
  factory MessageSendResponseModel.fromJson(Map<String, dynamic> json) {
    return MessageSendResponseModel(
      success: json['success'] ?? false,
      data: MessageModel.fromJson(json['data']),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class MessageModel {
  bool isRead;
  String id;
  String sender;
  String receiver;
  String message;
  DateTime date;
  int v;
  SharedPost sharedPost;

  MessageModel({
    required this.isRead,
    required this.id,
    required this.sender,
    required this.receiver,
    required this.message,
    required this.date,
    required this.v,
    required this.sharedPost,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        isRead: json["isRead"],
        id: json["_id"],
        sender: json["sender"],
        receiver: json["receiver"],
        message: json["message"] ?? "",
        date: DateTime.parse(json["date"]),
        v: json["__v"],
        sharedPost: json["sharedPost"] != null ? SharedPost.fromJson(json["sharedPost"]) : SharedPost(id: "", video: "", thumbnail: ""),
      );

  Map<String, dynamic> toJson() => {
        "isRead": isRead,
        "_id": id,
        "sender": sender,
        "receiver": receiver,
        "message": message,
        "date": date.toIso8601String(),
        "__v": v,
        "sharedPost": sharedPost.toJson(),
      };
}

class SharedPost {
  String id;
  String video;
  String thumbnail;

  SharedPost({
    required this.id,
    required this.video,
    required this.thumbnail,
  });

  factory SharedPost.fromJson(Map<String, dynamic> json) => SharedPost(
        id: json["_id"],
        video: json["video"],
        thumbnail: json["thumbnail"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "video": video,
        "thumbnail": thumbnail,
      };
}

/*
class MessageModel {
  bool isRead;
  String id;
  String sender;
  String receiver;
  String? message;
  String? audioMessage;
  DateTime date;
  int version;

  MessageModel({
    required this.isRead,
    required this.id,
    required this.sender,
    required this.receiver,
    this.message,
    this.audioMessage,
    required this.date,
    required this.version,
  });

  // Factory constructor to create an instance from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      isRead: json['isRead'] ?? false,
      id: json['_id'] ?? '',
      sender: json['sender'] ?? '',
      receiver: json['receiver'] ?? '',
      message: json['message'] ?? '',
      audioMessage: json['audioMessage'] ?? '',
      date: DateTime.parse(json['date']),
      version: json['__v'] ?? 0,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'isRead': isRead,
      '_id': id,
      'sender': sender,
      'receiver': receiver,
      'message': message,
      'audioMessage': audioMessage,
      'date': date.toIso8601String(),
      '__v': version,
    };
  }
}*/
