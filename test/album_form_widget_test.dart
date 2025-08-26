import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/widgets/album_form_widget.dart';

void main() {
  group('AlbumFormWidget Tests', () {
    late TextEditingController nameController;
    late TextEditingController artistController;
    late TextEditingController genreController;

    setUp(() {
      nameController = TextEditingController();
      artistController = TextEditingController();
      genreController = TextEditingController();
    });

    tearDown(() {
      nameController.dispose();
      artistController.dispose();
      genreController.dispose();
    });

    testWidgets('Displays all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Check for text fields
      expect(find.byType(TextField), findsNWidgets(3)); // Name, Artist, Genre
      expect(find.byType(DropdownButtonFormField), findsNWidgets(2)); // Year, Medium
      expect(find.byType(SwitchListTile), findsOneWidget); // Digital

      // Check for labels
      expect(find.text('Album-Name *'), findsOneWidget);
      expect(find.text('Künstler *'), findsOneWidget);
      expect(find.text('Genre (optional)'), findsOneWidget);
      expect(find.text('Jahr'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Digital verfügbar'), findsOneWidget);
    });

    testWidgets('Text fields accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Enter text in album name field
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Test Album',
      );
      expect(nameController.text, 'Test Album');

      // Enter text in artist field
      await tester.enterText(
        find.widgetWithText(TextField, 'Künstler *'),
        'Test Artist',
      );
      expect(artistController.text, 'Test Artist');

      // Enter text in genre field
      await tester.enterText(
        find.widgetWithText(TextField, 'Genre (optional)'),
        'Rock',
      );
      expect(genreController.text, 'Rock');
    });

    testWidgets('Year dropdown contains recent years', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlbumFormWidget(
                nameController: nameController,
                artistController: artistController,
                genreController: genreController,
                enableValidation: false,
              ),
            ),
          ),
        ),
      );

      // Open year dropdown
      await tester.tap(find.widgetWithText(DropdownButtonFormField, 'Jahr'));
      await tester.pumpAndSettle();

      // Check for current year
      final currentYear = DateTime.now().year;
      expect(find.text(currentYear.toString()), findsWidgets);
      expect(find.text((currentYear - 1).toString()), findsWidgets);
    });

    testWidgets('Medium dropdown contains all options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlbumFormWidget(
                nameController: nameController,
                artistController: artistController,
                genreController: genreController,
                enableValidation: false,
              ),
            ),
          ),
        ),
      );

      // Open medium dropdown
      await tester.tap(find.widgetWithText(DropdownButtonFormField, 'Medium'));
      await tester.pumpAndSettle();

      // Check for all medium options
      expect(find.text('Vinyl'), findsWidgets);
      expect(find.text('CD'), findsWidgets);
      expect(find.text('Cassette'), findsWidgets);
      expect(find.text('Digital'), findsWidgets);
    });

    testWidgets('Digital switch can be toggled', (WidgetTester tester) async {
      bool? digitalValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              isDigital: false,
              onDigitalChanged: (value) => digitalValue = value,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Toggle digital switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      expect(digitalValue, true);
    });

    testWidgets('Validation shows error messages when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              enableValidation: true,
            ),
          ),
        ),
      );

      // Trigger validation by entering and clearing text
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Test',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        '',
      );
      await tester.pump();

      // Should show error message
      expect(find.text('Album-Name ist erforderlich'), findsOneWidget);
    });

    testWidgets('Callbacks are triggered correctly', (WidgetTester tester) async {
      String? selectedYear;
      String? selectedMedium;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlbumFormWidget(
                nameController: nameController,
                artistController: artistController,
                genreController: genreController,
                onYearChanged: (year) => selectedYear = year,
                onMediumChanged: (medium) => selectedMedium = medium,
                enableValidation: false,
              ),
            ),
          ),
        ),
      );

      // Select year
      await tester.tap(find.widgetWithText(DropdownButtonFormField, 'Jahr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2023').last);
      await tester.pumpAndSettle();
      expect(selectedYear, '2023');

      // Select medium
      await tester.tap(find.widgetWithText(DropdownButtonFormField, 'Medium'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vinyl').last);
      await tester.pumpAndSettle();
      expect(selectedMedium, 'Vinyl');
    });

    testWidgets('Sections are properly displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Check for section titles
      expect(find.text('Album-Informationen'), findsOneWidget);
      expect(find.text('Album-Details'), findsOneWidget);
    });

    testWidgets('Icons are displayed for each field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Check for icons
      expect(find.byIcon(Icons.album), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.music_note), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('Pre-populated values are displayed', (WidgetTester tester) async {
      nameController.text = 'Existing Album';
      artistController.text = 'Existing Artist';
      genreController.text = 'Jazz';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumFormWidget(
              nameController: nameController,
              artistController: artistController,
              genreController: genreController,
              selectedYear: '2022',
              selectedMedium: 'CD',
              isDigital: true,
              enableValidation: false,
            ),
          ),
        ),
      );

      // Check that values are displayed
      expect(find.text('Existing Album'), findsOneWidget);
      expect(find.text('Existing Artist'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      
      // Check dropdown selections (in the dropdown button, not in the menu)
      expect(find.descendant(
        of: find.byType(DropdownButtonFormField),
        matching: find.text('2022'),
      ), findsOneWidget);
      
      expect(find.descendant(
        of: find.byType(DropdownButtonFormField),
        matching: find.text('CD'),
      ), findsOneWidget);

      // Check switch state
      final SwitchListTile switchTile = tester.widget(find.byType(SwitchListTile));
      expect(switchTile.value, true);
    });
  });
}