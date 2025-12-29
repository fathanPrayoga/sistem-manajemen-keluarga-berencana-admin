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

    // Create Notification on Status Update
    final docSnapshot = await _firestore.collection('pendaftaran_kb').doc(id).get();
    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      final nik = data['nik'] as String?;

      if (nik != null && nik.isNotEmpty) {
        String bodyText = 'Pendaftaran KB anda diperbarui.';
        if (status == KbStatus.confirmed) {
          bodyText = 'Pendaftaran KB anda telah dikonfirmasi.';
        } else if (status == KbStatus.done) {
          bodyText = 'Pendaftaran KB anda telah selesai.';
        } else if (status == KbStatus.rejected) {
          bodyText = 'Pendaftaran KB anda telah ditolak.';
        } else if (status == KbStatus.pending) {
           bodyText = 'Pendaftaran KB anda sedang menunggu konfirmasi.';
        }

        await _firestore.collection('notifications').add({
          'recipientNik': nik,
          'title': 'Pendaftaran KB',
          'body': bodyText,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
