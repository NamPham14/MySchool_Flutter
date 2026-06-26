import 'package:flutter/material.dart';
import '../domain/grade_model.dart';
import '../service/grade_service.dart';

class GradeProvider extends ChangeNotifier {
  final GradeService _service = GradeService();

  bool isLoading = false;
  List<GradeModel> grades = [];
  double? gpa;
  String? academicPerformance;
  String? conduct;
  String? semesterName;
  String? errorMessage;

  /// Lấy bảng điểm của học sinh (Cần ID học sinh và ID học kỳ)
  Future<void> fetchGrades(int studentId, int semesterId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getStudentGrades(studentId, semesterId);
      if (data != null) {
        if (data['summary'] != null) {
          final summary = data['summary'];
          gpa = summary['gpa'] != null ? double.parse(summary['gpa'].toString()) : null;
          academicPerformance = summary['academicPerformance'];
          conduct = summary['conduct'];
          semesterName = summary['semesterName'];
        }
        if (data['details'] != null) {
          final List list = data['details'];
          grades = list.map((e) => GradeModel.fromJson(e)).toList();
        } else {
          grades = [];
        }
      } else {
        grades = [];
      }
    } catch (e) {
      errorMessage = "Không thể tải bảng điểm: $e";
    } finally {
      isLoading = false;
      notifyListeners(); 
    }
  }

  bool isLoadingSemesters = false;
  List<Map<String, dynamic>> semesters = [];

  Future<void> fetchSemesters() async {
    isLoadingSemesters = true;
    notifyListeners();

    try {
      final data = await _service.getSemesters();
      if (data != null && data.isNotEmpty) {
        semesters = data;
      } else {
        semesters = [
          {"id": 1, "name": "Học kỳ 1"}
        ];
      }
    } catch (e) {
      semesters = [
        {"id": 1, "name": "Học kỳ 1"}
      ];
    } finally {
      isLoadingSemesters = false;
      notifyListeners();
    }
  }
}
