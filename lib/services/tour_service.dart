// lib/services/tour_service.dart

import 'package:flutter/material.dart';

class TourStep {
  final String title;
  final String description;
  final GlobalKey targetKey;

  const TourStep({
    required this.title,
    required this.description,
    required this.targetKey,
  });
}

class TourService extends ChangeNotifier {
  List<TourStep> _steps = [];
  int _currentStep = -1;
  bool _isActive = false;

  List<TourStep> get steps => _steps;
  int get currentStep => _currentStep;
  bool get isActive => _isActive;

  TourStep? get currentTourStep {
    if (!_isActive || _currentStep < 0 || _currentStep >= _steps.length) {
      return null;
    }
    return _steps[_currentStep];
  }

  void configure(List<TourStep> steps) {
    _steps = steps;
  }

  void start() {
    if (_steps.isEmpty) return;
    _currentStep = 0;
    _isActive = true;
    notifyListeners();
  }

  void next() {
    if (!_isActive) return;
    if (_currentStep < _steps.length - 1) {
      _currentStep++;
      notifyListeners();
    } else {
      finish();
    }
  }

  void skip() {
    finish();
  }

  void finish() {
    _isActive = false;
    _currentStep = -1;
    notifyListeners();
  }
}
