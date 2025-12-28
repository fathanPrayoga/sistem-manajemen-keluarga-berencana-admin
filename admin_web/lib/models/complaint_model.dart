import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus { pending, processed, done, rejected }

class ComplaintModel {
  final String id;
  final String kategori;
  final String fullname;
  final String nik;
  final String phone;
  final String address;
  final String description;
  final String imageUrl;
  final ComplaintStatus status;
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
    final data = doc.data() as Map<String, dynamic>;

    return ComplaintModel(
      id: doc.id,
      kategori: data['kategori'] ?? '',
      fullname: data['nama'] ?? '',
      nik: data['nik'] ?? '',
      phone: data['no_hp'] ?? '',
      address: data['alamat'] ?? '',
      description: data['keluhan'] ?? '',
      imageUrl: data['image_url'] ?? '',
      status: _parseStatus(data['status']),
      timestamp: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static ComplaintStatus _parseStatus(String? status) {
    switch (status) {
      case 'diproses':
        return ComplaintStatus.processed;
      case 'selesai':
        return ComplaintStatus.done;
      case 'ditolak':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.pending; // menunggu
    }
  }

  String get statusFirestore {
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

  String get statusText {
    switch (status) {
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
