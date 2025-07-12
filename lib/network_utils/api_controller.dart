import 'dart:convert';
import 'dart:io';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import 'api_request_widget.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: baseUrl,
    sendTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    responseType: ResponseType.json,
    headers: buildHeaderTokens(),
  ),
);

Map<String, String> buildHeaderTokens({Map<String, String>? extraHeaders}) {
  Map<String, String> header = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    HttpHeaders.cacheControlHeader: 'no-cache',
    HttpHeaders.acceptHeader: 'application/json; charset=utf-8',
  };

  if (extraHeaders != null) header.addAll(extraHeaders);
  log(jsonEncode(header));
  return header;
}

class ApiRequestController<T> {
  ApiRequestWidgetState<T>? _state;
  CancelToken? _cancelToken;

  T get getData => _state?.response as T;

  void setResponse(T data) {
    _state?.response = data;
    updateWidget();
  }

  /// Append to list (if response is List<T>)
  void appendData(List<dynamic> newItems) {
    if (_state?.response is List) {
      final current = List.from(_state!.response as List);
      current.addAll(newItems);
      setResponse(current as T);
    }
  }

  /// Prepend to list
  void prependData(List<dynamic> newItems) {
    if (_state?.response is List) {
      final current = List.from(_state!.response as List);
      final updated = [...newItems, ...current];
      setResponse(updated as T);
    }
  }

  void updateWidget() {
    _state?.updateWidget();
  }

  void bind(ApiRequestWidgetState<T> state) => _state = state;

  void _setBaseUrl(String endPoint) {
    Uri url = Uri.parse(endPoint);

    if (endPoint.startsWith('http')) {
      url = Uri.parse(endPoint);
    } else {
      url = Uri.parse('$baseUrl$endPoint');
    }

    if (isWeb) dio.httpClientAdapter = BrowserHttpClientAdapter();
    dio.options.baseUrl = url.toString();
  }

  Future<dynamic> callApi(Uri uri, Map<String, dynamic>? body, HttpMethodType method, {Map<String, String>? headers}) async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) return;
    _cancelToken = CancelToken();
    _setBaseUrl(uri.toString());

    final options = Options(headers: buildHeaderTokens(extraHeaders: headers));

    try {
      log('URL: ${dio.options.baseUrl}');

      Response response;
      switch (method) {
        case HttpMethodType.GET:
          response = await dio.get(dio.options.baseUrl, options: options, cancelToken: _cancelToken);
          break;
        case HttpMethodType.POST:
          response = await dio.post(dio.options.baseUrl, data: body, options: options, cancelToken: _cancelToken);
          break;
        case HttpMethodType.PUT:
          response = await dio.put(dio.options.baseUrl, data: body, options: options, cancelToken: _cancelToken);
          break;
        case HttpMethodType.DELETE:
          response = await dio.delete(dio.options.baseUrl, data: body, options: options, cancelToken: _cancelToken);
          break;
      }

      _cancelToken?.cancel();
      return await _handleResponse(response);
    } catch (e) {
      _cancelToken?.cancel();
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    log('URL: ${response.requestOptions.baseUrl}');
    if (response.requestOptions.method == HttpMethodType.POST.name) {
      log('Request: ${jsonEncode(response.requestOptions.data)}');
    }
    log('Response (${response.requestOptions.method} ${response.statusCode}): ${response.data}');
    log('------------------------------------------------------');

    if (response.statusCode.validate().isSuccessful()) {
      if (response.data is Map && response.data.containsKey('status')) {
        if (response.data['status']) {
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

  dynamic _handleError(dynamic error) {
    if (error is DioException) {
      log('[DIO ERROR] ${error.message} ${error.type}');
      log('[RESPONSE] ${error.response?.data}');

      final statusCode = error.response?.statusCode;

      if (statusCode == 401 || statusCode == 403) {
        throw "Unauthorized access.";
      } else if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw "Request timed out.";
      } else if (error.type == DioExceptionType.connectionError || error.message?.contains("SocketException") == true) {
        throw errorInternetNotAvailable;
      } else {
        throw errorSomethingWentWrong;
      }
    } else {
      log(error);
      throw error;
    }
  }

  void cancel() {
    _cancelToken?.cancel();
  }

  void _unbind() => _state = null;

  void refresh({bool showLoading = true}) => _state?.refresh(showLoading: showLoading);

  void nextPage() => _state?.nextPage();

  void retry() {
    _state?.init();
    _state?.updateWidget();
  }

  void dispose() {
    cancel();
    _unbind();
  }
}
