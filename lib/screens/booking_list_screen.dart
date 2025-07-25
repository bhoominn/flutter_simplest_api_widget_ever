import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/network_utils/api_controller.dart';
import 'package:flutter_api_request_simpler/network_utils/api_request_widget.dart';

import '../models/category_model.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  ApiRequestController<CategoryResponse> controller = ApiRequestController();

  @override
  void initState() {
    super.initState();

    dio
        .post('login', data: {"email": "john@gmail.com", "password": "12345678", "login_type": "email"})
        .then((response) {
          print(response);

          print(response.requestOptions.uri.toString());

          controller.refresh();
        })
        .catchError((e) {
          print(e);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<CategoryResponse>(
        controller: controller,
        endpoint: 'category-list',
        skipInitialCall: true,
        fromJson: (json) => CategoryResponse.fromJson(json),
      ),
    );
  }
}
