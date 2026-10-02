import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/country_data.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';

/// A labelled form control.
///
/// The design puts the label *above* the field rather than using a floating
/// placeholder, so the two are separate: [label] is always visible in
/// charcoal, and [hint] is the lighter text inside the box.
class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    required this.child,
    super.key,
    this.hint,
    this.errorText,
    this.helperText,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        const SizedBox(height: 6),
        child,
        if (helperText != null) ...<Widget>[
          const SizedBox(height: 5),
          Text(
            helperText!,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
        ],
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: const TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// The text input used by both form screens.
///
/// Validation is reported through [errorText] rather than the built-in
/// `InputDecoration.errorText`, so the message always renders in the muted red
/// below the box with the layout the design specifies.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.suffix,
    this.inputFormatters,
    this.focusNode,
    this.semanticLabel,
  });

  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        autofocus: autofocus,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
        minLines: obscureText ? 1 : minLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        inputFormatters: inputFormatters,
        cursorColor: AppColors.forest,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 14,
          color: AppColors.charcoal,
        ),
        decoration: InputDecoration(
          hintText: hint,
          // `AppTextField` renders its own message below the box, so the
          // built-in one is suppressed here to avoid it appearing twice.
          errorText: null,
          suffixIcon: suffix,
          filled: true,
          fillColor: enabled ? AppColors.white : AppColors.parchment,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          hintStyle: const TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 13,
            color: AppColors.muted,
          ),
          border: _border(AppColors.fieldBorder),
          enabledBorder: _border(AppColors.fieldBorder),
          disabledBorder: _border(AppColors.fieldBorder),
          focusedBorder: _border(AppColors.forest, width: 1.6),
          suffixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// A read-only field that looks identical to [AppTextField] but opens a picker
/// when tapped. Used for the country, gender and audio-language controls.
class AppPickerField extends StatelessWidget {
  const AppPickerField({
    required this.value,
    required this.onTap,
    super.key,
    this.placeholder = 'Select',
    this.errorText,
    this.leading,
    this.semanticLabel,
  });

  /// Display string, or empty when nothing is selected yet.
  final String value;
  final VoidCallback onTap;
  final String placeholder;
  final String? errorText;
  final Widget? leading;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool empty = value.isEmpty;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.fieldBorder,
                width: errorText != null ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    empty ? placeholder : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      color: empty ? AppColors.muted : AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const AppIconView(
                  AppIcon.chevronDown,
                  size: 16,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three-way segmented control used for gender.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  final List<T> options;
  final T? selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: AppColors.fieldBorder),
      ),
      child: Row(
        children: <Widget>[
          for (final T option in options)
            Expanded(
              child: _Segment<T>(
                label: labelBuilder(option),
                active: option == selected,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: active ? AppColors.forest : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? AppColors.white : AppColors.charcoal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square checkbox + label for "Remember Me".
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: value ? AppColors.forest : AppColors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: value ? AppColors.forest : AppColors.fieldBorder,
                  width: 1.2,
                ),
              ),
              child: value
                  ? const AppIconView(AppIcon.check, size: 12, color: AppColors.white, strokeWidth: 2.6)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                color: AppColors.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The country-code chip beside the phone field: an ISO badge plus the dial
/// code, opening the searchable country list.
class CountryCodeButton extends StatelessWidget {
  const CountryCodeButton({required this.country, required this.onTap, super.key});

  final Country country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Country code, ${country.pickerLabel}',
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.fieldBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CountryIsoBadge(iso: country.iso, color: country.badgeColor),
                const SizedBox(width: 7),
                Text(
                  country.dialCode,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
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

/// Small rounded badge showing a country's ISO code.
///
/// Used wherever the design calls for a flag: it is a text chip, so it renders
/// identically on every platform instead of depending on whether the device has
/// an emoji flag font installed.
class CountryIsoBadge extends StatelessWidget {
  const CountryIsoBadge({required this.iso, required this.color, super.key, this.size = 22});

  final String iso;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        iso,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: AppColors.white,
        ),
      ),
    );
  }
}
