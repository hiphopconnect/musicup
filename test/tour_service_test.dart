import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/tour_service.dart';

void main() {
  group('TourService', () {
    late TourService tourService;
    late List<TourStep> steps;

    setUp(() {
      tourService = TourService();
      steps = [
        TourStep(
          title: 'Step 1',
          description: 'First step',
          targetKey: GlobalKey(),
        ),
        TourStep(
          title: 'Step 2',
          description: 'Second step',
          targetKey: GlobalKey(),
        ),
        TourStep(
          title: 'Step 3',
          description: 'Third step',
          targetKey: GlobalKey(),
        ),
      ];
    });

    tearDown(() {
      tourService.dispose();
    });

    test('initial state is inactive', () {
      expect(tourService.isActive, isFalse);
      expect(tourService.currentStep, equals(-1));
      expect(tourService.currentTourStep, isNull);
      expect(tourService.steps, isEmpty);
    });

    test('configure sets steps', () {
      tourService.configure(steps);
      expect(tourService.steps.length, equals(3));
    });

    test('start activates tour at step 0', () {
      tourService.configure(steps);
      tourService.start();

      expect(tourService.isActive, isTrue);
      expect(tourService.currentStep, equals(0));
      expect(tourService.currentTourStep?.title, equals('Step 1'));
    });

    test('start does nothing with empty steps', () {
      tourService.start();
      expect(tourService.isActive, isFalse);
    });

    test('next advances to next step', () {
      tourService.configure(steps);
      tourService.start();
      tourService.next();

      expect(tourService.currentStep, equals(1));
      expect(tourService.currentTourStep?.title, equals('Step 2'));
    });

    test('next on last step finishes tour', () {
      tourService.configure(steps);
      tourService.start();
      tourService.next(); // step 1
      tourService.next(); // step 2
      tourService.next(); // finish

      expect(tourService.isActive, isFalse);
      expect(tourService.currentStep, equals(-1));
    });

    test('skip finishes tour immediately', () {
      tourService.configure(steps);
      tourService.start();
      tourService.skip();

      expect(tourService.isActive, isFalse);
      expect(tourService.currentStep, equals(-1));
    });

    test('finish deactivates tour', () {
      tourService.configure(steps);
      tourService.start();
      tourService.finish();

      expect(tourService.isActive, isFalse);
      expect(tourService.currentStep, equals(-1));
    });

    test('next does nothing when not active', () {
      tourService.configure(steps);
      tourService.next();

      expect(tourService.isActive, isFalse);
      expect(tourService.currentStep, equals(-1));
    });

    test('notifies listeners on start', () {
      tourService.configure(steps);
      int notifyCount = 0;
      tourService.addListener(() => notifyCount++);

      tourService.start();
      expect(notifyCount, equals(1));
    });

    test('notifies listeners on next', () {
      tourService.configure(steps);
      tourService.start();

      int notifyCount = 0;
      tourService.addListener(() => notifyCount++);

      tourService.next();
      expect(notifyCount, equals(1));
    });

    test('notifies listeners on skip', () {
      tourService.configure(steps);
      tourService.start();

      int notifyCount = 0;
      tourService.addListener(() => notifyCount++);

      tourService.skip();
      expect(notifyCount, equals(1));
    });

    test('currentTourStep returns null when inactive', () {
      tourService.configure(steps);
      expect(tourService.currentTourStep, isNull);
    });

    test('currentTourStep returns null for out of range index', () {
      tourService.configure(steps);
      tourService.start();
      tourService.finish();
      expect(tourService.currentTourStep, isNull);
    });
  });
}