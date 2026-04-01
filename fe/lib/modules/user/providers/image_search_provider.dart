// lib/modules/user/providers/image_search_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/config/api.dart';
import '../models/product_model.dart';

class ImageSearchProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _analysis;
  List<ProductModel> _results = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get analysis => _analysis;
  List<ProductModel> get results => _results;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.BASE_URL,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<void> searchByImage(File imageFile) async {
    _isLoading = true;
    _error = null;
    _results = [];
    _analysis = null;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'search_image.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConfig.SEARCH_BY_IMAGE,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _analysis = data['analysis'] as String?;
        final productList = data['products'] as List? ?? [];
        _results = productList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        _error = 'Quá thời gian chờ. Vui lòng thử lại.';
      } else {
        _error = e.response?.data?['message'] as String? ??
            'Lỗi kết nối đến server';
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _results = [];
    _analysis = null;
    _error = null;
    notifyListeners();
  }
}
