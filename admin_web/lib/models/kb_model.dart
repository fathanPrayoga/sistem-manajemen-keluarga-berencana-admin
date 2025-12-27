import 'package:cloud_firestore/cloud_firestore.dart';

enum KbStatus { pending, confirmed, done, rejected }

class KbRegistrationModel {
  final String id;
  final String fullname;
  final String nik;
  final String phone;
  final String alamat;
  final String serviceType;
  final DateTime bookingDate;
  final KbStatus status;
  final DateTime timestamp; // Waktu submit

  KbRegistrationModel({
    required this.id,
    required this.fullname,
    required this.nik,
    required this.phone,
    required this.alamat,
    required this.serviceType,
    required this.bookingDate,
    required this.status,
    required this.timestamp,
  });

  factory KbRegistrationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KbRegistrationModel(
      id: doc.id,
      fullname: data['nama'] ?? '',
      nik: data['nik'] ?? '',
      phone: data['hp'] ?? '',
      alamat: data['alamat'] ?? '',
      serviceType: data['layanan'] ?? '',
      bookingDate: _parseDate(data['tanggal']),
      status: _parseStatus(data['status']),
      timestamp: (data['created_at'] != null)
          ? _parseDate(data['created_at'])
          : DateTime.now(),
    );
  }

  static DateTime _parseDate(dynamic val) {
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
  }

  static KbStatus _parseStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return KbStatus.confirmed;
      case 'done':
        return KbStatus.done;
      case 'rejected':
        return KbStatus.rejected;
      default:
        return KbStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case KbStatus.pending:
        return 'Menunggu Konfirmasi';
      case KbStatus.confirmed:
        return 'Disetujui';
      case KbStatus.done:
        return 'Selesai';
      case KbStatus.rejected:
        return 'Ditolak';
    }
  }

  String get serviceTypeText {
    if (serviceType == 'pendek') return 'Kontrasepsi Jangka Pendek';
    if (serviceType == 'panjang') return 'Kontrasepsi Jangka Panjang';
    return serviceType;
  }
}
