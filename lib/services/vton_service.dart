// lib/services/vton_service.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VtonService {
  final String apiUrl;

  VtonService({this.apiUrl = 'https://b09a-50-173-30-254.ngrok-free.app'});

  /// 1) 사용자 사진 업로드
  Future<String> uploadUserImage(XFile xfile) async {
    final uri = Uri.parse('$apiUrl/api/v1/user/upload-image');
    final bytes = await xfile.readAsBytes();
    final ext = xfile.name
        .split('.')
        .last;
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: xfile.name,
      contentType: MediaType('image', ext),
    );
    final req = http.MultipartRequest('POST', uri)
      ..files.add(multipartFile);
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200) {
      throw Exception('사용자 업로드 실패 (${res.statusCode})');
    }
    return jsonDecode(body)['file_id'] as String;
  }

  /// 2) assets 폴더의 의류 이미지 업로드
  Future<String> uploadClothingFromAsset(String assetPath,
      String category) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final filename = assetPath
        .split('/')
        .last;
    final ext = filename
        .split('.')
        .last;

    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType('image', ext),
    );

    final uri = Uri.parse('$apiUrl/api/v1/clothing/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['category'] = category
      ..files.add(multipartFile);
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200) {
      throw Exception('의류 업로드 실패 (${res.statusCode})');
    }
    return jsonDecode(body)['clothing_id'] as String;
  }

  /// 3) 인체 파싱
  Future<String> humanParsing(XFile xfile) async {
    final uri = Uri.parse('$apiUrl/api/v1/preprocessing/human-parsing');
    final bytes = await xfile.readAsBytes();
    final ext = xfile.name
        .split('.')
        .last;
    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: xfile.name,
      contentType: MediaType('image', ext),
    );
    final req = http.MultipartRequest('POST', uri)
      ..fields['save_visualization'] = 'true'
      ..files.add(multipartFile);
    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200) {
      throw Exception('인체 파싱 실패 (${res.statusCode})');
    }
    return jsonDecode(body)['file_id'] as String;
  }

  /// 4) 가상 피팅 요청
  Future<String> tryOn({
    required String userImageId,
    required String clothingId,
    required String category,
    String? parsingId,
    int numSteps = 30,
    double guidance = 2.0,
  }) async {
    final uri = Uri.parse('$apiUrl/api/v1/tryon/process');
    final payload = {
      'user_image_id': userImageId,
      'clothing_id': clothingId,
      'category': category,
      if (parsingId != null) 'parsing_id': parsingId,
      if (numSteps != 30) 'num_inference_steps': numSteps,
      if (guidance != 2.0) 'guidance_scale': guidance,
    };
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('가상 피팅 실패 (${res.statusCode})');
    }
    return jsonDecode(res.body)['result_id'] as String;
  }

  /// 5) 결과 이미지 다운로드
  Future<Uint8List> downloadResultImage(String resultId) async {
    final uri = Uri.parse('$apiUrl/api/v1/tryon/result/$resultId');
    print('🔍 downloadResultImage → GET $uri');

    final res = await http.get(
      uri,
      headers: {
        'ngrok-skip-browser-warning': 'true', // ngrok 경고 페이지 건너뛰기
      },
    );
    // 에러 시 전체 본문 확인
    if (res.statusCode != 200) {
      print('🔴 downloadResultImage error body: ${res.body}');
      throw Exception('결과 다운로드 실패: ${res.statusCode}');
    }

    // HTML 여부 검사
    final ct = res.headers['content-type'] ?? '';
    if (!ct.startsWith('image/')) {
      throw Exception('다운로드된 응답이 이미지가 아닙니다: content-type=$ct');
    }

    return res.bodyBytes;
  }
}
