import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/auth_service.dart';
import '../data/country_data.dart';
import '../data/language_data.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/form_chrome.dart';
import '../widgets/form_fields.dart';
import '../widgets/glass.dart';
import '../widgets/picker_sheet.dart';

/// Create-account form.
///
/// One scrollable page rather than a wizard: ten fields is a lot to split across
/// two steps, and the design calls for a single continuous form.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.auth});

  /// Injected in tests; production runs on [AuthService.instance].
  final AuthService? auth;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ScrollController _scroll = ScrollController();
  final Map<String, String?> _errors = <String, String?>{};

  /// Field keys that have lost focus at least once, or been interacted with.
  /// Errors are only rendered for these, so the form opens clean.
  final Set<String> _touched = <String>{};

  /// Set once the user has pressed Create Account, after which every error is
  /// shown regardless of [_touched].
  bool _showAllErrors = false;

  final Map<String, FocusNode> _focusNodes = <String, FocusNode>{};

  late final AuthService _auth = widget.auth ?? AuthService.instance;
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _address = TextEditingController();
  late final TextEditingController _nationalId = TextEditingController();
  late final TextEditingController _passport = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();

  Gender? _gender;
  Country _dialCountry = Countries.nepal;
  Country? _country;
  AudioGuideLanguage? _audioLanguage;

  bool _obscurePassword = true;
  bool _submitting = false;
  bool _formValid = false;

  @override
  void initState() {
    super.initState();
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _address,
      _nationalId,
      _passport,
      _phone,
      _email,
      _password,
    ]) {
      c.addListener(_revalidate);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    for (final TextEditingController c in <TextEditingController>[
      _name,
      _address,
      _nationalId,
      _passport,
      _phone,
      _email,
      _password,
    ]) {
      c.removeListener(_revalidate);
      c.dispose();
    }
    for (final FocusNode node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  /// A focus node that flags its field as visited the moment focus leaves it,
  /// which is when its error message should start showing.
  FocusNode _nodeFor(String key) {
    return _focusNodes.putIfAbsent(key, () {
      final FocusNode node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) {
          _touch(key);
        }
      });
      return node;
    });
  }

  void _touch(String key) {
    if (_touched.contains(key)) {
      return;
    }
    setState(() {
      _touched.add(key);
      _revalidateLocked();
    });
  }

  /// The error to render for [key], or null if the field has not been visited.
  String? _errorFor(String key) =>
      (_showAllErrors || _touched.contains(key)) ? _errors[key] : null;

  // ── Validation ────────────────────────────────────────────────────────────

  static final RegExp _emailPattern =
      RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$');
  static final RegExp _alphanumeric = RegExp(r'^[A-Za-z0-9]+$');
  static final RegExp _digits = RegExp(r'^[0-9]+$');

  String? _validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Enter at least 2 characters';
    }
    return null;
  }

  String? _validateAddress(String value) =>
      value.trim().isEmpty ? 'Residential address is required' : null;

  String? _validateNationalId(String value) {
    final String v = value.trim();
    if (v.isEmpty) {
      return 'National ID is required';
    }
    if (!_alphanumeric.hasMatch(v)) {
      return 'Letters and numbers only';
    }
    return null;
  }

  String? _validatePassport(String value) {
    final String v = value.trim();
    if (v.isEmpty) {
      return 'Passport number is required';
    }
    if (!_alphanumeric.hasMatch(v)) {
      return 'Letters and numbers only';
    }
    return null;
  }

  String? _validatePhone(String value) {
    final String v = value.trim();
    if (v.isEmpty) {
      return 'Contact phone is required';
    }
    if (!_digits.hasMatch(v)) {
      return 'Digits only';
    }
    // Allow a digit either side of the country's typical length, since carriers
    // are not consistent about leading zeros.
    final int expected = _dialCountry.nsnLength;
    if ((v.length - expected).abs() > 1) {
      return 'Expected about $expected digits for ${_dialCountry.name}';
    }
    return null;
  }

  String? _validateEmail(String value) {
    final String v = value.trim();
    if (v.isEmpty) {
      return 'Email address is required';
    }
    if (!_emailPattern.hasMatch(v)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// The account password. The length floor is the same constant the service
  /// enforces, so the form and the (fake) backend agree on what is acceptable.
  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  /// Recomputes every error and the button's enabled state.
  ///
  /// Errors are only *shown* once a field has been visited (see [_errorFor]),
  /// but running the validators on every keystroke anyway is what keeps the CTA
  /// in sync and clears each message as soon as it is fixed.
  void _revalidate() {
    if (!mounted) {
      return;
    }
    setState(_revalidateLocked);
  }

  void _revalidateLocked() {
    _errors['name'] = _validateName(_name.text);
    _errors['address'] = _validateAddress(_address.text);
    _errors['nationalId'] = _validateNationalId(_nationalId.text);
    _errors['passport'] = _validatePassport(_passport.text);
    _errors['phone'] = _validatePhone(_phone.text);
    _errors['email'] = _validateEmail(_email.text);
    _errors['password'] = _validatePassword(_password.text);
    _errors['gender'] = _gender == null ? 'Gender is required' : null;
    _errors['country'] = _country == null ? 'Country is required' : null;
    _errors['audio'] = _audioLanguage == null ? 'Audio guide language is required' : null;
    _formValid = _errors.values.every((String? e) => e == null);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          FormAppBar(
            title: 'Create Account',
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: <Widget>[
                const _RegisterIntro(),
                const SizedBox(height: 18),
                _nameField(),
                const SizedBox(height: 16),
                _addressField(),
                const SizedBox(height: 16),
                _genderField(),
                const SizedBox(height: 16),
                _nationalIdField(),
                const SizedBox(height: 16),
                _passportField(),
                const SizedBox(height: 16),
                _phoneField(),
                const SizedBox(height: 16),
                _emailField(),
                const SizedBox(height: 16),
                _passwordField(),
                const SizedBox(height: 16),
                _countryField(),
                const SizedBox(height: 16),
                _audioField(),
                const SizedBox(height: 24),
                SolidActionButton(
                  label: 'Create Account',
                  loading: _submitting,
                  onPressed: _formValid && !_submitting ? _submit : null,
                ),
                const SizedBox(height: 14),
                AuthLinkPrompt(
                  question: 'Already have an account?',
                  action: 'Login',
                  onTap: () => AppRouterScope.go(context, AppScreen.login),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameField() => LabeledField(
        label: 'Full Name',
        errorText: _errorFor('name'),
        child: AppTextField(
          controller: _name,
          focusNode: _nodeFor('name'),
          hint: 'e.g. Prabika Rai',
          semanticLabel: 'Full name',
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _addressField() => LabeledField(
        label: 'Residential Address',
        errorText: _errorFor('address'),
        child: AppTextField(
          controller: _address,
          focusNode: _nodeFor('address'),
          hint: 'Street, city, state, postal code',
          semanticLabel: 'Residential address',
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.streetAddress,
          minLines: 2,
          maxLines: 2,
        ),
      );

  Widget _genderField() => LabeledField(
        label: 'Gender',
        errorText: _errorFor('gender'),
        child: SegmentedChoice<Gender>(
          options: Gender.values,
          selected: _gender,
          labelBuilder: (Gender g) => g.label,
          onChanged: (Gender g) => setState(() {
            _gender = g;
            _touched.add('gender');
            _revalidateLocked();
          }),
        ),
      );

  Widget _nationalIdField() => LabeledField(
        label: 'National ID (from your country of residence)',
        errorText: _errorFor('nationalId'),
        child: AppTextField(
          controller: _nationalId,
          focusNode: _nodeFor('nationalId'),
          hint: 'Alphanumeric ID number',
          semanticLabel: 'National ID',
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[_AlphanumericFormatter()],
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _passportField() => LabeledField(
        label: 'Passport Number',
        errorText: _errorFor('passport'),
        child: AppTextField(
          controller: _passport,
          focusNode: _nodeFor('passport'),
          hint: 'e.g. P1234567',
          semanticLabel: 'Passport number',
          keyboardType: TextInputType.text,
          inputFormatters: <TextInputFormatter>[_AlphanumericFormatter()],
          textInputAction: TextInputAction.next,
        ),
      );

  Widget _phoneField() => LabeledField(
        label: 'Contact Phone',
        errorText: _errorFor('phone'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CountryCodeButton(
              country: _dialCountry,
              onTap: _pickDialCountry,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 46,
                child: AppTextField(
                  controller: _phone,
                  focusNode: _nodeFor('phone'),
                  hint: _phoneHint,
                  semanticLabel: 'Phone number',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _emailField() => LabeledField(
        label: 'Email Address',
        errorText: _errorFor('email'),
        child: AppTextField(
          controller: _email,
          focusNode: _nodeFor('email'),
          hint: 'you@example.com',
          semanticLabel: 'Email address',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
      );

  /// The account password, with the same reveal toggle the login screen uses so
  /// a mistyped value can be checked before submitting.
  Widget _passwordField() => LabeledField(
        label: 'Password',
        helperText: 'At least $minPasswordLength characters. You will use this to sign in.',
        errorText: _errorFor('password'),
        child: AppTextField(
          controller: _password,
          focusNode: _nodeFor('password'),
          hint: 'Create a password',
          semanticLabel: 'Password',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          suffix: IconButton(
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            icon: AppIconView(
              _obscurePassword ? AppIcon.eyeOff : AppIcon.eye,
              size: 19,
              color: AppColors.muted,
            ),
            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
          ),
        ),
      );

  Widget _countryField() => LabeledField(
        label: 'Country',
        errorText: _errorFor('country'),
        child: AppPickerField(
          value: _country?.name ?? '',
          placeholder: 'Select country',
          semanticLabel: 'Country of residence',
          onTap: _pickCountry,
          leading: _country == null
              ? null
              : CountryIsoBadge(iso: _country!.iso, color: _country!.badgeColor),
        ),
      );

  Widget _audioField() => LabeledField(
        label: 'Preferred Audio Guide Language',
        helperText: 'The language recorded guides are played in. This is separate '
            'from the app display language set on the welcome screen.',
        errorText: _errorFor('audio'),
        child: AppPickerField(
          value: _audioLanguage?.label ?? '',
          placeholder: 'Select language',
          semanticLabel: 'Preferred audio guide language',
          onTap: _pickAudioLanguage,
        ),
      );

  /// Pre-fills the expected digit count so the length rule is discoverable
  /// before the user types.
  String get _phoneHint => '0'.padRight(_dialCountry.nsnLength, '0');

  // ── Pickers ──────────────────────────────────────────────────────────────

  Future<void> _pickDialCountry() async {
    await showCountrySheet(
      context: context,
      selected: _dialCountry,
      onSelected: (Country c) => setState(() {
        _dialCountry = c;
        _touched.add('phone');
        // The expected length is country-dependent, so the phone error has to be
        // recomputed against the new dial code.
        _revalidateLocked();
      }),
    );
  }

  Future<void> _pickCountry() async {
    await showCountrySheet(
      context: context,
      selected: _country ?? Countries.nepal,
      onSelected: (Country c) => setState(() {
        _country = c;
        _touched.add('country');
        _revalidateLocked();
      }),
    );
  }

  Future<void> _pickAudioLanguage() async {
    await showPickerSheet<AudioGuideLanguage>(
      context: context,
      title: 'Audio Guide Language',
      options: AudioGuideLanguages.all,
      labelBuilder: (AudioGuideLanguage l) => l.englishName,
      trailingBuilder: (AudioGuideLanguage l) => l.nativeName,
      isSelected: (AudioGuideLanguage l) => l.code == _audioLanguage?.code,
      onSelected: (AudioGuideLanguage l) => setState(() {
        _audioLanguage = l;
        _touched.add('audio');
        _revalidateLocked();
      }),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Reveal every outstanding message, in case something is still invalid.
    setState(() {
      _showAllErrors = true;
      _touched.addAll(<String>[
        'name',
        'address',
        'gender',
        'nationalId',
        'passport',
        'phone',
        'email',
        'password',
        'country',
        'audio',
      ]);
      _revalidateLocked();
    });
    if (!_formValid) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _auth.register(
        RegistrationRequest(
          fullName: _name.text.trim(),
          address: _address.text.trim(),
          gender: _gender!,
          nationalId: _nationalId.text.trim(),
          passportNumber: _passport.text.trim(),
          dialCode: _dialCountry.dialCode,
          phone: _phone.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          country: _country!,
          audioGuideLanguage: _audioLanguage!,
        ),
      );
      if (!mounted) {
        return;
      }
      // Swapped in, not pushed: the completed form should not be reachable with
      // the back gesture once the account exists.
      AppRouterScope.of(context).replaceWith(AppScreen.onboarding);
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      _showError(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppFonts.body, fontSize: 13),
        ),
        backgroundColor: AppColors.charcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// One-line explainer under the app bar, saying why the form asks for what it
/// asks for.
class _RegisterIntro extends StatelessWidget {
  const _RegisterIntro();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your details let us issue tickets, verify travel documents, and narrate '
      'each site in your language.',
      style: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 13,
        height: 1.55,
        color: AppColors.body,
      ),
    );
  }
}

/// Keeps the text fields to letters and digits, which is what both the national
/// ID and the passport number accept.
class _AlphanumericFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), ''),
    );
  }
}
