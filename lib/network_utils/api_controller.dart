import 'dart:convert';
import 'dart:io';

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:nb_utils/nb_utils.dart';

import '../config.dart';
import 'api_request_widget.dart';
import 'network_utils.dart';

// Use the shared Dio instance and error constants
final Dio dio = NetworkUtilsShared.dio;

class ApiRequestController<T> {
  ApiRequestWidgetState<T>? _state;
  CancelToken? _cancelToken;

  T get getData => _state?.response as T;

  void setResponse(T data) {
    _state?.response = data;
    updateWidget();
  }

  void setBody(Map<String, dynamic>? _body) => _state?.body = _body;

  void setQueryParams(Map<String, String>? _queryParams) =>
      _state?.queryParams = _queryParams;

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

    NetworkUtilsShared.setupWebAdapter();
    dio.options.baseUrl = url.toString();
  }

  Future<dynamic> callApi(
    Uri uri,
    Map<String, dynamic>? body,
    HttpMethodType method, {
    Map<String, String>? headers,
  }) async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) return;
    _cancelToken = CancelToken();
    _setBaseUrl(uri.toString());

    final requestHeaders = NetworkUtilsShared.buildHeaders(
      extraHeaders: headers,
    );

    try {
      return await NetworkUtilsShared.makeRequest(
        dio.options.baseUrl,
        method,
        body: body,
        headers: requestHeaders,
        cancelToken: _cancelToken,
      );
    } catch (e) {
      _cancelToken?.cancel();

      if (e is DioException) {
        final statusCode = e.response?.statusCode;

        if (statusCode == 401) {
          // await login();
          if (getStringAsync("token").isNotEmpty) {
            return await callApi(uri, body, method, headers: headers);
          }
        }
      }
      throw e;
    }
  }

  void cancel() {
    _cancelToken?.cancel();
  }

  void _unbind() => _state = null;

  void refresh({bool showLoading = true}) =>
      _state?.refresh(showLoading: showLoading);

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
