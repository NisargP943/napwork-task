import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String privateKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'] ?? '';

  static const String folder = '/napwork';

  /// Dio Initialization
  static final Dio dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Authorization':
                  'Basic ${base64Encode(utf8.encode('$privateKey:'))}',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestHeader: false,
            requestBody: true,
            responseBody: true,
            logPrint: (log) {
              if (kDebugMode) debugPrint(log.toString());
            },
          ),
        );

  /// upload image api
  static Future<void> uploadImage(String imagePath, String name) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
      'fileName': imagePath.split('/').last,
      'folder': folder,
    });
    final response = await dio.post(
      'https://upload.imagekit.io/api/v1/files/upload',
      data: formData,
    );

    await FirebaseFirestore.instance.collection('images').add({
      'url': response.data['url'],
      'reference_name': name,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  static String errorMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out, please try again';
        case DioExceptionType.connectionError:
          return 'No internet connection';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          final data = error.response?.data;
          if (code == 401 || code == 403) return 'Invalid ImageKit key';
          if (data is Map && data['message'] is String) return data['message'];
          return 'Server error ($code)';
        default:
          return 'Upload failed, please try again';
      }
    }
    if (error is FirebaseException) {
      return error.message ?? 'Could not save image details';
    }
    return 'Something went wrong';
  }
}
