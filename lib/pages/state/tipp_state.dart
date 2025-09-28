import 'package:flutter/material.dart';
import 'package:studyproject/pages/models/tipp.dart';
import 'package:studyproject/pages/services/tipp_service.dart';

class TipState extends ChangeNotifier {
  List<Tipp> _tips = [];

  List<Tipp> get tips => _tips;

  Future<void> loadTips() async {
    _tips = await TippService().fetchTips();
    notifyListeners();
  }
}
