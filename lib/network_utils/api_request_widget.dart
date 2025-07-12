import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import 'api_controller.dart';

class ApiRequestWidget<T> extends StatefulWidget {
  final String endpoint;
  final HttpMethodType method;
  final Map<String, dynamic>? body;
  final bool showLoading;
  final bool enablePagination;
  final String pageKey;

  // take onResponseReceived param callback
  final void Function(T response)? onResponseReceived;

  final T Function(dynamic json) fromJson; // can parse single or list
  final Widget Function(T response, ScrollController? scrollController)? onSuccess;
  final Widget Function(String error, Widget errorWidget)? onError;

  final Map<String, dynamic>? queryParams;
  final ApiRequestController controller;

  final Widget? defaultWidget;
  final Widget? loaderWidget;
  final T? initialData;
  final bool useInitialDataOnly;
  final bool skipInitialCall;

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
  bool _isLoading = true;
  String? _error;
  T? response;
  int _currentPage = 1;

  late bool _skipInitialCall;

  @override
  void initState() {
    super.initState();
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
      final query = Map<String, dynamic>.from(widget.queryParams ?? {});

      if (widget.enablePagination) {
        query[widget.pageKey] = _currentPage.toString();
      }

      final uri = Uri.parse(widget.endpoint).replace(queryParameters: query);

      final response = await widget.controller.callApi(uri, widget.body, widget.method);

      // Let fromJson handle parsing logic whether it's a List or Map
      final parsedData = widget.fromJson(response);

      if (parsedData is List && this.response != null && widget.enablePagination) {
        (this.response as List).addAll(parsedData);
      } else {
        this.response = parsedData;
      }
      widget.onResponseReceived?.call(this.response as T);
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
    _currentPage++;
    init();
  }

  void refresh({bool showLoading = true}) {
    // _isLoading = showLoading
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
            return widget.onError!(snap.error.toString(), NoDataWidget(title: snap.error.toString(), onRetry: widget.controller.retry));
          } else {
            return NoDataWidget(title: snap.error.toString(), onRetry: widget.controller.retry);
          }
        } else if (snap.hasData) {
          return Stack(
            children: [
              if (widget.onSuccess != null) widget.onSuccess!(snap.data as T, scrollController),
              // if (_isLoading) widget.loaderWidget ?? const Center(child: Loader()),
            ],
          );
        } else {
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
