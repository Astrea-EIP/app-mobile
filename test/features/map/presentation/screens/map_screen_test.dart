import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/map/data/models/location_exceptions.dart';
import 'package:astrea/features/map/data/models/user_location.dart';
import 'package:astrea/features/map/presentation/screens/map_screen.dart';
import '../../fake_location_repository.dart';

/// Stand-in for the native MapLibre view, which cannot run in widget tests.
Widget _fakeMap(BuildContext context, UserLocation location) => Center(
  key: const Key('fake-map'),
  child: Text('${location.latitude},${location.longitude}'),
);

Future<void> pumpMap(
  WidgetTester tester,
  FakeLocationRepository repository,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MapScreen(locationRepository: repository, mapBuilder: _fakeMap),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('centers the map on the user position', (
    WidgetTester tester,
  ) async {
    final FakeLocationRepository repository = FakeLocationRepository(
      result: const UserLocation(latitude: 48.8566, longitude: 2.3522),
    );
    await pumpMap(tester, repository);

    expect(find.byKey(const Key('fake-map')), findsOneWidget);
    expect(find.text('48.8566,2.3522'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Recentrer la carte sur ma position'),
      findsOneWidget,
    );
  });

  testWidgets('shows a fallback when the permission is denied', (
    WidgetTester tester,
  ) async {
    final FakeLocationRepository repository = FakeLocationRepository(
      error: const LocationPermissionDeniedException(),
    );
    await pumpMap(tester, repository);

    expect(find.byKey(const Key('fake-map')), findsNothing);
    expect(find.text('Localisation refusée'), findsOneWidget);

    repository
      ..error = null
      ..result = const UserLocation(latitude: 1, longitude: 2);
    await tester.tap(find.text('Autoriser la localisation'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const Key('fake-map')), findsOneWidget);
    expect(repository.locationCalls, 2);
  });

  testWidgets('offers the app settings when the permission is blocked', (
    WidgetTester tester,
  ) async {
    final FakeLocationRepository repository = FakeLocationRepository(
      error: const LocationPermissionDeniedForeverException(),
    );
    await pumpMap(tester, repository);

    expect(find.text('Localisation désactivée'), findsOneWidget);
    await tester.tap(find.text('Ouvrir les paramètres'));
    await tester.pump();
    expect(repository.appSettingsCalls, 1);
  });

  testWidgets('offers the location settings when the GPS is off', (
    WidgetTester tester,
  ) async {
    final FakeLocationRepository repository = FakeLocationRepository(
      error: const LocationServiceDisabledException(),
    );
    await pumpMap(tester, repository);

    expect(find.text('GPS désactivé'), findsOneWidget);
    await tester.tap(find.text('Activer la localisation'));
    await tester.pump();
    expect(repository.locationSettingsCalls, 1);
  });

  testWidgets('shows a retry when the position is unavailable', (
    WidgetTester tester,
  ) async {
    final FakeLocationRepository repository = FakeLocationRepository(
      error: const LocationUnavailableException(),
    );
    await pumpMap(tester, repository);

    expect(find.text('Position introuvable'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pump();
    expect(repository.locationCalls, 2);
  });
}
