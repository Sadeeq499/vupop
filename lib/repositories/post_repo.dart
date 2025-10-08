import 'dart:convert';
import 'dart:io';

import 'package:socials_app/models/editors_model.dart';
import 'package:socials_app/models/post_models.dart';
import 'package:socials_app/models/ratings_model.dart';
import 'package:socials_app/models/reasons_report_block_model.dart';
import 'package:socials_app/services/endpoints.dart';
import 'package:socials_app/services/http_client.dart';
import 'package:socials_app/utils/common_code.dart';

import '../models/block_report_model.dart';
import '../models/post_response_model.dart';
import '../models/post_user_views_model.dart';
import '../models/tending_hashtag_model.dart';
import '../services/session_services.dart';

class PostRepo {
  late HTTPClient _httpClient;
  static final _instance = PostRepo._constructor();

  factory PostRepo() {
    return _instance;
  }

  PostRepo._constructor() {
    _httpClient = HTTPClient();
  }

  // Future<PostResponseModelData?> createPost({
  //   required String userId,
  //   required File file,
  //   List<String>? mentions,
  //   String fileType = 'video',
  //   required String locationAdress,
  //   required double lat,
  //   required double lng,
  //   List<String>? tags,
  //   required File thumbnailFile,
  //   required bool isFaceCam,
  //   required bool isPortrait,
  //   void Function(int)? progress,
  // }) async {
  //   Map<String, String> fieldsMention = {"mention[0]": ""};
  //   if (mentions != null && mentions.isNotEmpty) {
  //     fieldsMention = {
  //       for (int i = 0; i < mentions.length; i++) 'mention[$i]': mentions[i]
  //     };
  //   }
  //   Map<String, String> fieldsTags = {"tags[0]": ''};
  //   if (tags != null && tags.isNotEmpty) {
  //     fieldsTags = {for (int i = 0; i < tags.length; i++) 'tags[$i]': tags[i]};
  //   }
  //   printLogs('=============fieldsMention $fieldsMention');
  //   printLogs('=============fieldsTags $fieldsTags');
  //   Map<String, String> fields = {
  //     // 'userId': '6656e2f3e3fd001accdb69af',
  //     // 'mention[0]': '6656e45ae546583fbc278b2d',
  //     // 'tags[0]': '6656e45ae546583fbc278b2d',
  //     'userId': userId,
  //     ...fieldsMention,
  //     ...fieldsTags,
  //     // 'mention': mentions != null ? mentions.join(',') : '',
  //     // 'tags': tags != null ? tags.join(',') : '',
  //     "location[coordinates][0]": lng.toString(),
  //     "location[coordinates][1]": lat.toString(),
  //     "area": locationAdress,
  //     "facecam": '$isFaceCam',
  //     "isPortrait": '$isPortrait'
  //   };

  //   printLogs('===========post create fields $fields');
  //   final response = await _httpClient.postMultipartRequestFileProgress(
  //     url: kCreatePostURL,
  //     body: fields,
  //     isFile: true,
  //     filed: fileType,
  //     filePath: file.path,
  //     thumbnail: thumbnailFile.path,
  //     onProgress: (int sent, int total) {
  //       log('progress: $sent / $total');
  //       if (progress != null) {
  //         progress((sent / total * 100).toInt());
  //         log('Progress: ${(sent / total * 100).toInt()}');
  //       }
  //     },
  //   );

  //   printLogs('Response: ${response.data}');
  //   printLogs('Response.statuscode: ${response.statusCode}');
  //   if (response.statusCode == 200) {
  //     try {
  //       // Map<String, dynamic> jsonData = (response.data);
  //       // printLogs('jsonData: $jsonData');
  //       // printLogs('jsonData2 : ${(jsonData["data"])}');
  //       // printLogs('jsonData3 : ${jsonEncode(jsonData["data"])}');
  //       PostResponseModel postResponseModel =
  //           postResponseModelFromJson(jsonEncode(response.data));

  //       // final data = postModelFromJson(jsonEncode(postResponseModel.data));
  //       /*if (postResponseModel.data != null) {
  //         final data = postModelFromJson(postResponseModelToJson(postResponseModel.data));
  //         printLogs('Data: $data');
  //         return data;
  //       }*/

  //       return postResponseModel.data;
  //     } catch (e) {
  //       printLogs('Error: $e');
  //     }
  //   } else {
  //     printLogs('Response: ${response.statusCode}');
  //   }
  //   return null;
  // }

  Future<PostResponseModelData?> createPost({
    required String userId,
    required File file,
    List<String>? mentions,
    String fileType = 'video',
    required String locationAdress,
    required double lat,
    required double lng,
    List<String>? tags,
    required File thumbnailFile,
    required bool isFaceCam,
    required bool isPortrait,
    bool recordedByVupop = true,
    Map? body,
    void Function(int)? progress,
  }) async {
    printLogs('=======recordedByVupop $recordedByVupop ');
    printToFirebase("recordedByVupop $recordedByVupop");
    Map<String, String> fields = {};
    if (body == null) {
      Map<String, dynamic>? fieldsMention;
      if (mentions != null && mentions.isNotEmpty) {
        fieldsMention = {for (int i = 0; i < mentions.length; i++) 'mention[$i]': mentions[i]};
      }
      Map<String, dynamic>? fieldsTags;
      if (tags != null && tags.isNotEmpty) {
        fieldsTags = {for (int i = 0; i < tags.length; i++) 'tags[$i]': tags[i]};
      }
      // printLogs('=============fieldsMention $fieldsMention');
      // printLogs('=============fieldsTags $fieldsTags');
      fields = {
        // 'userId': '6656e2f3e3fd001accdb69af',
        // 'mention[0]': '6656e45ae546583fbc278b2d',
        // 'tags[0]': '6656e45ae546583fbc278b2d',
        'userId': userId,
        if (fieldsMention != null) ...fieldsMention!,
        if (fieldsTags != null) ...fieldsTags!,
        // 'mention': mentions != null ? mentions.join(',') : '',
        // 'tags': tags != null ? tags.join(',') : '',
        "location[coordinates][0]": lng.toString(),
        "location[coordinates][1]": lat.toString(),
        "area": locationAdress,
        "facecam": '$isFaceCam',
        "isPortrait": '$isPortrait',
        "recordedByVupop": '$recordedByVupop'
      };
    } else {
      Map<String, String> fieldsMention = {"mention[0]": ""};
      if (body['mention'] != null && body['mention'].isNotEmpty) {
        fieldsMention = {for (int i = 0; i < body['mention'].length; i++) 'mention[$i]': body['mention'][i]};
      }
      Map<String, String> fieldsTags = {"tags[0]": ''};
      if (body['tags'] != null && body['tags'].isNotEmpty) {
        fieldsTags = {for (int i = 0; i < body['tags'].length; i++) 'tags[$i]': body['tags'][i]};
      }

      fields = {
        "userId": userId,
        ...fieldsMention,
        ...fieldsTags,
        "location[coordinates][0]": body['lng'].toString(),
        "location[coordinates][1]": body['lat'].toString(),
        "area": body['locationAdress'],
        "facecam": body['isFaceCam'].toString(),
        "isPortrait": body['isPortrait'].toString(),
        "recordedByVupop": body['recordedByVupop'].toString()
      };
    }

    final response = await _httpClient.postMultipartRequestFileProgress(
      url: kCreatePostURL,
      body: fields,
      isFile: true,
      filed: fileType,
      filePath: file.path,
      thumbnail: thumbnailFile.path,
      onProgress: (int sent, int total) {
        if (progress != null) {
          progress((sent / total * 100).toInt());
          printLogs("===========progress $progress");
        }
      },
    );

    printLogs('Response createPost: ${response.data}');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        // Map<String, dynamic> jsonData = (response.data);
        // printLogs('jsonData: $jsonData');
        // printLogs('jsonData2 : ${(jsonData["data"])}');
        // printLogs('jsonData3 : ${jsonEncode(jsonData["data"])}');
        PostResponseModel postResponseModel = postResponseModelFromJson(jsonEncode(response.data));

        // final data = postModelFromJson(jsonEncode(postResponseModel.data));
        /*if (postResponseModel.data != null) {
          final data = postModelFromJson(postResponseModelToJson(postResponseModel.data));
          printLogs('Data: $data');
          return data;
        }*/
        if (mentions != null && mentions.isNotEmpty) {
          for (int i = 0; i < mentions.length; i++) {
            CommonCode()
                .sendMentionNotification(message: "${SessionService().user?.name} mentioned you in a clip", managerID: mentions[i], userID: userId);
          }
        }

        return postResponseModel.data;
      } catch (e) {
        printLogs('Error createPost PostRepo: $e');
      }
    } else {
      printLogs('Response createPost PostRepo: ${response.statusCode}');
    }
    return null;
  }

  /// fn for rating video/post not in use : using set rating method
  Future<RatingResponse?> rateVideoPost({
    required String userId,
    required String videoId,
    required int stars,
  }) async {
    Map<String, String> fields = {
      'userId': userId,
      'stars': stars.toString(),
      'videoId': videoId,
    };
    final body = jsonEncode(fields);
    final response = await _httpClient.postRequestWithHeader(
      url: kSetPostRatingURL,
      body: body,
    );

    printLogs('Response rateVideoPost: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = ratingResponseModelFromJson(jsonEncode(jsonData));
        printLogs('Data: ${data.message}');
        printLogs('Data: $data');
        return data;
      } catch (e) {
        printLogs('Error rateVideoPost PostRepo: $e');
      }
    } else {
      printLogs('Response rateVideoPost PostRepo: ${response.statusCode}');
    }
    return null;
  }

  /// fn to update view count

  Future<PostData?> getUserPosts({
    required String userId,
    dynamic body,
    bool isArchivedPosts = false,
    int pageNum = 1,
  }) async {
    final response = await _httpClient.getRequestWithHeader(
      url: "$kGetPostsByUserId/$userId?archive=$isArchivedPosts&page=$pageNum&limit=20",
    );

    printLogs('Response getUserPosts: $response');
    printLogs('getUserPost Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs("jsonData getUserPost $jsonData");
        final data = ListPostResponse.fromJson(jsonData);
        return data.data;
      } catch (e) {
        printLogs('Error on getUserPost : $e');
      }
    } else {
      printLogs('Response getUserPosts: ${response.statusCode}');
    }
    return null;
  }

  /// get all posts
  Future<PostData?> getAllPosts({
    int pageNum = 1,
    required double lat,
    required double lng,
  }) async {
    printLogs('=======pageNum getAllPost $pageNum');
    final response = await _httpClient.getRequestWithHeader(url: "$kGetUserPostUrl?page=$pageNum&lag=$lng&lat=$lat");
    printLogs('Response getAllPosts: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = response.data is String ? jsonDecode(response.data) : response.data;
        printLogs('jsonData: $jsonData');
        final data = ListPostResponse.fromJson(jsonData);
        printLogs('Data: ${data.data.posts.length}');
        printLogs('total pages: ${data.data.totalPages}');

        return data.data;
      } catch (e) {
        printLogs('Error on getAllPosts : $e');
        return null;
      }
    } else {
      printLogs('Response getAllPosts else: ${response.statusCode}');
      return null;
    }
  }

  /// fn to set rating for video
  Future<RatingResponse?> setRating(double rating, String postId, String userID) async {
    final response = await _httpClient.postRequestWithHeader(
      url: kSetPostRatingURL,
      body: jsonEncode({
        "userId": userID,
        "videoId": postId,
        "stars": rating,
      }),
    );

    printLogs('Response setRating: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = ratingResponseModelFromJson(jsonEncode(jsonData));
        printLogs('Data: ${data.message}');
        printLogs('Data: $data');
        return data;
      } catch (e) {
        printLogs('Error setRating PostRepo: $e');
      }
    } else {
      printLogs('Response setRating PostRepo: ${response.statusCode}');
    }
    return null;
  }

  /// fn to get specific post by id
  /// not in use
  /* Future<PostModel?> getPostById(String postId, {bool isArchivedPosts = false}) async {
    final response = await _httpClient.getRequestWithHeader(
      url: isArchivedPosts ? kGetUserArchivedPostUrl : kGetUserPostUrl,
      body: {"_id": postId},
    );

    printLogs('Response getPostById: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = ListPostResponse.fromJson(jsonData);
        return data.data.posts.first;
      } catch (e) {
        printLogs('Error on getPostById : $e');
      }
    } else {
      printLogs('Response getPostById: ${response.statusCode}');
    }
    return null;
  }*/

  Future<List<Editor>> getActiveEditors() async {
    final response = await _httpClient.getRequestWithHeader(
      url: kGetActiveBroadcasters,
    );

    printLogs('Response getActiveEditors: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = EditorsDataModel.fromJsonBroadcaster(jsonData["data"]);
        return data.editors != null ? data.editors! : [];
      } catch (e) {
        printLogs('Error on GetActiveEditors : $e');
      }
    } else {
      printLogs('Response getActiveEditors: ${response.statusCode}');
    }
    return [];
  }

  /// fn to update user activity
  Future<bool> updateUserActivity({required String postId, String likes = '', String share = '', String views = ''}) async {
    final response = await _httpClient.putRequestWithHeader(
      url: kUpdateUserActivity,
      body: jsonEncode({
        "postId": postId,
        "likes": likes,
        "share": share,
        "views": views,
      }),
    );

    printLogs('Response updateUserActivity: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('updateCount: $jsonData');
        // final data = postModelFromJson(jsonEncode(jsonData['data']));
        // printLogs('Data: $data');
        // return data;
        return true;
      } catch (e) {
        printLogs('Error on updateUserActivity : $e');
        // return null;
        return false;
      }
    } else {
      printLogs('Response updateUserActivity: ${response.statusCode}');
    }
    return false;
  }

  /// fn to set report  video
  Future<BlockReportModel?> reportPost({required String reason, required String postId, required String userID}) async {
    final response = await _httpClient.putRequestWithoutHeader(
      url: kReportingClipURL,
      body: jsonEncode({
        // "isReport": true,
        "ReportedBy": userID,
        "clip": postId,
        "id": reason,
      }),
    );

    printLogs('Response reportPost: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = blockReportModelFromJson(jsonEncode(jsonData));
        printLogs('Data: ${data.message}');
        printLogs('Data: $data');
        return data;
      } catch (e) {
        printLogs('Error reportPost PostRepo: $e');
      }
    } else {
      printLogs('Response reportPost PostRepo: ${response.statusCode}');
    }
    return null;
  }

  /// fn to block the user
  Future<BlockReportModel?> blockUser({required String reasonId, required String blockedUserId, required String userID}) async {
    final response = await _httpClient.putRequestWithoutHeader(
      url: kBlockingUserURL,
      body: jsonEncode({
        "id": reasonId,
        "BlockedBy": userID,
        "blockedUser": blockedUserId,
        // "reason": reason,
      }),
    );

    printLogs('Response blockUser: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = blockReportModelFromJson(jsonEncode(jsonData));
        printLogs('Data: ${data.message}');
        printLogs('Data: $data');

        SessionService().blockedUsers.add(blockedUserId);
        SessionService().saveBlockedUsersList(SessionService().blockedUsers);
        return data;
      } catch (e) {
        printLogs('Error blockUser PostRepo: $e');
      }
    } else {
      printLogs('Response blockUser PostRepo: ${response.statusCode}');
    }
    return null;
  }

  /// fn to update user activity
  Future<String> getPreSignedUrl({
    required String postUrl,
  }) async {
    final response = await _httpClient.putRequestWithHeader(
      url: kGetPreSignedUrl,
      body: jsonEncode({
        "key": postUrl,
      }),
    );

    printLogs('Response getPreSignedUrl: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('updateCount: $jsonData');
        // final data = postModelFromJson(jsonEncode(jsonData['data']));
        // printLogs('Data: $data');
        // return data;
        return jsonData["url"];
      } catch (e) {
        printLogs('Error on updateUserActivity : $e');
        // return null;
        return "";
      }
    } else {
      printLogs('Response getPreSignedUrl: ${response.statusCode}');
    }
    return "";
  }

  /// fn to get report video reasons
  Future<ReasonsBlockReportModel?> getReasonsToBlockReport({bool isReport = true}) async {
    final response = await _httpClient.getRequestWithHeader(
      url: '$kBlockingReportingReasonsURL?isReport=$isReport',
      /*body: jsonEncode({
        "isReport": true,
        "ReportedBy": userID,
        "clip": postId,
        "reason": reason,
      }),*/
    );

    printLogs('Response getReasonsToBlockReport: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('=========jsonData getReasonsToBlockReport $jsonData');
        final data = reasonsBlockReportModelFromJson(jsonEncode(jsonData['data'] ?? jsonData));
        printLogs('Data getReasonsToBlockReport: ${data.toString()}');
        printLogs('Data data.reasons != null: ${(data.reasons != null)}');
        printLogs('Data data.reasons!.isNotEmpty: ${(data.reasons!.isNotEmpty)}');
        if (data.reasons != null && data.reasons!.isNotEmpty) {
          printLogs('in if returning Data getReasonsToBlockReport: ${data}');
          printLogs('in if returning Data getReasonsToBlockReport is not null: ${data != null}');
          return data;
        } else {
          return null;
        }
      } catch (e) {
        printLogs('Error getReasonsToBlockReport PostRepo: $e');
        return null;
      }
    } else {
      printLogs('Response getReasonsToBlockReport PostRepo: ${response.statusCode}');
      return null;
    }
  }

  /// fn to get Trending hashtags
  Future<List<TendingHashTagsData>?> getTrendingHashTags({bool isReport = true}) async {
    final response = await _httpClient.getRequestWithHeader(
      url: kGetTrendingHashtags,
    );

    printLogs('Response getTrendingHashTags: $response');
    printLogs('Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        printLogs('=========jsonData getTrendingHashTags $jsonData');
        final data = trendingHashTagsFromJson(jsonEncode(jsonData));
        printLogs('Data getTrendingHashTags: ${data.toString()}');
        printLogs('Data data.reasons != null: ${(data.data != null)}');
        printLogs('Data data.reasons!.isNotEmpty: ${(data.data!.isNotEmpty)}');
        if (data.data != null && data.data!.isNotEmpty) {
          printLogs('in if returning Data getTrendingHashTags: ${data}');
          printLogs('in if returning Data getTrendingHashTags is not null: ${data != null}');
          return data.data;
        } else {
          return null;
        }
      } catch (e) {
        printLogs('Error getTrendingHashTags PostRepo: $e');
        return null;
      }
    } else {
      printLogs('Response getTrendingHashTags PostRepo: ${response.statusCode}');
      return null;
    }
  }

  ///fn to get user feed

  Future<PostData?> getUserFeedPosts({
    required String userId,
    dynamic body,
    int pageNum = 1,
    required double lat,
    required double lng,
  }) async {
    final response = await _httpClient.getRequestWithHeader(
      url: "$kGetUserFeedPosts/$userId?page=$pageNum&limit=10&lag=$lng&lat=$lat&",
    );

    printLogs('Response getUserFeedPosts: $response');
    printLogs('getUserFeedPosts Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        final data = ListPostResponse.fromJson(jsonData);
        return data.data;
      } catch (e) {
        printLogs('Error on getUserFeedPosts : $e');
      }
    } else {
      printLogs('Response getUserFeedPosts: ${response.statusCode}');
    }
    return null;
  }

  ///fn to get user feed

  Future<PostUserViewsDataModel?> getUserPostViews({
    required String postId,
    int pageNum = 1,
  }) async {
    final response = await _httpClient.getRequestWithHeader(
      url: "$kGetPostViews/$postId?page=$pageNum&limit=10",
    );

    printLogs('Response getUserPostViews: $response');
    printLogs('getUserPostViews Response.statuscode: ${response.statusCode}');
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> jsonData = jsonDecode(response.data);
        // final data = ListPostResponse.fromJson(jsonData);
        PostUserViewsModel postUserViewsModel = postUserViewsModelFromJson(response.data);
        return postUserViewsModel.data;
      } catch (e) {
        printLogs('Error on getUserPostViews : $e');
      }
    } else {
      printLogs('Response getUserPostViews: ${response.statusCode}');
    }
    return null;
  }
}
