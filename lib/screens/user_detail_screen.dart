import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/models/user_model.dart';
import 'package:flutter_api_request_simpler/network_utils/api_controller.dart';

import '../network_utils/api_request_widget.dart';

Map<String, UserData> cachedUser = {};

class UserDetailScreen extends StatefulWidget {
  final UserData user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  ApiRequestController<UserData> controller = ApiRequestController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<UserData>(
        controller: controller,
        endpoint: 'users/${widget.user.login}',
        initialData: cachedUser[widget.user.login],
        fromJson: (json) => UserData.fromJson(json),
        useInitialDataOnly: true,
        onResponseReceived: (response, page) {
          cachedUser.putIfAbsent(widget.user.login!, () => response);
        },
        onSuccess: (response, scrollController) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(response.bio ?? 'No data'),
          );
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
