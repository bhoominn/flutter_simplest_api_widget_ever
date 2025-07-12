class UserResponse {
  bool? status;
  List<UserData>? data;

  UserResponse({this.status, this.data});

  UserResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <UserData>[];
      json['data'].forEach((v) {
        data!.add(new UserData.fromJson(v));
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
  }
}

class UserData {
  int? id;
  String? login;
  String? title;
  String? bio;
  String? location;

  UserData({this.id, this.login, this.title, this.bio, this.location});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    login = json['login'];
    title = json['title'];
    bio = json['bio'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['login'] = this.login;
    data['bio'] = this.bio;
    data['title'] = this.title;
    data['location'] = this.location;
    return data;
  }
}
