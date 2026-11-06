import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astrea/core/network/astrea_api_client.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/onboarding/data/repositories/http_profile_repository.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  final AstreaApiClient apiClient = AstreaApiClient();
  final ProfileRepository profileRepository = HttpProfileRepository(
    apiClient: apiClient,
  );
  runApp(MyApp(profileRepository: profileRepository));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.profileRepository, super.key});

  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
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
    );
  }
}
