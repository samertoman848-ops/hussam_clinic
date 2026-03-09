class RoomModel {
  late int? id;
  late String name;

  RoomModel({this.id, required this.name});

  RoomModel.fromMap(Map<String, dynamic> map) {
    id = map['room_id'];
    name = map['room_name'] ?? '';
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['room_id'] = id;
    data['room_name'] = name;
    return data;
  }
}
