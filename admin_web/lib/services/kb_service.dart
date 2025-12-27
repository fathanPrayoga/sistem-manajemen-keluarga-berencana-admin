import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/kb_model.dart';

class KbService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ambil data pendaftaran KB
  Stream<List<KbRegistrationModel>> getRegistrations() {
    return _firestore
        .collection('pendaftaran_kb') //nama collection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => KbRegistrationModel.fromFirestore(doc))
              .toList();
        });
  }

  // Update Status Pendaftaran
  Future<void> updateStatus(String id, KbStatus status) async {
    String statusStr;
    switch (status) {
      case KbStatus.pending:
        statusStr = 'pending';
        break;
      case KbStatus.confirmed:
        statusStr = 'confirmed';
        break;
      case KbStatus.done:
        statusStr = 'done';
        break;
      case KbStatus.rejected:
        statusStr = 'rejected';
        break;
    }

    await _firestore.collection('pendaftaran_kb').doc(id).update({
      'status': statusStr,
    });
  }
}
