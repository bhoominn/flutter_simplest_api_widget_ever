import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/screens/user_list_screen.dart';

const baseUrl = 'https://apps.iqonic.design/frezka/';

Map<String, dynamic> listResponse = jsonDecode(
  '{"status": true, "data": [{"id": 1, "login": "mojombo", "title": "hello", "location": "india"}, {"id": 2, "login": "naik", "title": "how", "location": "surat"}]}',
);

//-d chrome --web-browser-flag "--disable-web-security"
void main() {
  runApp(const MyApp());

  // final user = UserResponse.fromJson(listResponse);

  // print(user.toJsonString(pretty: true));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const UsersListScreen(),
    );
  }
}
