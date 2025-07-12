import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/api_controller.dart';
import 'package:flutter_api_request_simpler/api_request_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import 'main.dart';

class UserDetailScreen extends StatefulWidget {
  final UserResponse user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  ApiRequestController<UserResponse> controller = ApiRequestController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<UserResponse>(
        endpoint: 'users/${widget.user.login}',
        method: HttpMethodType.POST,
        fromJson: (json) => UserResponse.fromJson(json),
        onSuccess: (response, scrollController) {
          return Padding(padding: EdgeInsets.all(8.0), child: Text(response.login ?? 'No Name'));
        },
        onError: (error, errorWidget) {
          return Text(error);
        },
        controller: controller,
        doSomethingWithResponse: (response) {
          //
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
