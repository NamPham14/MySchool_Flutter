import 'package:flutter/material.dart';
import '../domain/club_model.dart';
import '../service/club_service.dart';

class ClubProvider with ChangeNotifier {
  final ClubService _clubService = ClubService();

  List<Club> _clubs = [];
  bool _isLoading = false;
  String? _error;

  List<Club> get clubs => _clubs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClubs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clubs = await _clubService.getClubs();
    } catch (e) {
      _error = 'Lỗi tải danh sách CLB: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinClub(int clubId) async {
    try {
      final success = await _clubService.joinClub(clubId);
      if (success) {
        // Cập nhật trạng thái thành PENDING trong danh sách hiện tại
        final index = _clubs.indexWhere((c) => c.id == clubId);
        if (index != -1) {
          _clubs[index].membershipStatus = 'PENDING';
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
