import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil semua pengaduan
  Stream<List<ComplaintModel>> getComplaints() {
    return _firestore
        .collection('pengaduan')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ComplaintModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update Status Pengaduan
  Future<void> updateStatus(String id, ComplaintStatus status) async {
    String statusStr;
    switch (status) {
      case ComplaintStatus.pending:
        statusStr = 'pending';
        break;
      case ComplaintStatus.processed:
        statusStr = 'processed';
        break;
      case ComplaintStatus.done:
        statusStr = 'done';
        break;
      case ComplaintStatus.rejected:
        statusStr = 'rejected';
        break;
    }

    await _firestore.collection('pengaduan').doc(id).update({
      'status': statusStr,
    });
  }
}
