import 'package:flutter_test/flutter_test.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/main.dart';
import 'features/map/fake_location_repository.dart';

void main() {
  testWidgets('App smoke test shows onboarding', (WidgetTester tester) async {
    final ProfileRepository repository = MockProfileRepository();
    await tester.pumpWidget(
      MyApp(
        profileRepository: repository,
        locationRepository: FakeLocationRepository(),
      ),
    );

    expect(find.text('Astrea'), findsOneWidget);
    expect(find.text('Comment vous déplacez-vous ?'), findsOneWidget);
  });
}
