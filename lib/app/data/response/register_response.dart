class RegisterResponse {
  int? count;
  List<RegisterDB>? results;

  RegisterResponse({this.count, this.results});

  RegisterResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['results'] != null) {
      results = <RegisterDB>[];
      json['results'].forEach((v) {
        results!.add(new RegisterDB.fromJson(v));
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

class RegisterDB {
  int? id;
  String? name;
  String? createdDate;
  String? updatedDate;
  bool? active;
  String? description;
  int? value;
  String? type;
  bool? status;
  String? topic;

  RegisterDB(
      {this.id,
      this.name,
      this.createdDate,
      this.updatedDate,
      this.active,
      this.description,
      this.value,
      this.type,
      this.status,
      this.topic});

  RegisterDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    active = json['active'];
    description = json['description'];
    value = json['value'];
    type = json['type'];
    status = json['status'];
    topic = json['topic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['created_date'] = this.createdDate;
    data['updated_date'] = this.updatedDate;
    data['active'] = this.active;
    data['description'] = this.description;
    data['value'] = this.value;
    data['type'] = this.type;
    data['status'] = this.status;
    data['topic'] = this.topic;
    return data;
  }
}
