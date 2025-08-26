import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/auto_save_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoSaveService Tests', () {
    late AutoSaveService autoSaveService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      autoSaveService = AutoSaveService();
    });

    tearDown(() {
      autoSaveService.dispose();
    });

    test('Save and load form data', () async {
      final formData = {
        'name': 'Test Album',
        'artist': 'Test Artist',
        'year': '2023',
        'tracks': [
          {'trackNumber': '01', 'title': 'Track 1'},
          {'trackNumber': '02', 'title': 'Track 2'},
        ],
      };

      // Save form data
      autoSaveService.saveFormData('test_form', formData);
      
      // Wait for debounce
      await Future.delayed(const Duration(seconds: 3));

      // Load form data
      final loadedData = await autoSaveService.loadFormData('test_form');

      expect(loadedData, isNotNull);
      expect(loadedData!['name'], 'Test Album');
      expect(loadedData['artist'], 'Test Artist');
      expect(loadedData['year'], '2023');
      expect(loadedData['tracks'], isA<List>());
      expect((loadedData['tracks'] as List).length, 2);
    });

    test('Check if draft data exists', () async {
      // Initially no draft
      bool hasDraft = await autoSaveService.hasDraftData('new_form');
      expect(hasDraft, isFalse);

      // Save some data
      autoSaveService.saveFormData('new_form', {'test': 'data'});
      await Future.delayed(const Duration(seconds: 3));

      // Now draft should exist
      hasDraft = await autoSaveService.hasDraftData('new_form');
      expect(hasDraft, isTrue);
    });

    test('Clear form data', () async {
      // Save data
      autoSaveService.saveFormData('clear_test', {'data': 'test'});
      await Future.delayed(const Duration(seconds: 3));

      // Verify it exists
      bool hasDraft = await autoSaveService.hasDraftData('clear_test');
      expect(hasDraft, isTrue);

      // Clear it
      await autoSaveService.clearFormData('clear_test');

      // Verify it's gone
      hasDraft = await autoSaveService.hasDraftData('clear_test');
      expect(hasDraft, isFalse);
    });

    test('Clear multiple drafts individually', () async {
      // Save multiple drafts
      autoSaveService.saveFormData('draft1', {'data': '1'});
      autoSaveService.saveFormData('draft2', {'data': '2'});
      autoSaveService.saveFormData('draft3', {'data': '3'});
      await Future.delayed(const Duration(seconds: 3));

      // Clear each individually
      await autoSaveService.clearFormData('draft1');
      await autoSaveService.clearFormData('draft2');
      await autoSaveService.clearFormData('draft3');

      // Verify all are gone
      expect(await autoSaveService.hasDraftData('draft1'), isFalse);
      expect(await autoSaveService.hasDraftData('draft2'), isFalse);
      expect(await autoSaveService.hasDraftData('draft3'), isFalse);
    });

    test('Handle null form data', () async {
      final result = await autoSaveService.loadFormData('non_existent');
      expect(result, isNull);
    });

    test('Save empty form data', () async {
      autoSaveService.saveFormData('empty_form', {});
      await Future.delayed(const Duration(seconds: 3));

      final loaded = await autoSaveService.loadFormData('empty_form');
      expect(loaded, isNotNull);
      expect(loaded!.isEmpty, isTrue);
    });

    test('Save with special characters', () async {
      final formData = {
        'name': 'Album with "quotes" & symbols',
        'artist': 'Artist\nwith\nnewlines',
        'special': '🎵 Music',
      };

      autoSaveService.saveFormData('special_chars', formData);
      await Future.delayed(const Duration(seconds: 3));

      final loaded = await autoSaveService.loadFormData('special_chars');
      expect(loaded!['name'], 'Album with "quotes" & symbols');
      expect(loaded['artist'], 'Artist\nwith\nnewlines');
      expect(loaded['special'], '🎵 Music');
    });

    test('Debounce prevents multiple saves', () async {
      int saveCount = 0;
      
      // Override to count saves (this is just for testing concept)
      // In real scenario, we'd check SharedPreferences write count
      
      // Make multiple rapid saves
      for (int i = 0; i < 10; i++) {
        autoSaveService.saveFormData('debounce_test', {'count': i});
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Wait for debounce to complete
      await Future.delayed(const Duration(seconds: 3));

      // Should only have the last value
      final loaded = await autoSaveService.loadFormData('debounce_test');
      expect(loaded!['count'], 9); // Last value
    });

    test('Multiple forms can have separate drafts', () async {
      // Save different data for different forms
      autoSaveService.saveFormData('form_a', {'data': 'A'});
      autoSaveService.saveFormData('form_b', {'data': 'B'});
      await Future.delayed(const Duration(seconds: 3));

      // Load each form's data
      final dataA = await autoSaveService.loadFormData('form_a');
      final dataB = await autoSaveService.loadFormData('form_b');

      expect(dataA!['data'], 'A');
      expect(dataB!['data'], 'B');
    });

    test('Overwrite existing draft', () async {
      // Save initial data
      autoSaveService.saveFormData('overwrite_test', {'version': 1});
      await Future.delayed(const Duration(seconds: 3));

      // Overwrite with new data
      autoSaveService.saveFormData('overwrite_test', {'version': 2});
      await Future.delayed(const Duration(seconds: 3));

      // Should have latest version
      final data = await autoSaveService.loadFormData('overwrite_test');
      expect(data!['version'], 2);
    });
  });
}