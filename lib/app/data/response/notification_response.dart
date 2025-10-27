// Lớp đại diện cho một mục thông báo
class NotificationDB {
  int? id;
  String? title;
  String? description;
  DateTime? timestamp; 
  int? location;
  
  bool? isConfirm; // Trường mới
  int? level;      // Trường mới

  NotificationDB({
    this.id,
    this.title,
    this.description,
    this.timestamp,
    this.location,
    this.isConfirm,
    this.level,
  });

  // Constructor để tạo đối tượng từ Map (JSON)
  NotificationDB.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    location = json['location'];

    // Xử lý DateTime
    if (json['timestamp'] != null) {
      timestamp = DateTime.parse(json['timestamp']);
    }

    isConfirm = json['is_confirm'];
    level = json['level'];
  }

  // Phương thức để chuyển đối tượng thành Map (JSON)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['location'] = this.location;

    // Chuyển DateTime thành chuỗi
    data['timestamp'] = this.timestamp?.toIso8601String(); 

    // Thêm các trường mới vào Map
    data['is_confirm'] = this.isConfirm;
    data['level'] = this.level;
    
    return data;
  }

  // ⬅️ THÊM PHƯƠNG THỨC copyWith NÀY
  NotificationDB copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? timestamp,
    int? location,
    bool? isConfirm,
    int? level,
  }) {
    return NotificationDB(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      isConfirm: isConfirm ?? this.isConfirm, // Cập nhật isConfirm
      level: level ?? this.level,             // Cập nhật level
    );
  }
}