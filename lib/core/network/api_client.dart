import 'package:dio/dio.dart';
import 'package:voice_huluca/core/constants/app_constants.dart';
import 'package:voice_huluca/core/errors/error_mapper.dart';
import 'package:voice_huluca/core/storage/secure_storage.dart';

class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient({Dio? dio, SecureStorage? secureStorage, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? AppConstants.apiBaseUrl,
              connectTimeout: AppConstants.connectionTimeout,
              receiveTimeout: AppConstants.apiTimeout,
              sendTimeout: AppConstants.apiTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          ),
      _secureStorage = secureStorage ?? SecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getApiToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final headers = await _getHeaders();
    return _execute(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: headers),
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final headers = await _getHeaders();
    return _execute(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: headers),
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final headers = await _getHeaders();
    return _execute(
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: headers),
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final headers = await _getHeaders();
    return _execute(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: (options ?? Options()).copyWith(headers: headers),
      ),
    );
  }

  Future<Response<T>> upload<T>(
    String path,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
  }) async {
    final fileName = filePath.split('/').last;
    final multipartFile = await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    );
    final formData = FormData.fromMap({
      fileKey: multipartFile,
      if (extraData != null) ...extraData,
    });
    final headers = await _getHeaders();
    return _execute(
      () => _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      ),
    );
  }

  Future<Response<dynamic>> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    final headers = await _getHeaders();
    return _execute(
      () => _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: headers, responseType: ResponseType.bytes),
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  Future<Response<T>> _execute<T>(
    Future<Response<T>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapError(e);
    } catch (e) {
      throw mapError(e);
    }
  }

  void close() {
    _dio.close();
  }
}
