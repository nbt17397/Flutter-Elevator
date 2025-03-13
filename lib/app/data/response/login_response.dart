class LoginResponse {
  UserInfo? userInfo;
  String? token;

  LoginResponse({this.userInfo, this.token});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    userInfo = json['user_info'] != null
        ? new UserInfo.fromJson(json['user_info'])
        : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.userInfo != null) {
      data['user_info'] = this.userInfo!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class UserInfo {
  int? id;
  String? username;
  String? email;
  String? deviceToken;
  String? firstName;
  String? lastName;
  String? name;
  bool? isSuperuser;

  UserInfo(
      {this.id,
      this.username,
      this.email,
      this.deviceToken,
      this.firstName,
      this.lastName,
      this.name,
      this.isSuperuser});

  UserInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    deviceToken = json['device_token'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    isSuperuser = json['is_superuser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['device_token'] = this.deviceToken;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['is_superuser'] = this.isSuperuser;
    return data;
  }
}