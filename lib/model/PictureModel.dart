// CREATE TABLE "patient_pic" (
// "patient_pic_id"	INTEGER NOT NULL UNIQUE,
// "patient_pic_location"	TEXT,
// "patient_pic_patientId"	TEXT,
// PRIMARY KEY("patient_pic_id" AUTOINCREMENT)
class PictureModel {
  int _pictureId = 1; //picture_id
  String _patient_pic_patientId = "mo"; //patientId
  String _pictureLocation = "2";

  int get pictureId => _pictureId;

  set pictureId(int value) {
    _pictureId = value;
  } //picture_location

  PictureModel(dynamic obj) {
    _pictureId = obj["patient_pic_id"]; //picture_id
    _patient_pic_patientId = obj["patient_pic_patientId"]; //patientId
    _pictureLocation = obj["patient_pic_location"]; //picture_location
  }

  PictureModel.fromMap(Map<String, dynamic> data) {
    _pictureId = data["patient_pic_id"]; //picture_id
    _patient_pic_patientId = data["patient_pic_patientId"]; //patientId
    _pictureLocation = data["patient_pic_location"]; //picture_location
   }

  Map<String, dynamic> toMap() => {
        'patient_pic_id': _pictureId, //picture_id
        'patient_pic_patientId': _patient_pic_patientId, //picture_name
        'patient_pic_location': _pictureLocation, //picture_location
      };

  String get patient_pic_patientId => _patient_pic_patientId;

  set patient_pic_patientId(String value) {
    _patient_pic_patientId = value;
  }

  String get pictureLocation => _pictureLocation;

  set pictureLocation(String value) {
    _pictureLocation = value;
  }
}
