import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/theme/app_theme.dart';
import 'package:astrea/core/widgets/widgets.dart';
import 'package:astrea/features/auth/presentation/auth_validators.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/widgets/auth_consent_checkbox.dart';
import 'package:astrea/features/auth/presentation/widgets/auth_link_button.dart';

/// "Créer un compte" form.
class RegisterForm extends StatefulWidget {
  const RegisterForm({required this.onSwitchToLogin, super.key});

  final VoidCallback onSwitchToLogin;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  static const String _consentLabel =
      "J'accepte que ma localisation et mon profil de mobilité soient "
      'traités pour calculer mes itinéraires. En savoir plus';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _consentGiven = false;
  bool _showConsentError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (context.read<AuthBloc>().state.isSubmitting) {
      return;
    }
    final bool fieldsValid = _formKey.currentState?.validate() ?? false;
    setState(() => _showConsentError = !_consentGiven);
    final DateTime? birthDate = AuthValidators.parseBirthDate(
      _birthDateController.text,
    );
    if (!fieldsValid || !_consentGiven || birthDate == null) {
      return;
    }
    TextInput.finishAutofillContext();
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        birthDate: birthDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = context.select(
      (AuthBloc bloc) => bloc.state.isSubmitting,
    );

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: <Widget>[
                AstreaTextField(
                  controller: _nameController,
                  hint: 'Prénom et nom',
                  enabled: !busy,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.name],
                  validator: AuthValidators.fullName,
                ),
                AstreaTextField(
                  controller: _emailController,
                  hint: 'Adresse e-mail',
                  enabled: !busy,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                  validator: AuthValidators.email,
                ),
                AstreaTextField(
                  controller: _passwordController,
                  hint: 'Mot de passe',
                  enabled: !busy,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.newPassword],
                  validator: AuthValidators.newPassword,
                ),
                AstreaTextField(
                  controller: _birthDateController,
                  hint: 'Date de naissance (JJ / MM / AAAA)',
                  enabled: !busy,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.birthday],
                  inputFormatters: const <TextInputFormatter>[
                    BirthDateInputFormatter(),
                  ],
                  validator: AuthValidators.birthDate,
                ),
                AuthConsentCheckbox(
                  label: _consentLabel,
                  value: _consentGiven,
                  enabled: !busy,
                  errorText: _showConsentError
                      ? 'Votre accord est nécessaire pour créer un compte.'
                      : null,
                  onChanged: (bool value) => setState(() {
                    _consentGiven = value;
                    _showConsentError = false;
                  }),
                ),
                AstreaButton.primary(
                  label: 'Créer un compte',
                  isLoading: busy,
                  onPressed: _submit,
                ),
                Text(
                  "En continuant, vous acceptez nos Conditions générales d'utilisation.",
                  textAlign: TextAlign.center,
                  style: AppTypography.petit.copyWith(height: 16 / 12),
                ),
                AstreaButton.secondary(
                  label: 'Continuer avec Google',
                  onPressed: busy
                      ? null
                      : () =>
                            showAuthComingSoon(context, 'La connexion Google'),
                ),
              ],
            ),
            // The link's own 12 px padding replaces the 12 px gap.
            AuthLinkButton(
              label: 'Déjà un compte ? Se connecter',
              onPressed: widget.onSwitchToLogin,
            ),
          ],
        ),
      ),
    );
  }
}
