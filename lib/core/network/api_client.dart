import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../error/exceptions.dart';

/// API client for making HTTP requests
class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.baseUrl,
                connectTimeout:
                    Duration(milliseconds: AppConstants.connectionTimeout),
                receiveTimeout:
                    Duration(milliseconds: AppConstants.receiveTimeout),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

  /// Performs GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Performs DELETE request
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handles Dio errors and converts to custom exceptions
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection');
      case DioExceptionType.badResponse:
        return ServerException(
          e.response?.statusMessage ?? 'Server error',
          e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      default:
        return const NetworkException('Network error occurred');
    }
  }
}
