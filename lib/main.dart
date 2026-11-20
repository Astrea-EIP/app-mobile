import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/auth/data/repositories/auth_repository.dart';
import 'package:astrea/features/auth/data/storage/token_storage.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/screens/auth_gate.dart';
import 'package:astrea/features/map/data/repositories/geolocator_location_repository.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';
import 'package:astrea/features/onboarding/data/repositories/http_profile_repository.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';

void main() {
  final AstreaApiClient apiClient = AstreaApiClient();
  final ProfileRepository profileRepository = HttpProfileRepository(
    apiClient: apiClient,
  );
  runApp(
    MyApp(
      profileRepository: profileRepository,
      locationRepository: const GeolocatorLocationRepository(),
      // Mocked until the backend exposes the auth routes.
      authRepository: MockAuthRepository(),
      tokenStorage: SecureTokenStorage(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.profileRepository,
    required this.locationRepository,
    required this.authRepository,
    required this.tokenStorage,
    super.key,
  });

  final ProfileRepository profileRepository;
  final LocationRepository locationRepository;
  final AuthRepository authRepository;
  final TokenStorage tokenStorage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<LocationRepository>.value(value: locationRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthBloc>(
            create: (BuildContext context) => AuthBloc(
              authRepository: authRepository,
              tokenStorage: tokenStorage,
            )..add(const AuthStarted()),
          ),
          BlocProvider<ProfileBloc>(
            create: (BuildContext context) =>
                ProfileBloc(profileRepository: profileRepository),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Astrea',
          theme: AppTheme.lightTheme,
          locale: const Locale('fr', 'FR'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const <Locale>[Locale('fr', 'FR')],
          home: const AuthGate(),
        ),
      ),
    );
  }
}
