import 'package:flutter/material.dart';

import '../data/country_data.dart';
import '../theme/app_theme.dart';
import 'app_icons.dart';
import 'form_fields.dart';

/// A single row in a picker sheet: ISO badge, name, and a check when selected.
class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.iso,
    this.badgeColor,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? iso;
  final Color? badgeColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          child: Row(
            children: <Widget>[
              if (iso != null) ...<Widget>[
                CountryIsoBadge(
                  iso: iso!,
                  color: badgeColor ?? AppColors.forest,
                  size: 26,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              if (trailing != null) ...<Widget>[
                trailing!,
                const SizedBox(width: 10),
              ],
              if (selected)
                const AppIconView(AppIcon.check, size: 17, color: AppColors.forest, strokeWidth: 2.4),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet hosting a scrollable, optionally searchable list.
///
/// The registration form uses this for gender, country and audio guide
/// language, so they all get the same sheet chrome instead of three slightly
/// different dropdowns.
Future<T?> showPickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> options,
  required String Function(T option) labelBuilder,
  required bool Function(T option) isSelected,
  required ValueChanged<T> onSelected,
  bool searchable = false,
  String? searchHint,
  String Function(T option)? isoBuilder,
  Color Function(T option)? badgeColorBuilder,
  String Function(T option)? trailingBuilder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return _PickerSheet<T>(
        title: title,
        options: options,
        labelBuilder: labelBuilder,
        isSelected: isSelected,
        onSelected: onSelected,
        searchable: searchable,
        searchHint: searchHint,
        isoBuilder: isoBuilder,
        badgeColorBuilder: badgeColorBuilder,
        trailingBuilder: trailingBuilder,
      );
    },
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.labelBuilder,
    required this.isSelected,
    required this.onSelected,
    required this.searchable,
    this.searchHint,
    this.isoBuilder,
    this.badgeColorBuilder,
    this.trailingBuilder,
  });

  final String title;
  final List<T> options;
  final String Function(T option) labelBuilder;
  final bool Function(T option) isSelected;
  final ValueChanged<T> onSelected;
  final bool searchable;
  final String? searchHint;
  final String Function(T option)? isoBuilder;
  final Color Function(T option)? badgeColorBuilder;
  final String Function(T option)? trailingBuilder;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final TextEditingController _query = TextEditingController();
  String _term = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  /// The filtered list, recomputed on every keystroke. The option lists here are
  /// a couple of hundred entries at most, so filtering in memory is fine.
  List<T> get _visible {
    if (!widget.searchable || _term.isEmpty) {
      return widget.options;
    }
    final String q = _term.toLowerCase();
    return widget.options
        .where((T option) =>
            widget.labelBuilder(option).toLowerCase().contains(q) ||
            (widget.isoBuilder?.call(option).toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<T> visible = _visible;
    // Lift the sheet above the keyboard when it is open so the search field and
    // the first few results stay reachable.
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Grab handle.
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.fieldBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: AppFonts.serif,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.searchable) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _query,
                    autofocus: false,
                    onChanged: (String value) => setState(() => _term = value),
                    cursorColor: AppColors.forest,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      color: AppColors.charcoal,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.searchHint ?? 'Search',
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      prefixIcon: const AppIconView(
                        AppIcon.search,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      hintStyle: const TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        borderSide: const BorderSide(color: AppColors.fieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        borderSide: const BorderSide(color: AppColors.fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        borderSide: const BorderSide(color: AppColors.forest, width: 1.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Flexible(
              child: visible.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'No matches',
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 12,
                      ),
                      itemCount: visible.length,
                      itemBuilder: (BuildContext context, int index) {
                        final T option = visible[index];
                        return _OptionRow<T>(
                          label: widget.labelBuilder(option),
                          selected: widget.isSelected(option),
                          iso: widget.isoBuilder?.call(option),
                          badgeColor: widget.badgeColorBuilder?.call(option),
                          trailing: widget.trailingBuilder == null
                              ? null
                              : Text(
                                  widget.trailingBuilder!(option),
                                  style: const TextStyle(
                                    fontFamily: AppFonts.body,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.muted,
                                  ),
                                ),
                          onTap: () {
                            widget.onSelected(option);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience wrapper for the searchable country list, which both the phone
/// code picker and the country-of-residence field open.
Future<Country?> showCountrySheet({
  required BuildContext context,
  required Country selected,
  required ValueChanged<Country> onSelected,
}) {
  return showPickerSheet<Country>(
    context: context,
    title: 'Select Country',
    options: Countries.all,
    searchable: true,
    searchHint: 'Search by name or code',
    labelBuilder: (Country c) => c.name,
    isoBuilder: (Country c) => c.iso,
    badgeColorBuilder: (Country c) => c.badgeColor,
    trailingBuilder: (Country c) => c.dialCode,
    isSelected: (Country c) => c.iso == selected.iso,
    onSelected: onSelected,
  );
}
