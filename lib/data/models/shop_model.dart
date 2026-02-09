class ShopModel {
  final String id;
  final String campusId;
  final String campusName;
  final String name;
  final String category;
  final String contactPhone;
  final String location;
  final String createdBy;
  final DateTime createdAt;

  const ShopModel({
    required this.id,
    required this.campusId,
    required this.campusName,
    required this.name,
    required this.category,
    required this.contactPhone,
    required this.location,
    required this.createdBy,
    required this.createdAt,
  });

  factory ShopModel.fromMap(Map<String, dynamic> map, String docId) {
    return ShopModel(
      id: docId,
      campusId: map['campusId'] ?? '',
      campusName: map['campusName'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      contactPhone: map['contactPhone'] ?? '',
      location: map['location'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'campusId': campusId,
      'campusName': campusName,
      'name': name,
      'category': category,
      'contactPhone': contactPhone,
      'location': location,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
