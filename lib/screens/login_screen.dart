import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/form_chrome.dart';
import '../widgets/form_fields.dart';
import '../widgets/glass.dart';

/// Sign-in screen.
///
/// Accepts an email or a phone number in one field, and lands on `/home` for a
/// returning user or `/onboarding` for a first-time one, based on the flag on
/// the record [AuthService] returns.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.auth});

  /// Defaults to the shared [AuthService.instance].
  final AuthService? auth;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthService _auth = widget.auth ?? AuthService.instance;
  final TextEditingController _identifier = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = false;
  bool _submitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _identifier.addListener(_onFieldChanged);
    _password.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _identifier.removeListener(_onFieldChanged);
    _password.removeListener(_onFieldChanged);
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    // Clear a stale error as soon as the user starts fixing the form.
    if (_formError != null) {
      setState(() => _formError = null);
    }
    setState(() {});
  }

  /// The button wakes up once both boxes have something in them; the length rule
/// is the service's call to make, so the failure surfaces under the button
/// rather than gating the tap forever.
bool get _canSubmit =>
    _identifier.text.trim().isNotEmpty &&
    _password.text.isNotEmpty &&
    !_submitting;

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Login',
      onBack: () => AppRouterScope.back(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: <Widget>[
          const SizedBox(height: 12),
          const Center(child: AppLogoBadge(size: 56)),
          const SizedBox(height: 18),
          const _Heading(),
          const SizedBox(height: 24),
          _identifierField(),
          const SizedBox(height: 16),
          _passwordField(),
          const SizedBox(height: 12),
          _optionsRow(),
          const SizedBox(height: 22),
          SolidActionButton(
            label: 'Login',
            loading: _submitting,
            onPressed: _canSubmit ? _submit : null,
          ),
          if (_formError != null) ...<Widget>[
            const SizedBox(height: 10),
            _ErrorText(_formError!),
          ],
          const SizedBox(height: 20),
          AuthLinkPrompt(
            question: "Don't have an account?",
            action: 'Register',
            onTap: () => AppRouterScope.go(context, AppScreen.register),
          ),
        ],
      ),
    );
  }

  Widget _identifierField() => LabeledField(
        label: 'Email or Phone Number',
        child: AppTextField(
          controller: _identifier,
          hint: 'you@example.com or +977 98XXXXXXXX',
          semanticLabel: 'Email or phone number',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _passwordField() => LabeledField(
        label: 'Password',
        errorText: _passwordError,
        child: AppTextField(
          controller: _password,
          hint: 'At least 6 characters',
          semanticLabel: 'Password',
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_canSubmit) {
              _submit();
            }
          },
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: AppIconView(
              _obscure ? AppIcon.eyeOff : AppIcon.eye,
              size: 19,
              color: AppColors.muted,
            ),
            tooltip: _obscure ? 'Show password' : 'Hide password',
          ),
        ),
      );

  /// Only surfaces once the field has focus and is too short, so an untouched
  /// form stays quiet.
  String? get _passwordError {
    if (_password.text.isEmpty) {
      return null;
    }
    return _password.text.length < 6 ? 'Use at least 6 characters' : null;
  }

  Widget _optionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        AppCheckbox(
          value: _rememberMe,
          label: 'Remember Me',
          onChanged: (bool value) => setState(() => _rememberMe = value),
        ),
        Semantics(
          button: true,
          label: 'Forgot password',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => AppRouterScope.go(context, AppScreen.forgotPassword),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _formError = null;
    });
    try {
      final AuthUser user = await _auth.login(
        identifier: _identifier.text,
        password: _password.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) {
        return;
      }
      // A first-time login still has the intro carousel to see.
      final AppScreen destination =
          user.completedOnboarding ? AppScreen.home : AppScreen.onboarding;
      AppRouterScope.of(context).replaceWith(destination);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _formError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _formError = 'Something went wrong. Please try again.';
      });
    }
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.serif,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sign in to continue exploring Nepal',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13.5,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

/// Inline failure message under the button, in the muted red used for
/// validation.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const AppIconView(AppIcon.shield, size: 14, color: AppColors.error),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
