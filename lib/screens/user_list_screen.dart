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
        showLoading: false,
        //TODO multipart
        //TODO show loader based on condition
        //TODO call API only once if initial data is given based on condition
        useInitialDataOnly: true,
        initialData: UserResponse(
          status: true,
          data: [
            UserData(login: 'bhoominn', location: 'India'),
            UserData(login: 'mojombo', location: 'India'),
          ],
        ),
        onResponseReceived: (response) {
          log('onResponseReceived ${response.data!.length} ${controller.getData.data!.length}');
        },
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
        // fromJson: (json) => (json as List).map((e) => UserResponse.fromJson(e)).toList(),
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
