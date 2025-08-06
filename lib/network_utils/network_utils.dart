import 'dart:convert';
import 'dart:io';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';

import '../config.dart';

/// Shared network utilities that can be used by both NetworkUtils and ApiController
class NetworkUtilsShared {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      responseType: ResponseType.json,
      headers: _buildDefaultHeaders(),
    ),
  );

  /// Build default headers for API requests
  static Map<String, String> _buildDefaultHeaders() {
    return {
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
      HttpHeaders.cacheControlHeader: 'no-cache',
      HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
      HttpHeaders.accessControlAllowHeadersHeader: '*',
      HttpHeaders.accessControlAllowOriginHeader: '*',
    };
  }

  /// Build headers with optional authorization token and extra headers
  static Map<String, String> buildHeaders({
    Map<String, String>? extraHeaders,
    bool includeAuth = true,
  }) {
    Map<String, String> headers = Map.from(_buildDefaultHeaders());

    // Add authorization token if available and requested
    if (includeAuth) {
      final token = getStringAsync('token');
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    // Add extra headers if provided
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// Build the full URL for the request
  /// Automatically detects if endpoint is a full URL or needs base URL appended
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('http')) {
      return endpoint;
    }
    return '$baseUrl$endpoint';
  }

  /// Set up web adapter if needed
  static void setupWebAdapter() {
    if (isWeb) {
      _dio.httpClientAdapter = BrowserHttpClientAdapter();
    }
  }

  /// Get the shared Dio instance
  static Dio get dio => _dio;

  /// Make HTTP request with shared functionality
  static Future<dynamic> makeRequest(
    String url,
    HttpMethodType method, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    CancelToken? cancelToken,
  }) async {
    final options = Options(headers: headers, method: method.name);

    try {
      log('URL: $url');

      Response response;
      switch (method) {
        case HttpMethodType.GET:
          response = await _dio.get(
            url,
            options: options,
            cancelToken: cancelToken,
          );
          break;
        case HttpMethodType.POST:
          response = await _dio.post(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;
        case HttpMethodType.PUT:
          response = await _dio.put(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;
        case HttpMethodType.DELETE:
          response = await _dio.delete(
            url,
            data: body,
            options: options,
            cancelToken: cancelToken,
          );
          break;
      }

      return handleResponse(response);
    } catch (error) {
      logError(error);
      throw handleError(error);
    }
  }

  /// Log request details
  static void logRequest(
    HttpMethodType method,
    String url,
    Map<String, dynamic>? body,
    Map<String, String> headers,
  ) {
    log('🌐 REQUEST: ${method.name} $url');
    if (body != null) {
      log('📦 BODY: ${jsonEncode(body)}');
    }
    log('📋 HEADERS: ${jsonEncode(headers)}');
    log('------------------------------------------------------');
  }

  /// Log response details
  static void logResponse(Response response) {
    log(
      '📥 RESPONSE: ${response.requestOptions.method} ${response.statusCode}',
    );
    log('📄 DATA: ${response.data}');
    log('------------------------------------------------------');
  }

  /// Log error details
  static void logError(dynamic error) {
    log('❌ ERROR: $error');
    log('------------------------------------------------------');
  }

  /// Handle successful response
  static dynamic handleResponse(Response response) {
    if (response.statusCode.validate().isSuccessful()) {
      // Check if response has a status field (common in APIs)
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status'] == true ||
            response.data['status'] == 'success') {
          return response.data;
        } else {
          throw response.data['message'] ?? errorSomethingWentWrong;
        }
      }
      return response.data;
    } else {
      throw errorSomethingWentWrong;
    }
  }

  /// Handle errors
  static String handleError(dynamic error) {
    if (error is DioException) {
      log('[DIO ERROR] ${error.message} ${error.type}');
      log('[RESPONSE] ${error.response?.data}');

      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        return "Unauthorized access. Please login again.";
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return "Request timed out. Please try again.";
      } else if (error.type == DioExceptionType.connectionError ||
          error.message?.contains("SocketException") == true) {
        return errorInternetNotAvailable;
      } else {
        return error.response?.data?['message'] ?? errorSomethingWentWrong;
      }
    } else {
      log('[NETWORK ERROR] $error');
      return error.toString();
    }
  }

  /// Set authorization token
  static void setAuthToken(String token) {
    setValue('token', token);
  }

  /// Clear authorization token
  static void clearAuthToken() {
    removeKey('token');
  }

  /// Get current authorization token
  static String getAuthToken() {
    return getStringAsync('token');
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return getStringAsync('token').isNotEmpty;
  }
}

/// Network utility class for making API calls
class NetworkUtils {
  /// Make a GET request
  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    return await _makeRequest(
      endpoint,
      HttpMethodType.GET,
      queryParams: queryParams,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  /// Make a POST request
  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    return await _makeRequest(
      endpoint,
      HttpMethodType.POST,
      body: body,
      queryParams: queryParams,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  /// Make a PUT request
  static Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    return await _makeRequest(
      endpoint,
      HttpMethodType.PUT,
      body: body,
      queryParams: queryParams,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  /// Make a DELETE request
  static Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    return await _makeRequest(
      endpoint,
      HttpMethodType.DELETE,
      body: body,
      queryParams: queryParams,
      headers: headers,
      includeAuth: includeAuth,
    );
  }

  /// Generic method to make HTTP requests
  static Future<dynamic> _makeRequest(
    String endpoint,
    HttpMethodType method, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    try {
      // Build the full URL
      String fullUrl = NetworkUtilsShared.buildUrl(endpoint);

      // Add query parameters if provided
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(fullUrl).replace(queryParameters: queryParams);
        fullUrl = uri.toString();
      }

      // Build headers
      final requestHeaders = NetworkUtilsShared.buildHeaders(
        extraHeaders: headers,
        includeAuth: includeAuth,
      );

      // Configure Dio options
      final options = Options(headers: requestHeaders, method: method.name);

      // Set up web adapter if needed
      NetworkUtilsShared.setupWebAdapter();

      // Log request details
      NetworkUtilsShared.logRequest(method, fullUrl, body, requestHeaders);

      // Make the request
      Response response;
      switch (method) {
        case HttpMethodType.GET:
          response = await NetworkUtilsShared.dio.get(
            fullUrl,
            options: options,
          );
          break;
        case HttpMethodType.POST:
          response = await NetworkUtilsShared.dio.post(
            fullUrl,
            data: body,
            options: options,
          );
          break;
        case HttpMethodType.PUT:
          response = await NetworkUtilsShared.dio.put(
            fullUrl,
            data: body,
            options: options,
          );
          break;
        case HttpMethodType.DELETE:
          response = await NetworkUtilsShared.dio.delete(
            fullUrl,
            data: body,
            options: options,
          );
          break;
      }

      // Log response
      NetworkUtilsShared.logResponse(response);

      // Handle response
      return NetworkUtilsShared.handleResponse(response);
    } catch (error) {
      NetworkUtilsShared.logError(error);
      throw NetworkUtilsShared.handleError(error);
    }
  }

  /// Set authorization token
  static void setAuthToken(String token) {
    NetworkUtilsShared.setAuthToken(token);
  }

  /// Clear authorization token
  static void clearAuthToken() {
    NetworkUtilsShared.clearAuthToken();
  }

  /// Get current authorization token
  static String getAuthToken() {
    return NetworkUtilsShared.getAuthToken();
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return NetworkUtilsShared.isAuthenticated();
  }
}
