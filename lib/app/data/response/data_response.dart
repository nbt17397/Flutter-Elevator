class DataResponse {
  List<TagData>? data;
  String? id;

  DataResponse({this.data, this.id});

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    return DataResponse(
      data: json['data'] != null
          ? List<TagData>.from(json['data'].map((x) => TagData.fromJson(x)))
          : [],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data?.map((x) => x.toJson()).toList(),
        'id': id,
      };
}

class TagData {
  String? name;
  int? value;

  TagData({this.name, this.value});

  factory TagData.fromJson(Map<String, dynamic> json) {
    String? valueKey =
        json.keys.firstWhere((k) => k.startsWith("value"), orElse: () => "");
    return TagData(
      name: json['name'],
      value: json[valueKey],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}
