import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/help/help_content.dart';

void main() {
  group('HelpContent', () {
    test('appName is set', () {
      expect(HelpContent.appName, isNotEmpty);
    });

    test('shortDescription is set', () {
      expect(HelpContent.shortDescriptionDe, isNotEmpty);
    });

    test('synopsis is set', () {
      expect(HelpContent.synopsis, contains('musicup'));
    });

    test('sections list is not empty', () {
      expect(HelpContent.sectionsDe, isNotEmpty);
    });

    test('every section has a title and body', () {
      for (final section in HelpContent.sectionsDe) {
        expect(section.title, isNotEmpty,
            reason: 'Section title must not be empty');
        expect(section.body, isNotEmpty,
            reason: 'Body of "${section.title}" must not be empty');
      }
    });

    test('contains required sections', () {
      final titles = HelpContent.sectionsDe.map((s) => s.title).toSet();
      expect(titles, contains('BESCHREIBUNG'));
      expect(titles, contains('SAMMLUNG VERWALTEN'));
      expect(titles, contains('DISCOGS INTEGRATION'));
      expect(titles, contains('IMPORT/EXPORT'));
      expect(titles, contains('WANTLIST'));
      expect(titles, contains('DATEIPFADE'));
      expect(titles, contains('OPTIONEN'));
      expect(titles, contains('AUTOR'));
      expect(titles, contains('FEHLER MELDEN'));
    });

    test('OPTIONEN section documents --help and --version', () {
      final optionen = HelpContent.sectionsDe
          .firstWhere((s) => s.title == 'OPTIONEN');
      expect(optionen.body, contains('--help'));
      expect(optionen.body, contains('--version'));
    });

    test('section titles are unique', () {
      final titles = HelpContent.sectionsDe.map((s) => s.title).toList();
      expect(titles.toSet().length, equals(titles.length),
          reason: 'Duplicate section titles found');
    });

    test('DATEIPFADE section mentions config path', () {
      final dateipfade = HelpContent.sectionsDe
          .firstWhere((s) => s.title == 'DATEIPFADE');
      expect(dateipfade.body, contains('.config/music_up'));
    });

    test('FEHLER MELDEN section has contact info', () {
      final fehler = HelpContent.sectionsDe
          .firstWhere((s) => s.title == 'FEHLER MELDEN');
      expect(fehler.body, contains('nobo_code@posteo.de'));
    });
  });
}
