import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../widgets/shared/brand_mark.dart';
import '../../enums/auth/auth_mode.dart';
import '../../widgets/auth/auth_fields.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode mode = widget.initialMode;
  final formKey = GlobalKey<FormState>();
  final identifier = TextEditingController();
  final userName = TextEditingController();
  final email = TextEditingController();
  final mobileNumber = TextEditingController();
  final password = TextEditingController();
  final code = TextEditingController();
  bool codeSent = false;
  bool busy = false;
  bool hidePassword = true;
  String? error;

  @override
  void dispose() {
    for (final controller in [
      identifier,
      userName,
      email,
      mobileNumber,
      password,
      code,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void select(AuthMode value) => setState(() {
    mode = value;
    error = null;
    codeSent = false;
    formKey.currentState?.reset();
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final title = switch (mode) {
      AuthMode.signIn => 'Welcome back.',
      AuthMode.register => 'Join the library.',
      AuthMode.recover => 'Find your way back.',
    };
    final subtitle = switch (mode) {
      AuthMode.signIn => 'Your next chapter is waiting.',
      AuthMode.register => 'Create a space for every story you love.',
      AuthMode.recover => 'We’ll send a code to your saved email.',
    };
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Your account'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(size: 52),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 30),
                    AuthFields(
                      mode: mode,
                      codeSent: codeSent,
                      identifier: identifier,
                      userName: userName,
                      email: email,
                      mobileNumber: mobileNumber,
                      password: password,
                      code: code,
                    ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          error!,
                          style: TextStyle(color: color.error),
                        ),
                      ),
                    const SizedBox(height: 23),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: busy ? null : submit,
                        icon: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                mode == AuthMode.signIn
                                    ? Icons.login_rounded
                                    : mode == AuthMode.register
                                    ? Icons.person_add_alt_rounded
                                    : Icons.mark_email_read_outlined,
                              ),
                        label: Text(switch (mode) {
                          AuthMode.signIn => 'Sign in',
                          AuthMode.register => 'Create account',
                          AuthMode.recover =>
                            codeSent ? 'Reset password' : 'Send code',
                        }),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (mode == AuthMode.signIn) ...[
                      Center(
                        child: TextButton(
                          onPressed: () => select(AuthMode.recover),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => select(AuthMode.register),
                          child: const Text('New here? Create an account'),
                        ),
                      ),
                    ] else
                      Center(
                        child: TextButton.icon(
                          onPressed: () => select(AuthMode.signIn),
                          icon: const Icon(Icons.arrow_back_rounded, size: 17),
                          label: const Text('Back to sign in'),
                        ),
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

  Future<void> submit() async {
    if (formKey.currentState?.validate() != true) return;
    setState(() {
      busy = true;
      error = null;
    });
    final session = AppScope.of(context).session;
    try {
      switch (mode) {
        case AuthMode.signIn:
          await session.signIn(identifier.text.trim(), password.text);
          if (mounted) Navigator.pop(context, true);
          break;
        case AuthMode.register:
          await session.register(
            userName.text.trim(),
            email.text.trim(),
            password.text,
            mobileNumber.text.trim(),
          );
          if (mounted) {
            select(AuthMode.signIn);
            _message('Account created. Sign in to continue.');
          }
          break;
        case AuthMode.recover:
          if (!codeSent) {
            await session.requestReset(identifier.text.trim());
            if (mounted) setState(() => codeSent = true);
            _message(
              'If this account exists, a code was sent to its saved email.',
            );
          } else {
            await session.confirmReset(
              identifier.text.trim(),
              code.text.trim(),
              password.text,
            );
            if (mounted) {
              select(AuthMode.signIn);
              _message('Password changed. Sign in again.');
            }
          }
          break;
      }
    } catch (failure) {
      if (mounted) setState(() => error = '$failure');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
