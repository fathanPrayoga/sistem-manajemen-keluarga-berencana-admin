import 'package:flutter/material.dart';
import '/models/complaint_model.dart';
import '/services/complaint_service.dart';

class ComplaintListViewModel extends ChangeNotifier {
  final ComplaintService _service = ComplaintService();

  ComplaintStatus? _filterStatus;
  ComplaintStatus? get filterStatus => _filterStatus;

  Stream<List<ComplaintModel>> get complaintsStream {
    return _service.getComplaints().map((complaints) {
      if (_filterStatus == null) return complaints;

      return complaints.where((c) => c.status == _filterStatus).toList();
    });
  }

  void setFilter(ComplaintStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> updateStatus(
    ComplaintModel complaint,
    ComplaintStatus status,
  ) async {
    await _service.updateStatus(complaint.id, complaint.kategori, status);
    notifyListeners();
  }
}
