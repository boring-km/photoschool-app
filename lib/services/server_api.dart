import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../dto/post/award_response.dart';

import '../dto/post/post_response.dart';
import '../dto/post/searched_post_response.dart';
import '../dto/school/school.dart';
import '../dto/school/school_rank.dart';
import '../dto/school/school_search_response.dart';
import '../utils/geocode.dart';
import '../utils/http_custom.dart';

class CustomAPIService {
  static Future checkUserRegistered() async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.getWithJWT("$domain/check", idToken);
    return _getResult(result)['isRegistered'];
  }

  static Future<Map<String, dynamic>> getNickName(User user) async {
    final idToken = await user.getIdToken();
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.getWithJWT("$domain/nickname", idToken);
    final json = _getResult(result);
    print(json);
    return { "nickname": json['nickname'], "isAdmin": json['isAdmin'] };
  }

  static Future<List<SchoolSearchResponse>> searchSchool(String text) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/school/$text");
    final json = _getResult(result);
    final schools = json['schools'];
    var resultList = <SchoolSearchResponse>[];
    for (var school in schools) {
      // ignore: lines_longer_than_80_chars
      resultList.add(SchoolSearchResponse(school['schoolId'], school['region'], school['schoolName']));
    }
    return resultList;
  }

  static Future<School> getMySchool() async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.getWithJWT("$domain/mySchool", idToken);
    final json = _getResult(result)['result'];
    var latLng = await GoogleGeoCoding.getLatLng(json['address']);
    return School(json['region'], json['schoolName'], latLng);
  }

  static Future<Map<String, dynamic>> getMyPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.getWithJWT("$domain/mypost/$index", idToken);
    final json = _getResult(result);

    final schoolName = json['schoolName'];
    final awards = json['awards'];
    final awardMap = <int, Award>{};
    if (awards != null) {
      for (var item in awards) {
        awardMap[item['postId']] = Award(item['postId'], item['awardName'], item['month']);
      }
    }

    final posts = json['posts'];
    final postList = <PostResponse>[];
    for (var item in posts) {
      var postId = item['postId'];
      var response = PostResponse(postId, item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      response.isApproved = item['isApproved'];
      response.isRejected = item['isRejected'];
      if (awardMap.containsKey(postId)) {
        response.awardName = awardMap[postId]!.awardName;
        response.month = awardMap[postId]!.month;
      }
      postList.add(response);
    }
    return { "schoolName": schoolName, "posts": postList };
  }

  static Future<List<PostResponse>> getOthersPostBy(String apiId, int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/others/$apiId/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      postResponse.nickname = item['nickname'];
      postList.add(postResponse);
    }
    return postList;
  }

  static Future<List<PostResponse>> getAwardPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/awards/$index");
    final json = _getResult(result);
    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      postResponse.nickname = item['nickname'];
      postResponse.awardName = item['awardName'];
      postResponse.month = item['month'].toString();
      postResponse.schoolName = item['schoolName'];
      postList.add(postResponse);
    }
    return postList;
  }

  static Future<List<SchoolRank>> getSchoolRank(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/rank/$index");
    final json = _getResult(result);
    final schools = json['topSchools'];
    var schoolList = <SchoolRank>[];
    for (var item in schools) {
      schoolList.add(SchoolRank(item['region'], item['schoolName'], item['sumOfViews'], item['sumOfPosts'], item['address']));
    }
    return schoolList;
  }

  static Future<List<PostResponse>> getAllPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/all/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      postResponse.nickname = item['nickname'];
      postResponse.schoolName = item['schoolName'];
      postList.add(postResponse);
    }
    return postList;
  }

  static Future<List<PostResponse>> searchPost(String searchType, String searchText, String sortType, int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/$searchType/$sortType/$searchText/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      postResponse.nickname = item['nickname'];
      postResponse.schoolName = item['schoolName'];
      postList.add(postResponse);
    }
    return postList;
  }

  static Future<SearchedPostResponse> searchDetailPost(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/detail/$postId");
    final json = _getResult(result);
    final post = json['post'];
    final detailResult = SearchedPostResponse(post['title'], post['nickname'], post['apiId'], post['likes'], post['views'], post['imgURL'], post['regTime']);
    detailResult.region = post['region'];
    detailResult.schoolName = post['schoolName'];
    return detailResult;
  }

  static Future checkDoLikeBefore(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.getWithJWT("$domain/check/like/$postId", idToken);
    return _getResult(result)['result'];
  }

  static Future likeOrNotLike(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.postWithJWT("$domain/post/like", idToken, { "postId": "$postId" });
    return _getResult(result)['result'];
  }

  static Future<int> registerPost(String apiId, String title) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.postWithJWT("$domain/register/post", idToken, { "apiId": "$apiId", "title": title });
    return _getResult(result)['result'];
  }

  static Future registerUser(String nickname, int schoolId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.postWithJWT("$domain/register/user", idToken,
        { "nickname": nickname, "schoolId": "$schoolId" });
    return _getResult(result)['result'];
  }

  static Future changePostTitle(String title, int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.patchWithJWT("$domain/update/title", idToken,
      { "postId": "$postId", "title": title });
    return _getResult(result)['result'];
  }

  static Future updateImage(int postId, String tbImgURL, String imgURL) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.patchWithJWT("$domain/update/image",
        idToken, { "postId": "$postId", "tbImgURL": tbImgURL, "imgURL": imgURL });
    return _getResult(result)['result'];
  }

  static Future deleteImage(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.deleteWithJWT("$domain/delete/$postId", idToken);
    return _getResult(result)['result'];
  }

  static Future<List<PostResponse>> getNotApprovedPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/admin/posts/$index");
    final posts = _getResult(result)['posts'];
    final resultList = <PostResponse>[];
    for (var item in posts) {
      var post = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime'], item['upTime']);
      post.isApproved = item['isApproved'];
      post.isRejected = item['isRejected'];
      post.imgURL = item['imgURL'];
      post.apiId = item['apiId'];
      resultList.add(post);
    }
    return resultList;
  }

  static Future sendApproval(int postId, String approval) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.patchWithJWT("$domain/admin/approval", idToken, {
      "postId": "$postId",
      "approval": approval,
    });
    return _getResult(result)['result'];
  }

  static dynamic _getResult(Map<String, dynamic> result) {
    if (result['error'] == null) {
      return jsonDecode(result['data']);
    } else {
      throw '${result['errorCode']}';
    }
  }
}