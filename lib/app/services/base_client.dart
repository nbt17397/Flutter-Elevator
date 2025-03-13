import 'package:dio/dio.dart';
import 'package:elevator/utils/constants.dart';

abstract class ApiProvider {

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
      validateStatus: (status) => true,
      receiveDataWhenStatusError: true,
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static void setBearerAuth(String token) {
    _dio.options.headers['Authorization'] = 'Token $token';
  }

  static void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  static void setValidateStatus(ValidateStatus? validateStatus) {
    _dio.options.validateStatus = validateStatus!;
  }

  final Dio httpClient;

  ApiProvider() : httpClient = _dio {
    if (_dio.interceptors.isEmpty) {
      _dio.interceptors.add(
        LogInterceptor(
          error: true,
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }
}
