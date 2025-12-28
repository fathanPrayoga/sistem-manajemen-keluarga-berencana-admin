import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import '../models/complaint_model.dart';

class ComplaintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _collections = [
    'pengaduan_bansos',
    'pengaduan_anak',
    'pengaduan_lansia',
    'pengaduan_bencana',
    'pengaduan_mental',
  ];

  Stream<List<ComplaintModel>> getComplaints() {
    final streams = _collections.map((collection) {
      return _firestore
          .collection(collection)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ComplaintModel.fromFirestore(doc))
                .toList();
          });
    });

    return StreamZip(streams).map((lists) {
      return lists.expand((e) => e).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  Future<void> updateStatus(
    String id,
    String kategori,
    ComplaintStatus status,
  ) async {
    await _firestore.collection('pengaduan_$kategori').doc(id).update({
      'status': _statusToString(status),
    });
  }

  String _statusToString(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'menunggu';
      case ComplaintStatus.processed:
        return 'diproses';
      case ComplaintStatus.done:
        return 'selesai';
      case ComplaintStatus.rejected:
        return 'ditolak';
    }
  }
}
