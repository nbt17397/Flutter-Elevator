class LocationResponse {
  int? count;
  List<LocationDB>? results;

  LocationResponse({this.count, this.results});

  LocationResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['results'] != null) {
      results = <LocationDB>[];
      json['results'].forEach((v) {
        results!.add(new LocationDB.fromJson(v));
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

class LocationDB {
  int? id;
  List<BoardDB>? boards;
  String? name;
  bool? active;
  String? description;
  double? lat;
  double? lng;
  List<int>? authorizedUsers;

  LocationDB(
      {this.id,
      this.boards,
      this.name,
      this.active,
      this.description,
      this.lat,
      this.lng,
      this.authorizedUsers});

  LocationDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['boards'] != null) {
      boards = <BoardDB>[];
      json['boards'].forEach((v) {
        boards!.add(new BoardDB.fromJson(v));
      });
    }
    name = json['name'];
    active = json['active'];
    description = json['description'];
    lat = json['lat'];
    lng = json['lng'];
    authorizedUsers = json['authorized_users'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.boards != null) {
      data['boards'] = this.boards!.map((v) => v.toJson()).toList();
    }
    data['name'] = this.name;
    data['active'] = this.active;
    data['description'] = this.description;
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['authorized_users'] = this.authorizedUsers;
    return data;
  }
}

class GroupDB {
  int? id;
  String? name;
  String? description;

  GroupDB({this.id, this.name, this.description});

  GroupDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
  }
}

class BoardDB {
  int? id;
  String? name;
  String? createdDate;
  String? updatedDate;
  bool? active;
  String? deviceId;
  String? description;
  bool? status;
  int? location;
  List<int>? authorizedUsers;
  List<GroupDB>? groups;
  double? capacity;

  BoardDB(
      {this.id,
      this.name,
      this.createdDate,
      this.updatedDate,
      this.active,
      this.deviceId,
      this.description,
      this.status,
      this.location,
      this.authorizedUsers,this.groups,
      this.capacity});

  BoardDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    active = json['active'];
    deviceId = json['device_id'];
    description = json['description'];
    status = json['status'];
    location = json['location'];
    authorizedUsers = json['authorized_users'].cast<int>();
    if (json['groups'] != null) {
      groups = <GroupDB>[];
      json['groups'].forEach((v) {
        groups!.add(new GroupDB.fromJson(v));
      });
    }
    capacity = json['capacity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['created_date'] = this.createdDate;
    data['updated_date'] = this.updatedDate;
    data['active'] = this.active;
    data['device_id'] = this.deviceId;
    data['description'] = this.description;
    data['status'] = this.status;
    data['location'] = this.location;
    data['authorized_users'] = this.authorizedUsers;
    data['capacity'] = this.capacity;
    return data;
  }
}
