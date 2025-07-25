import 'package:nb_utils/nb_utils.dart';

class StatusModel extends JsonModel {
  StatusModel({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory StatusModel.fromJson(Map<String, dynamic> json) => StatusModel(fields: json);

  int? get id => getField<int>('id');

  String? get value => getField<String>('value');

  String? get label => getField<String>('label');
}
