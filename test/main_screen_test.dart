import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeJsonService extends Fake implements JsonService {
  List<Album> albumsToReturn = [];

  @override
  Future<List<Album>> loadAlbums() async => albumsToReturn;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ServiceLocator.instance.reset();

    final configManager = ConfigManager();
    await configManager.loadConfig();
    final fakeJsonService = FakeJsonService();

    ServiceLocator.instance.initForTest(
      configManager: configManager,
      jsonService: fakeJsonService,
      discogsService: DiscogsServiceUnified(configManager),
    );
  });

  testWidgets('MainScreen displays a list of albums',
      (WidgetTester tester) async {
    final fakeJsonService = sl.jsonService as FakeJsonService;
    fakeJsonService.albumsToReturn = [
      Album(
        id: '1',
        name: 'Test Album 1',
        artist: 'Test Artist',
        genre: 'Test Genre',
        year: '2021',
        medium: 'CD',
        digital: false,
        tracks: [],
      ),
      Album(
        id: '2',
        name: 'Test Album 2',
        artist: 'Another Artist',
        genre: 'Another Genre',
        year: '2022',
        medium: 'Vinyl',
        digital: true,
        tracks: [],
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const MainScreen(),
      ),
    );

    // Use pump() instead of pumpAndSettle() because the TextField cursor
    // blink animation prevents pumpAndSettle from ever completing
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the list of albums is displayed
    expect(find.text('Test Album 1'), findsOneWidget);
    expect(find.text('Test Album 2'), findsOneWidget);
  });
}
