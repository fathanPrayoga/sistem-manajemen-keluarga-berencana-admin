import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus { pending, processed, done, rejected }

class ComplaintModel {
  final String id;
  final String kategori;
  final String fullname;
  final String nik;
  final String phone;
  final String address;
  final String description; // Ditambahkan
  final String imageUrl;
  final ComplaintStatus status; // Diubah ke Enum
  final DateTime timestamp;

  ComplaintModel({
    required this.id,
    required this.kategori,
    required this.fullname,
    required this.nik,
    required this.phone,
    required this.address,
    required this.description,
    required this.imageUrl,
    required this.status,
    required this.timestamp,
  });

  factory ComplaintModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ComplaintModel(
      id: doc.id,
      kategori: data['kategori'] ?? '',
      fullname: data['fullname'] ?? '',
      nik: data['nik'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      description:
          data['description'] ??
          data['keluhan'] ??
          '', // Handle key 'keluhan' dari mobile
      imageUrl: data['imageUrl'] ?? '',
      status: _parseStatus(data['status']), // Gunakan helper
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static ComplaintStatus _parseStatus(String? status) {
    switch (status) {
      case 'processed':
        return ComplaintStatus.processed;
      case 'done':
        return ComplaintStatus.done;
      case 'rejected':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      // Sekarang status adalah Enum, jadi valid
      case ComplaintStatus.pending:
        return 'Menunggu';
      case ComplaintStatus.processed:
        return 'Diproses';
      case ComplaintStatus.done:
        return 'Selesai';
      case ComplaintStatus.rejected:
        return 'Ditolak';
    }
  }
}
