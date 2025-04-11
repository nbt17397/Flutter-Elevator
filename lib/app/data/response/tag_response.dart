class TagResponse {
  int? count;
  List<TagDB>? results;

  TagResponse({this.count, this.results});

  TagResponse.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['results'] != null) {
      results = <TagDB>[];
      json['results'].forEach((v) {
        results!.add(new TagDB.fromJson(v));
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

class TagDB {
  int? id;
  String? tagCode;
  String? tagName;
  String? description;
  int? maxValue;
  int? minValue;
  int? defaultValue;
  String? createdDate;
  String? updatedDate;
  bool? active;

  TagDB(
      {this.id,
      this.tagCode,
      this.tagName,
      this.description,
      this.maxValue,
      this.minValue,
      this.defaultValue,
      this.createdDate,
      this.updatedDate,
      this.active});

  TagDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tagCode = json['tag_code'];
    tagName = json['tag_name'];
    description = json['description'];
    maxValue = json['max_value'];
    minValue = json['min_value'];
    defaultValue = json['default_value'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tag_code'] = this.tagCode;
    data['tag_name'] = this.tagName;
    data['description'] = this.description;
    data['max_value'] = this.maxValue;
    data['min_value'] = this.minValue;
    data['default_value'] = this.defaultValue;
    data['created_date'] = this.createdDate;
    data['updated_date'] = this.updatedDate;
    data['active'] = this.active;
    return data;
  }
}