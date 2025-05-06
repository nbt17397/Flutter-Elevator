class RequestControlResponse {
  int? count;
  List<RequestControl>? results;

  RequestControlResponse({this.count, this.results});

  RequestControlResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['results'] != null) {
      results = <RequestControl>[];
      json['results'].forEach((v) {
        results!.add(new RequestControl.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RequestControl {
  int? id;
  String? createdAt;
  String? expiresAt;
  bool? isActive;
  int? board;
  int? user;
  String? userName;

  RequestControl(
      {this.id,
      this.createdAt,
      this.expiresAt,
      this.isActive,
      this.board,
      this.user,
      this.userName});

  RequestControl.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = json['created_at'];
    expiresAt = json['expires_at'];
    isActive = json['is_active'];
    board = json['board'];
    user = json['user'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.createdAt;
    data['expires_at'] = this.expiresAt;
    data['is_active'] = this.isActive;
    data['board'] = this.board;
    data['user'] = this.user;
    data['user_name'] = this.userName;
    return data;
  }
}
