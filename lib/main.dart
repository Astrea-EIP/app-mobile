import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/bloc/profile_bloc.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_screen.dart';



void main() {
  final ProfileRepository profileRepository = MockProfileRepository();
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
        home: const OnboardingScreen(),
      ),
    );
  }
}
