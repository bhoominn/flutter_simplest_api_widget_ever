import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/user_detail_screen.dart';
import 'package:nb_utils/nb_utils.dart';

import 'api_controller.dart';
import 'api_request_widget.dart';
import 'main.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  ApiRequestController<List<UserResponse>> controller = ApiRequestController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiRequestWidget<List<UserResponse>>(
        controller: controller,
        endpoint: 'users',
        enablePagination: true,
        showLoading: false,
        //TODO loader widget
        //TODO error widget
        //TODO initial data widget
        //TODO multipart
        //TODO show loader based on condition
        //TODO call API only once if initial data is given based on condition
        doSomethingWithResponse: (response) {
          log('doSomethingWithResponse ${response.length} ${controller.getData.length}');
        },
        onSuccess: (userList, scrollController) {
          return AnimatedListView(
            controller: scrollController,
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
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
        onError: (error, errorWidget) {
          return errorWidget;
        },
        fromJson: (json) => (json as List).map((e) => UserResponse.fromJson(e)).toList(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
