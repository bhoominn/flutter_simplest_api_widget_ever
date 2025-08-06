import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../config.dart';
import 'api_controller.dart';

class ApiRequestWidget<T> extends StatefulWidget {
  final ApiRequestController controller;
  final String endpoint;
  final T Function(dynamic json) fromJson; // can parse single or list

  final Widget Function(T response, ScrollController? scrollController)?
  onSuccess;
  final Widget Function(String error, Widget errorWidget)? onError;

  final HttpMethodType method;
  final Map<String, dynamic>? body;
  final Map<String, String>? queryParams;

  final bool showLoading;
  final Widget? loaderWidget;

  final bool enablePagination;
  final String pageKey;

  final void Function(T response, int page)? onResponseReceived;

  final T? initialData;
  final bool useInitialDataOnly;
  final bool skipInitialCall;

  final Widget? defaultWidget;

  const ApiRequestWidget({
    super.key,
    required this.controller,
    required this.endpoint,

    /// fromJson can parse single or list
    /// For single response - fromJson: (json) => MyModel.fromJson(json),
    /// For list response - fromJson: (json) => (json as List).map((e) => MyModel.fromJson(e)).toList(),
    required this.fromJson,
    this.onSuccess,
    this.onError,
    this.method = HttpMethodType.GET,
    this.body,
    this.showLoading = true,
    this.enablePagination = false,
    this.pageKey = "page",
    this.queryParams,
    this.onResponseReceived,
    this.defaultWidget,
    this.loaderWidget,
    this.initialData,
    this.useInitialDataOnly = false,
    this.skipInitialCall = false,
  });

  @override
  State<ApiRequestWidget<T>> createState() => ApiRequestWidgetState<T>();
}

class ApiRequestWidgetState<T> extends State<ApiRequestWidget<T>> {
  ScrollController? scrollController;
  Future<T>? _future;

  Map<String, dynamic>? body;
  Map<String, String>? queryParams;

  bool _isLoading = true;
  String? _error;
  T? response;
  int _currentPage = 1;
  bool isLastPage = false;

  late bool _skipInitialCall;

  @override
  void initState() {
    super.initState();
    body = widget.body;
    queryParams = widget.queryParams;
    widget.controller.bind(this);
    _skipInitialCall = widget.skipInitialCall;

    if (widget.enablePagination) {
      scrollController = ScrollController();
    }
    if (!widget.skipInitialCall) {
      afterBuildCreated(() {
        init();
      });
    }
  }

  void init() async {
    _future = fetchData().catchError((e) {
      throw e;
    });
  }

  void updateWidget() {
    setState(() {});
  }

  Future<T> fetchData() async {
    setState(() {
      _skipInitialCall = false;
      _isLoading = widget.showLoading;
      _error = null;
    });

    if (widget.initialData != null && widget.useInitialDataOnly) {
      return widget.initialData!;
    }
    try {
      final query = Map<String, dynamic>.from(queryParams ?? {});

      if (widget.enablePagination) {
        query[widget.pageKey] = _currentPage.toString();
      }

      final uri = Uri.parse(widget.endpoint).replace(queryParameters: query);

      final response = await widget.controller.callApi(
        uri,
        body,
        widget.method,
      );

      Iterable extractDataList(dynamic resp) {
        if (resp is Map && resp['data'] is List) {
          return resp['data'];
        } else if (resp is List) {
          return resp;
        } else {
          return [];
        }
      }

      // Let fromJson handle parsing logic whether it's a List or Map
      if (widget.enablePagination) {
        if (this.response == null) {
          // First page
          final dataList = extractDataList(response);
          final parsedData = widget.fromJson(dataList);
          this.response = parsedData;
          isLastPage = (parsedData as List).isEmpty;
        } else {
          // Next pages
          final dataList = extractDataList(response);
          final parsedData = widget.fromJson(dataList);

          // Clear the list if it's the first page
          if (_currentPage == 1) (this.response as List).clear();

          (this.response as List).addAll(parsedData as Iterable);
          isLastPage = (parsedData as List).length != perPageItem;
        }
      } else {
        // Not paginated – handle full object, list or object with 'data'
        if (response is Map &&
            response.containsKey('data') &&
            response['data'] is List) {
          final parsedData = widget.fromJson(response['data']);
          this.response = parsedData;
        } else if (response is List) {
          final parsedData = widget.fromJson(response);
          this.response = parsedData;
        } else {
          final parsedData = widget.fromJson(response);
          this.response = parsedData;
        }
      }

      widget.onResponseReceived?.call(this.response as T, _currentPage);
      _isLoading = false;

      setState(() {});

      return this.response as T;
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });

      throw _error.toString();
    }
  }

  void nextPage() {
    if (widget.enablePagination && !isLastPage) {
      _currentPage++;
      init();
    }
  }

  void refresh({bool showLoading = true}) {
    _isLoading = showLoading;
    _currentPage = 1;
    init();
  }

  @override
  Widget build(BuildContext context) {
    if (_skipInitialCall) {
      return widget.defaultWidget ?? Offstage();
    }
    return FutureBuilder(
      future: _future,
      initialData: widget.initialData,
      builder: (_, snap) {
        if (snap.hasError) {
          if (widget.onError != null) {
            return widget.onError!(
              snap.error.toString(),
              NoDataWidget(
                title: snap.error.toString(),
                onRetry: widget.controller.retry,
              ),
            );
          } else {
            return NoDataWidget(
              title: snap.error.toString(),
              onRetry: widget.controller.retry,
            );
          }
        } else if (snap.hasData) {
          return Stack(
            children: [
              if (widget.onSuccess != null)
                widget.onSuccess!(snap.data as T, scrollController),
              if (_isLoading)
                widget.loaderWidget ?? const Center(child: Loader()),
            ],
          );
        } else {
          if (!widget.showLoading) return Offstage();
          return widget.loaderWidget ?? const Center(child: Loader());
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController?.dispose();
    //widget.controller.dispose();
    super.dispose();
  }
}
