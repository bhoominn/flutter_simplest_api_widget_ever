import 'package:flutter_api_request_simpler/models/json_model.dart';

class ServiceResponse extends JsonModel {
  bool? get status => getField<bool>('status');

  List<ServiceData>? get users => getModelList<ServiceData>('data', ServiceData.fromJson);

  ServiceResponse({Map<String, dynamic>? fields}) {
    registerFields(fields: fields);
  }

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(fields: json);
  }

  /*bool? status;
  List<BookingData>? data;

  BookingResponse({this.status, this.data});

  BookingResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <BookingData>[];
      json['data'].forEach((v) {
        data!.add(new BookingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }*/
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

  /*int? id;
  String? name;
  String? address_line_1;

  BookingData({this.id, this.name, this.address_line_1});

  BookingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address_line_1 = json['address_line_1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address_line_1'] = this.address_line_1;
    return data;
  }*/
}
