import 'package:nb_utils/nb_utils.dart';

class ServiceResponse extends JsonModel {
  bool? get status => getField<bool>('status');

  List<ServiceData>? get services => getModelList<ServiceData>('data', ServiceData.fromJson);

  ServiceResponse({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(fields: json);
  }
}

class ServiceData extends JsonModel {
  int? get id => getField<int>('id');

  String? get name => getField<String>('name');

  String? get provider_image => getField<String>('provider_image');

  String? get description => getField<String>('description');

  List<String>? get attchments => getFieldList<String>('attchments');

  ServiceData({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(fields: json);
  }
}
