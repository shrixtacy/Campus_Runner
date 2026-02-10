// lib/data/models/task_model.dart

class TaskModel {
  final String id;
  final String requesterId;
  final String title;
  final String pickup;
  final String drop;
  final String price;
  final String status; // 'OPEN', 'ACCEPTED', 'COMPLETED'
  final DateTime createdAt;
  final String campusId;
  final String campusName;
  final String transportMode;

  // --- NEW FIELD ADDED ---
  final String? fileUrl; // URL where the PDF is stored in Firebase Storage

  TaskModel({
    required this.id,
    required this.requesterId,
    required this.title,
    required this.pickup,
    required this.drop,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.campusId,
    required this.campusName,
    required this.transportMode,
    // --- NEW FIELD IN CONSTRUCTOR ---
    this.fileUrl,
  });

  // Convert Firebase Data -> Dart Object
  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      requesterId: map['requesterId'] ?? '',
      title: map['title'] ?? '',
      pickup: map['pickup'] ?? '',
      drop: map['drop'] ?? '',
      price: map['price'] ?? '0',
      status: map['status'] ?? 'OPEN',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      campusId: map['campusId'] ?? 'unknown',
      campusName: map['campusName'] ?? 'Unknown Campus',
      transportMode: map['transportMode'] ?? 'Walking',
      // --- FROM MAP: Reads the URL from Firestore ---
      fileUrl: map['fileUrl'],
    );
  }

  // Convert Dart Object -> Firebase Data
  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'title': title,
      'pickup': pickup,
      'drop': drop,
      'price': price,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'campusId': campusId,
      'campusName': campusName,
      'transportMode': transportMode,
      // --- TO MAP: Writes the URL to Firestore ---
      'fileUrl': fileUrl,
    };
  }
}
