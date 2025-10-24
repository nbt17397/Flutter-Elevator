class HistoricalData {
  int? id;
  String? type;
  double? value;
  String? timestamp;

  HistoricalData({this.id, this.type, this.value, this.timestamp});

  HistoricalData.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    type = json['type'];
    value = (json['value'] as num?)?.toDouble();
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['value'] = this.value;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
