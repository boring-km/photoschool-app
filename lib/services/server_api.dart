import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/post_response.dart';
import '../dto/school_rank.dart';
import '../dto/school_search_response.dart';
import '../dto/searched_post_detail.dart';
import '../utils/http_custom.dart';

class CustomAPIService {
  static Future checkUserRegistered() async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.getWithJWT("$domain/check", idToken);
    return _getResult(result)['isRegistered'];
  }

  static Future<String> getNickName() async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.getWithJWT("$domain/nickname", idToken);
    final json = _getResult(result);
    return json['nickname'];
  }

  static Future<List<SchoolSearchResponse>> searchSchool(String text) async {
    final domain = dotenv.env["server_domain"]!;
    final httpResult = await Http.get("$domain/school/$text");
    final json = _getResult(httpResult);
    final schools = json['schools'];
    var resultList = <SchoolSearchResponse>[];
    for (var school in schools) {
      // ignore: lines_longer_than_80_chars
      resultList.add(SchoolSearchResponse(school['schoolId'], school['region'], school['schoolName']));
    }
    return resultList;
  }

  static Future<Map<String, dynamic>> getMyPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.getWithJWT("$domain/mypost/$index", idToken);
    final json =  _getResult(result);

    final schoolName = json['schoolName'];
    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      postList.add(PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime']));
    }
    return { "schoolName": schoolName, "posts": postList };
  }

  static Future<Map<String, dynamic>> getOthersPostBy(int apiId, int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/others/$apiId/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime']);
      postResponse.nickname = item['nickname'];
      postList.add(postResponse);
    }
    return { "posts": postList };
  }

  static Future<Map<String, dynamic>> getAwardPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/awards/$index");
    final json = _getResult(result);
    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime']);
      postResponse.nickname = item['nickname'];
      postResponse.awardName = item['awardName'];
      postList.add(postResponse);
    }
    return { "posts": postList };
  }

  static Future<List<SchoolRank>> getSchoolRank() async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/rank");
    final json = _getResult(result);
    final schools = json['topSchools'];
    var schoolList = <SchoolRank>[];
    for (var item in schools) {
      schoolList.add(SchoolRank(item['region'], item['schoolName'], item['sumOfViews'], item['sumOfPosts']));
    }
    return schoolList;
  }

  static Future<Map<String, dynamic>> getAllPosts(int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/all/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime']);
      postResponse.nickname = item['nickname'];
      postList.add(postResponse);
    }
    return { "posts": postList };
  }

  static Future<List<PostResponse>> searchPost(String searchType, String searchText, String sortType, int index) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/$searchType/$sortType/$searchText/$index");
    final json = _getResult(result);

    final posts = json['posts'];
    var postList = <PostResponse>[];
    for (var item in posts) {
      var postResponse = PostResponse(item['postId'], item['title'], item['likes'], item['views'], item['tbImgURL'], item['regTime']);
      postResponse.nickname = item['nickname'];
      postList.add(postResponse);
    }
    return postList;
  }

  static Future<SearchedPostDetail> searchDetailPost(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final result = await Http.get("$domain/post/detail/$postId");
    final json = _getResult(result);
    final post = json['post'];
    final detailResult = SearchedPostDetail(post['title'], post['nickname'], post['apiId'], post['likes'], post['views'], post['imgURL'], post['regTime']);
    return detailResult;
  }

  static Future likeOrNotLike(int postId) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.postWithJWT("$domain/post/like", idToken, { "postId": "$postId" });
    return _getResult(result)['result'];
  }

  static Future<int> registerPost(int apiId, String title) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.postWithJWT("$domain/register/post", idToken, { "apiId": "$apiId", "title": title });
    return _getResult(result)['result'];
  }

  static Future<bool> updateImage(int postId, String tbImgURL, String imgURL) async {
    final domain = dotenv.env["server_domain"]!;
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final result = await Http.patchWithJWT("$domain/update/image",
        idToken, { "postId": "$postId", "tbImgURL": tbImgURL, "imgURL": imgURL });
    return _getResult(result)['result'];
  }

  static dynamic _getResult(Map<String, dynamic> result) {
    if (result['error'] == null) {
      return jsonDecode(result['data']);
    } else {
      return '${result['errorCode']}';
    }
  }
}