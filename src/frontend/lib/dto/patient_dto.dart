class PatientDto {
  final int? id;
  final String name;
  final int age;

  PatientDto({this.id, required this.name, required this.age});

  factory PatientDto.fromJson(Map<String, dynamic> json) {
    return PatientDto(id: json['id'], name: json['name'], age: json['age']);
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) "id": id, "name": name, "age": age};
  }
}
