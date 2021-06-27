import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../dto/dict/dict_detail_response.dart';
import '../dto/dict/dict_main_image_response.dart';
import '../dto/dict/dict_reference.dart';
import '../dto/dict/dict_response.dart';

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

  static Future<List<DictDetailResponse>> searchDetailWJPedia(int pid) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_detail_wjpedia"];
    final response = await HttpWJDict.get("$domain$apiPath$pid");
    final jsonResult = jsonDecode(response['data'])['RESP_RESULT'] as List;
    final resultList = <DictDetailResponse>[];

    if (jsonResult.isNotEmpty) {
      var item = jsonResult[0];
      var categories = item['eduCtgrDetail'];
      var category1 = "";
      var category2 = "";
      var category3 = "";
      if (categories.isNotEmpty) {
        category1 = categories[0]['ctgr1'];
        category2 = categories[0]['ctgr2'];
        category3 = categories[0]['ctgr3'];
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

      var detail = item['headwd_cntt'];

      resultList.add(DictDetailResponse(category1, category2, category3, refList, apiId, name, subName, description, mainImages, detail));
    }

    return resultList;
  }

  static Future searchPhotoLibrary(String keyword) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_photo"];
    final response = await HttpWJDict.get("$domain$apiPath$keyword");
    var array = jsonDecode(response['data'])['RESP_RESULT']['PHOTOLIB']['SEARCH_PHOTOLIB_CONTENTS'];
    return array;
  }

  static Future searchPhotoDetail(int pid) async {
    final domain = dotenv.env["woongjin_domain"]!;
    final apiPath = dotenv.env["woongjin_search_detail_photo"];
    final response = await HttpWJDict.get("$domain$apiPath$pid");
    var data = jsonDecode(response['data'])['RESP_RESULT']['PHOTOLIB'];
    return data;
  }
}