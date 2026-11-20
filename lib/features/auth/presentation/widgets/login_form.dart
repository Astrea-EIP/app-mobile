import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:astrea/core/widgets/widgets.dart';
import 'package:astrea/features/auth/presentation/auth_validators.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:astrea/features/auth/presentation/bloc/auth_event.dart';
import 'package:astrea/features/auth/presentation/widgets/auth_link_button.dart';

/// "Se connecter" form. Vertical rhythm follows Figma: 12 px between
/// controls, links carry their own 12 px padding (see [AuthLinkButton]).
class LoginForm extends StatefulWidget {
  const LoginForm({required this.onSwitchToRegister, super.key});

  final VoidCallback onSwitchToRegister;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (context.read<AuthBloc>().state.isSubmitting) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    TextInput.finishAutofillContext();
    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
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
            AstreaTextField(
              controller: _emailController,
              hint: 'Adresse e-mail',
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const <String>[AutofillHints.email],
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 12),
            AstreaTextField(
              controller: _passwordController,
              hint: 'Mot de passe',
              enabled: !busy,
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofillHints: const <String>[AutofillHints.password],
              validator: AuthValidators.requiredPassword,
              onFieldSubmitted: (_) => _submit(),
            ),
            AuthLinkButton(
              label: 'Mot de passe oublié ?',
              alignment: Alignment.centerLeft,
              onPressed: () =>
                  showAuthComingSoon(context, 'La réinitialisation'),
            ),
            AstreaButton.primary(
              label: 'Se connecter',
              isLoading: busy,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            AstreaButton.secondary(
              label: 'Continuer avec Google',
              onPressed: busy
                  ? null
                  : () => showAuthComingSoon(context, 'La connexion Google'),
            ),
            AuthLinkButton(
              label: 'Pas encore de compte ? Créer un compte',
              onPressed: widget.onSwitchToRegister,
            ),
          ],
        ),
      ),
    );
  }
}
