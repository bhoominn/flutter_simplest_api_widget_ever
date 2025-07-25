import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/models/user_model.dart';
import 'package:flutter_api_request_simpler/screens/user_detail_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import '../network_utils/api_controller.dart';
import '../network_utils/api_request_widget.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  ApiRequestController<UserResponse> controller = ApiRequestController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<UserResponse>(
        controller: controller,
        endpoint: 'users',
        enablePagination: true,
        onSuccess: (response, scrollController) {
          return AnimatedListView(
            controller: scrollController,
            itemCount: response.data!.length,
            itemBuilder: (context, index) {
              final user = response.data![index];

              return ListTile(
                title: Text(user.login.toString()),
                onTap: () {
                  UserDetailScreen(user: user).launch(context);
                },
              );
            },
            onSwipeRefresh: () {
              controller.refresh();

              return Future.value(true);
            },
            onNextPage: () {
              controller.nextPage();
            },
          );
        },
        fromJson: (json) => UserResponse.fromJson(json),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
