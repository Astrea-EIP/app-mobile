import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/map/data/repositories/geolocator_location_repository.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';
import 'package:astrea/features/onboarding/data/repositories/http_profile_repository.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  final AstreaApiClient apiClient = AstreaApiClient();
  final ProfileRepository profileRepository = HttpProfileRepository(
    apiClient: apiClient,
  );
  runApp(
    MyApp(
      profileRepository: profileRepository,
      locationRepository: const GeolocatorLocationRepository(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.profileRepository,
    required this.locationRepository,
    super.key,
  });

  final ProfileRepository profileRepository;
  final LocationRepository locationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<LocationRepository>.value(
      value: locationRepository,
      child: BlocProvider<ProfileBloc>(
        create: (BuildContext context) =>
            ProfileBloc(profileRepository: profileRepository),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Astrea',
          theme: AppTheme.lightTheme,
          locale: const Locale('fr', 'FR'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const <Locale>[Locale('fr', 'FR')],
          home: const OnboardingScreen(),
        ),
      ),
    );
  }
}
