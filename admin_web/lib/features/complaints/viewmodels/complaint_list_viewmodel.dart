import 'package:flutter/material.dart';
import '../../../models/complaint_model.dart';
import '../../../services/complaint_service.dart';

class ComplaintListViewModel extends ChangeNotifier {
  final ComplaintService _service = ComplaintService();

  // Filter status aktif (null = semua)
  ComplaintStatus? _filterStatus;
  ComplaintStatus? get filterStatus => _filterStatus;

  Stream<List<ComplaintModel>> get complaintsStream => _service.getComplaints();

  void setFilter(ComplaintStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> updateStatus(String id, ComplaintStatus status) async {
    await _service.updateStatus(id, status);
    notifyListeners();
  }
}
