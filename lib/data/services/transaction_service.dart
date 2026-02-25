import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTransaction({
    required String taskId,
    required String requesterId,
    required String runnerId,
    required String amount,
    String? paymentMethod,
    String? notes,
  }) async {
    final transaction = TransactionModel(
      id: '',
      taskId: taskId,
      requesterId: requesterId,
      runnerId: runnerId,
      amount: amount,
      status: 'PENDING',
      type: 'TASK_PAYMENT',
      createdAt: DateTime.now(),
      paymentMethod: paymentMethod,
      notes: notes,
    );

    final docRef = await _firestore.collection('transactions').add(
          transaction.toMap(),
        );
    return docRef.id;
  }

  Future<void> updateTransactionStatus(
    String transactionId,
    String status, {
    String? transactionReference,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      if (status == 'COMPLETED') 'completedAt': DateTime.now().millisecondsSinceEpoch,
      if (transactionReference != null) 'transactionReference': transactionReference,
    };

    await _firestore.collection('transactions').doc(transactionId).update(
          updateData,
        );
  }

  Stream<List<TransactionModel>> getTransactionsByUser(String userId) {
    return _firestore
        .collection('transactions')
        .where('runnerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<TransactionModel>> getTransactionsByTask(String taskId) {
    return _firestore
        .collection('transactions')
        .where('taskId', isEqualTo: taskId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<TransactionModel?> getTransactionByTask(String taskId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('taskId', isEqualTo: taskId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return TransactionModel.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  Future<Map<String, dynamic>> getRunnerEarnings(String runnerId) async {
    final snapshot = await _firestore
        .collection('transactions')
        .where('runnerId', isEqualTo: runnerId)
        .where('status', isEqualTo: 'COMPLETED')
        .get();

    double totalEarnings = 0;
    int completedTasks = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      final amount = double.tryParse(doc.data()['amount'] ?? '0') ?? 0;
      totalEarnings += amount;
    }

    return {
      'totalEarnings': totalEarnings,
      'completedTasks': completedTasks,
    };
  }
}
