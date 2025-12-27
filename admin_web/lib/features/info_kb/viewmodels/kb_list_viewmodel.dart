import 'package:flutter/material.dart';
import '../../../models/kb_model.dart';
import '../../../services/kb_service.dart';

class KbListViewModel extends ChangeNotifier {
  final KbService _service = KbService();

  KbStatus? _filterStatus;
  KbStatus? get filterStatus => _filterStatus;

  Stream<List<KbRegistrationModel>> get registrationsStream =>
      _service.getRegistrations();

  void setFilter(KbStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> updateStatus(String id, KbStatus status) async {
    await _service.updateStatus(id, status);
    notifyListeners();
  }
}
