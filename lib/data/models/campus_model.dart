class CampusModel {
  final String id;
  final String name;
  final String city;
  final String state;

  const CampusModel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
  });

  factory CampusModel.fromMap(Map<String, dynamic> map, String docId) {
    return CampusModel(
      id: docId,
      name: map['name'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'city': city, 'state': state};
  }
}
