// lib/data/models/task_model.dart

class TaskModel {
  final String id;
  final String requesterId;
  final String? runnerId;
  final String title;
  final String pickup;
  final String drop;
  final String price;
  final String status;
  final DateTime createdAt;
  final String campusId;
  final String campusName;
  final String transportMode;
  final String? fileUrl;

  TaskModel({
    required this.id,
    required this.requesterId,
    this.runnerId,
    required this.title,
    required this.pickup,
    required this.drop,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.campusId,
    required this.campusName,
    required this.transportMode,
    this.fileUrl,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String docId) {
    return TaskModel(
      id: docId,
      requesterId: map['requesterId'] ?? '',
      runnerId: map['runnerId'],
      title: map['title'] ?? '',
      pickup: map['pickup'] ?? '',
      drop: map['drop'] ?? '',
      price: map['price'] ?? '0',
      status: map['status'] ?? 'OPEN',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      campusId: map['campusId'] ?? 'unknown',
      campusName: map['campusName'] ?? 'Unknown Campus',
      transportMode: map['transportMode'] ?? 'Walking',
      fileUrl: map['fileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      if (runnerId != null) 'runnerId': runnerId,
      'title': title,
      'pickup': pickup,
      'drop': drop,
      'price': price,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'campusId': campusId,
      'campusName': campusName,
      'transportMode': transportMode,
      'fileUrl': fileUrl,
    };
  }
}
