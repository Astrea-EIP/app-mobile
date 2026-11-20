import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_state.dart';
import 'package:astrea/features/auth/presentation/screens/auth_screen.dart';
import 'package:astrea/features/map/data/repositories/location_repository.dart';
import 'package:astrea/features/map/presentation/screens/map_screen.dart';
import 'package:astrea/features/onboarding/data/models/accessibility_profile.dart';
import 'package:astrea/features/onboarding/data/repositories/profile_repository.dart';
import 'package:astrea/features/onboarding/presentation/screens/onboarding_screen.dart';

/// Decides what to show from the auth state: a splash while the stored token
/// is checked, the main app when authenticated, the auth screen otherwise.
///
/// Being state-driven (no manual navigation), it also handles logout and
/// expired sessions without leaving stale routes on the stack.
class AuthGate extends StatefulWidget {
  const AuthGate({
    this.minSplashDuration = const Duration(milliseconds: 800),
    super.key,
  });

  /// Minimum time the splash stays on screen at startup. The token check is
  /// near-instant, so without it the branded splash would only flash.
  final Duration minSplashDuration;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Timer? _splashTimer;
  late bool _splashElapsed = widget.minSplashDuration == Duration.zero;

  @override
  void initState() {
    super.initState();
    if (!_splashElapsed) {
      _splashTimer = Timer(widget.minSplashDuration, () {
        if (mounted) {
          setState(() => _splashElapsed = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (AuthState previous, AuthState current) =>
          previous.status == AuthStatus.submitting &&
          current.status == AuthStatus.authenticated,
      listener: (BuildContext context, AuthState state) {
        SemanticsService.sendAnnouncement(
          View.of(context),
          'Connexion réussie.',
          TextDirection.ltr,
        );
      },
      builder: (BuildContext context, AuthState state) {
        if (!_splashElapsed) {
          return const _SplashScreen();
        }
        switch (state.status) {
          case AuthStatus.checking:
            return const _SplashScreen();
          case AuthStatus.authenticated:
            return const _AuthenticatedHome();
          case AuthStatus.unauthenticated:
          case AuthStatus.submitting:
          case AuthStatus.failure:
            return const AuthScreen();
        }
      },
    );
  }
}

/// Home of a signed-in user: the map when an accessibility profile already
/// exists, the profile onboarding otherwise.
class _AuthenticatedHome extends StatefulWidget {
  const _AuthenticatedHome();

  @override
  State<_AuthenticatedHome> createState() => _AuthenticatedHomeState();
}

class _AuthenticatedHomeState extends State<_AuthenticatedHome> {
  late final Future<AccessibilityProfile?> _profile = context
      .read<ProfileRepository>()
      .getProfile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccessibilityProfile?>(
      future: _profile,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<AccessibilityProfile?> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _SplashScreen();
            }
            // A failed lookup is treated as "no profile": the onboarding
            // is the safe path and rebuilds it.
            if (snapshot.data == null) {
              return const OnboardingScreen();
            }
            return MapScreen(
              locationRepository: context.read<LocationRepository>(),
            );
          },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    // Full-screen brand gradient, like the Android launch screen it follows.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.brandGradientStart,
                AppColors.brandGradientEnd,
              ],
            ),
          ),
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Same position and size as the Android 12+ system splash
                // icon, so the hand-over only changes the background.
                // Decorative: the progress indicator carries the meaning.
                Image.asset(
                  'assets/images/astrea_pedestrian.png',
                  width: 172,
                  height: 172,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                ),
                const Align(
                  alignment: Alignment(0, 0.5),
                  child: CircularProgressIndicator(
                    color: AppColors.surface,
                    semanticsLabel: 'Chargement en cours',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
