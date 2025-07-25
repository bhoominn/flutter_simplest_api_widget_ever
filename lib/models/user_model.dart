import 'package:nb_utils/nb_utils.dart';

class UserResponse extends JsonModel {
  UserResponse({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(fields: json);

  bool? get status => getField<bool>('status');

  List<UserData>? get data => getField<List<dynamic>>('data')?.map((e) => UserData.fromJson(e as Map<String, dynamic>)).toList();
}

class UserData extends JsonModel {
  UserData({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(fields: json);

  int? get id => getField<int>('id');

  String? get login => getField<String>('login');

  String? get title => getField<String>('title');

  String? get bio => getField<String>('bio');

  String? get location => getField<String>('location');
}
