import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  final String authToken;
  final String name;
  final String email;
  final String id;

  UserModel({
    required this.authToken,
    required this.name,
    required this.email,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authToken: json['authToken'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': authToken,
      'name': name,
      'email': email,
      '_id': id,
    };
  }

  @override
  String toString() {
    return 'UserModel{authToken: $authToken, name: $name, email: $email, id: $id}';
  }
}

UserResponseModel userResponseModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UserResponseModel.fromJson(jsonData);
}

class UserResponseModel {
  final UserModel user;
  final String message;

  UserResponseModel({
    required this.user,
    required this.message,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : UserModel.fromJson(json['data']),
      message: json['message'],
    );
  }
}

UserDetailResponse userDetailResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return UserDetailResponse.fromJson(jsonData);
}

class UserDetailResponse {
  final bool success;
  final UserDetailModel user;

  UserDetailResponse({
    required this.success,
    required this.user,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      success: json['success'] ?? false,
      user: UserDetailModel.fromJson(json['data']['user']),
    );
  }
}

class UserDetailModel {
  final List<String> favourite;
  List<String> followers;
  List<String> following;
  final bool isAdmin;
  final bool isDeleted;
  final String id;
  final String email;
  final String name;
  final String? password;
  final int v;
  String? image;
  final String? about;
  final String? googleId;
  final String? date;
  final List? deviceIds;

  UserDetailModel({
    required this.favourite,
    required this.followers,
    required this.following,
    required this.isAdmin,
    required this.isDeleted,
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.v,
    this.image,
    required this.about,
    this.googleId,
    this.date,
    this.deviceIds,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      favourite: List<String>.from(json['favourite']),
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      isAdmin: json['isAdmin'],
      isDeleted: json['isDeleted'],
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      password: json['password'] ?? '',
      v: json['__v'],
      image: json['image'] ?? '',
      about: json['about'] ?? '',
      googleId: json['googleId'] ?? '',
      date: json['date'] ?? '',
      deviceIds: json['deviceId'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "favourite": favourite,
      "followers": followers,
      "following": following,
      "isAdmin": isAdmin,
      "isDeleted": isDeleted,
      "_id": id,
      "email": email,
      "name": name,
      "password": password,
      "__v": v,
      "image": image,
      "about": about,
      "googleId": googleId,
      "date": date
    };
  }
}

UserListResponse userListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return UserListResponse.fromJson(jsonData);
}

class UserListResponse {
  final bool success;
  final List<UserDetailModel> users;

  UserListResponse({required this.success, required this.users});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    List<UserDetailModel> users = [];
    if (json['data']['user'] is List) {
      users = (json['data']['user'] as List).map((userJson) => UserDetailModel.fromJson(userJson)).toList();
    }
    return UserListResponse(success: json['success'] ?? false, users: users);
  }
}

/*
* import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  String authToken = "";
  final String name;
  final String email;
  String id = "";
  String password = "";
  bool termAndCondition = false;

  UserModel({
    required this.authToken,
    required this.name,
    required this.email,
    required this.id,
  });
  UserModel.register({
    required this.name,
    required this.email,
    required this.password,
    required this.termAndCondition,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      authToken: json['authToken'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authToken': authToken,
      'name': name,
      'email': email,
      '_id': id,
    };
  }

  Map<String, dynamic> toJsonRegister() {
    return {
      'password': password,
      'name': name,
      'email': email,
      'termAndCondition': termAndCondition,
    };
  }

  @override
  String toString() {
    return 'UserModel{authToken: $authToken, name: $name, email: $email, id: $id}';
  }
}

UserResponseModel userResponseModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UserResponseModel.fromJson(jsonData);
}

class UserResponseModel {
  final UserModel user;
  final String message;

  UserResponseModel({
    required this.user,
    required this.message,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      user: UserModel.fromJson(json['user']),
      message: json['message'],
    );
  }
}

UserDetailResponse userDetailResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return UserDetailResponse.fromJson(jsonData);
}

class UserDetailResponse {
  final bool success;
  final UserDetailModel user;

  UserDetailResponse({
    required this.success,
    required this.user,
  });

  factory UserDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserDetailResponse(
      success: json['success'],
      user: UserDetailModel.fromJson(json['data']['user']),
    );
  }
}

class UserDetailModel {
  final List<String> favourite;
  final List<String> followers;
  final List<String> following;
  final bool isAdmin;
  final bool isDeleted;
  final String id;
  final String email;
  final String name;
  final String? password;
  final int v;
  final String? image;
  final String? about;
  final String? googleId;
  final String? date;

  UserDetailModel({
    required this.favourite,
    required this.followers,
    required this.following,
    required this.isAdmin,
    required this.isDeleted,
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.v,
    this.image,
    required this.about,
    this.googleId,
    this.date,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      favourite: List<String>.from(json['favourite']),
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
      isAdmin: json['isAdmin'],
      isDeleted: json['isDeleted'],
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      password: json['password'] ?? '',
      v: json['__v'],
      image: json['image'] ?? '',
      about: json['about'] ?? '',
      googleId: json['googleId'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "favourite": favourite,
      "followers": followers,
      "following": following,
      "isAdmin": isAdmin,
      "isDeleted": isDeleted,
      "_id": id,
      "email": email,
      "name": name,
      "password": password,
      "__v": v,
      "image": image,
      "about": about,
      "googleId": googleId,
      "date": date
    };
  }
}

UserListResponse userListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return UserListResponse.fromJson(jsonData);
}

class UserListResponse {
  final bool success;
  final List<UserDetailModel> users;

  UserListResponse({required this.success, required this.users});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    List<UserDetailModel> users = [];
    if (json['data']['user'] is List) {
      users = (json['data']['user'] as List).map((userJson) => UserDetailModel.fromJson(userJson)).toList();
    }
    return UserListResponse(success: json['success'], users: users);
  }
}
*/
