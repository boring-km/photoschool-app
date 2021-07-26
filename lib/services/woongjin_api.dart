import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/dict/dict_detail_response.dart';
import '../dto/dict/dict_main_image_response.dart';
import '../dto/dict/dict_reference.dart';
import '../dto/dict/dict_response.dart';
import '../dto/photos/photo_detail_response.dart';
import '../dto/photos/photo_response.dart';
import '../utils/http_custom.dart';
import '../utils/http_wjdict.dart';

class WoongJinAPIService {
  static Future<List<DictResponse>> searchWJPedia(String keyword) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_wjpedia"];
    final response = await HttpWJDict.get("$domain$apiPath$keyword");
    var jsonResult = jsonDecode(response['data'])['RESP_RESULT'];
    var searchedItemList = jsonResult['SEARCH_WORD_WJPEDIA_MEAN'];
    var resultList = <DictResponse>[];

    if (searchedItemList.isNotEmpty) {
      for (var item in searchedItemList) {
        var imageList = item['ONLY_IMG_FILE'];
        var imageURLs = <String>[];
        if (imageList.isNotEmpty) {
          for (var url in imageList) {
            imageURLs.add(url['FILE_PATH']);
          }
        }
        var apiId = item['DICT_SEQ'];
        var name = item['HEADWD'];
        var subName = item['ORG_HEADWD'];
        var description = item['HEAD_WORD_DSCR'];
        var isExactly = name == keyword;
        var dictResponse = DictResponse(apiId, name, subName, imageURLs, description, isExactly);
        resultList.add(dictResponse);
      }
    }

    return resultList;
  }

  static Future<DictDetailResponse> searchDetailWJPedia(String pid) async {

    var response = {};

    if (kIsWeb) {
      final domain = dotenv.env["server_domain"]!;
      response = await Http.get("$domain/wjPedia/detail/$pid");
    } else {
      final domain = dotenv.env["woongjin_domain"]!;
      final apiPath = dotenv.env["woongjin_search_detail_wjpedia"];
      response = await HttpWJDict.get("$domain$apiPath$pid");
    }

    final jsonResult = jsonDecode(response['data'])['RESP_RESULT'] as List;

    if (jsonResult.isNotEmpty) {
      var item = jsonResult[0];
      var categories = item['eduCtgrDetail'];
      var category1 = "";
      var category2 = "";
      var category3 = "";
      var categoryNo = "";

      if (categories.isNotEmpty) {
        category1 = categories[0]['ctgr1'];
        category2 = categories[0]['ctgr2'];
        category3 = categories[0]['ctgr3'];
        // categoryNo = categories[0]['ctgr_no'];
      }
      var refs = item['eduRefHead'];
      var refList = <DictReference>[];
      if (refs.isNotEmpty) {
        for (var ref in refs) {
          var refApiId = ref['reltnDictSeq'];
          var order = ref['num'];
          var name = ref['headWd'];
          var dictName = ref['dictNm'];
          refList.add(DictReference(refApiId, name, order, dictName));
        }
      }
      var apiId = item['dict_seq'];
      var name = item['headwd'];
      var subName = item['org_headwd'];
      var description = item['head_word_dscr'];

      var fileList = item['file'];
      var mainImages = <DictMainImageResponse>[];
      if (fileList.isNotEmpty) {
        for (var file in fileList) {
          mainImages.add(DictMainImageResponse(file['dtl_file_thm'], file['dtl_file_dscr']));
        }
      }
      var detail = item['headwd_cntt'] as String;
      detail = detail.replaceAll("\n", "<br/><br/>").replaceAll("<style type='italic'>", "").replaceAll("</style>", "");
      return DictDetailResponse(category1, category2, category3, categoryNo, refList, apiId, name, subName, description, mainImages, detail);
    }
    throw "에러";
  }

  static Future<List<PhotoResponse>> searchPhotoLibrary(String keyword, String category) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_photo"];
    final response = await HttpWJDict.get("$domain$apiPath$keyword");
    final array = jsonDecode(response['data'])['RESP_RESULT']['PHOTOLIB']['SEARCH_PHOTOLIB_CONTENTS'];

    final resultList = <PhotoResponse>[];
    if (array.isNotEmpty) {
      for (var item in array) {
        final imgURL = item['THUMIMG_FILE_PATH'];
        final apiId = item['IMG_CTTS_SEQ'];
        resultList.add(PhotoResponse(apiId, imgURL));
      }
    }
    return resultList;
  }

  static Future<List<PhotoDetailResponse>> searchPhotoDetail(String pid) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_detail_photo"];
    final response = await HttpWJDict.get("$domain$apiPath$pid");
    final array = jsonDecode(response['data'])['RESP_RESULT']['PHOTOLIB']['SEARCH_PHOTOLIB_CONTENTS'];

    final resultList = <PhotoDetailResponse>[];
    if (array.isNotEmpty) {
      for (var item in array) {
        final apiId = item['IMG_CTTS_SEQ'];
        final name = item['CTTS_NAME'];
        final source = item['STPT_USER'];
        final thumbURL = item['THUMIMG_FILE_PATH'];
        final imgURL = item['ORG_IMG_FILE_PATH'];
        final mainCategory = item['MAIN_CTGR_NAME'];
        final subCategory = item['SUB_CTGR_NAME'];
        final description = item['CTTS_DSCR'];
        resultList.add(PhotoDetailResponse(apiId, name, source, thumbURL, imgURL, mainCategory, subCategory, description));
      }
    }

    return resultList;
  }

  static Future<bool> sendDictEmail(String apiId, String name, User user) async {
    final email = await user.email;
    if (email != null) {
      final encodedEmail = base64.encode(utf8.encode(email));
      final emailUrl = dotenv.env["woongjin_email_url"];
      final url = '$emailUrl/$apiId/searchWord/$name/email/$encodedEmail';
      final response = await Http.get(url);
      final result = jsonDecode(response['data'])['RESP_RESULT']['MAIL_RESULT'];
      if (result == 201) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}