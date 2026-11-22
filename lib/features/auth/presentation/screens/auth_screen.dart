import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/widgets.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_state.dart';
import 'package:astrea/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:astrea/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:astrea/features/auth/presentation/widgets/login_form.dart';
import 'package:astrea/features/auth/presentation/widgets/register_form.dart';

enum AuthMode { login, register }

/// Login / register screen. Both modes share the same frame (logo +
/// segmented control), as in the Figma "Parcours 1 — Compte".
class AuthScreen extends StatefulWidget {
  const AuthScreen({this.initialMode = AuthMode.login, super.key});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// Distance from the top of the screen to the logo in the design.
  static const double _designTopInset = 72;

  late AuthMode _mode = widget.initialMode;

  void _setMode(AuthMode mode) {
    if (mode == _mode) {
      return;
    }
    // A stale "wrong password" message makes no sense on the other tab.
    context.read<AuthBloc>().add(const AuthErrorCleared());
    setState(() => _mode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = math.max(
      _designTopInset,
      MediaQuery.paddingOf(context).top + AppSpacing.lg,
    );

    // Light page: dark status bar icons (the splash before it sets light ones).
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.page,
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s20,
              topInset,
              AppSpacing.s20,
              AppSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: AuthLogoHeader()),
                    // 12 px gap + 4 px spacer + 12 px gap in the design.
                    const SizedBox(height: 28),
                    AstreaSegmentedControl(
                      labels: const <String>['Se connecter', 'Créer un compte'],
                      selectedIndex: _mode == AuthMode.login ? 0 : 1,
                      onChanged: (int index) => _setMode(
                        index == 0 ? AuthMode.login : AuthMode.register,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (AuthState previous, AuthState current) =>
                          previous.errorMessage != current.errorMessage,
                      builder: (BuildContext context, AuthState state) {
                        final String? message = state.errorMessage;
                        if (message == null) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AuthErrorBanner(message: message),
                        );
                      },
                    ),
                    if (_mode == AuthMode.login)
                      LoginForm(
                        key: const ValueKey<AuthMode>(AuthMode.login),
                        onSwitchToRegister: () => _setMode(AuthMode.register),
                      )
                    else
                      RegisterForm(
                        key: const ValueKey<AuthMode>(AuthMode.register),
                        onSwitchToLogin: () => _setMode(AuthMode.login),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
