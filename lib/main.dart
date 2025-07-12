import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_api_request_simpler/users_list_screen.dart';
import 'package:nb_utils/nb_utils.dart';

const baseUrl = 'https://api.github.com/';
//-d chrome --web-browser-flag "--disable-web-security"
void main() {
  runApp(const MyApp());

  final json = {'id': "123", 'login': 'Bhoomin', 'email': 'b@x.com'};

  final user = UserResponse.fromJson(json);

  print(user.toJsonString(pretty: true));

  // user.toJson();

  print(user.login); // Bhoomin
  print(user.id); // Bhoomin
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

class UserResponse extends JsonModel {
  int? get id => getField<int>('id', defaultValue: 0);

  String? get login => getField<String>('login');

  String? get title => getField<String>('title');

  String? get location => getField<String>('location');

  UserResponse({Map<String, dynamic>? fields}) {
    registerFields(fields ?? {});
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(fields: json);
  }
}

abstract class JsonModel {
  final Map<String, dynamic> _fieldMap = {};

  /// Automatically register all fields passed to constructor
  void registerFields(Map<String, dynamic> fields) {
    _fieldMap.addAll(fields);
  }

  /// Update values from JSON map
  /*void fromJson(Map<String, dynamic> json) {
    for (var key in json.keys) {
      if (_fieldMap.containsKey(key)) {
        _fieldMap[key] = json[key];
      }
    }
  }*/

  /// Get a typed value from the map
  // T? getField<T>(String key) => _fieldMap[key] as T;

  T? getField<T>(String key, {T? defaultValue}) {
    final value = _fieldMap[key];

    if (value == null) return defaultValue;

    if (value is T) {
      return value;
    } else {
      final actualType = value.runtimeType;
      final expectedType = T;
      final errorMessage =
          "❌ Type mismatch for key '$key': Expected <$expectedType>, got <$actualType>.\n"
          "💡 Value: $value";

      log(errorMessage);
      return defaultValue;
    }
  }

  Map<String, dynamic> toJson() => Map.from(_fieldMap);

  String toJsonString({bool pretty = false}) {
    return pretty ? const JsonEncoder.withIndent('  ').convert(_fieldMap) : jsonEncode(_fieldMap);
  }
}
