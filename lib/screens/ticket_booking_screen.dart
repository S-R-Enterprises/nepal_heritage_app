import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/buttons.dart';

/// Ticket checkout: date picker, visitor steppers, payment method and a live
/// order summary.
class TicketBookingScreen extends StatefulWidget {
  const TicketBookingScreen({super.key});

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  int _adults = 1;
  int _children = 0;
  PaymentMethod _method = PaymentMethod.esewa;
  String _date = 'Wed, Oct 8${MockData.bookingDateYearSuffix}';

  int get _total => _adults * MockData.adultPrice + _children * MockData.childPrice;

  @override
  Widget build(BuildContext context) {
    final AppRouter router = AppRouterScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'Book Entry Ticket',
            subtitle: MockData.heritageTitle,
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  _DateCard(
                    date: _date,
                    onChanged: (String value) => setState(() => _date = value),
                  ),
                  const SizedBox(height: 16),
                  _VisitorsCard(
                    adults: _adults,
                    children: _children,
                    onAdultsChanged: (int value) =>
                        setState(() => _adults = value),
                    onChildrenChanged: (int value) =>
                        setState(() => _children = value),
                  ),
                  const SizedBox(height: 16),
                  _PaymentCard(
                    method: _method,
                    onChanged: (PaymentMethod value) =>
                        setState(() => _method = value),
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    adults: _adults,
                    children: _children,
                    total: _total,
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: 'Pay NPR ${_format(_total)} via ${_method.label}',
              onPressed: () => router.go(AppScreen.ticketConfirm),
            ),
          ),
        ],
      ),
    );
  }
}

String _format(int value) {
  final String digits = value.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.date, required this.onChanged});

  final String date;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Dates are stored as "Wed, Oct 8, 2026"; the chip label is the "Wed, Oct 8"
    // prefix, so a startsWith check identifies the active chip.
    final String selectedDay = date.split(',').first.trim();

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Visit Date', fontSize: 13, bottom: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.bookingDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final String label = MockData.bookingDates[index];
                final bool active = label.startsWith(selectedDay);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      onChanged('$label${MockData.bookingDateYearSuffix}'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.forest : AppColors.cream,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.white : AppColors.charcoal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorsCard extends StatelessWidget {
  const _VisitorsCard({
    required this.adults,
    required this.children,
    required this.onAdultsChanged,
    required this.onChildrenChanged,
  });

  final int adults;
  final int children;
  final ValueChanged<int> onAdultsChanged;
  final ValueChanged<int> onChildrenChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Visitors', fontSize: 13, bottom: 14),
          _VisitorRow(
            label: 'Adults',
            sub: 'Age 18+',
            price: MockData.adultPrice,
            count: adults,
            min: 1,
            onChanged: onAdultsChanged,
          ),
          _VisitorRow(
            label: 'Children',
            sub: 'Age 5\u201317',
            price: MockData.childPrice,
            count: children,
            min: 0,
            onChanged: onChildrenChanged,
          ),
        ],
      ),
    );
  }
}

class _VisitorRow extends StatelessWidget {
  const _VisitorRow({
    required this.label,
    required this.sub,
    required this.price,
    required this.count,
    required this.min,
    required this.onChanged,
  });

  final String label;
  final String sub;
  final int price;
  final int count;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NPR ${_format(price)}/person \u00b7 $sub',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Row(
            children: <Widget>[
              RoundIconButton(
                icon: AppIcon.minus,
                size: 32,
                iconSize: 20,
                background: AppColors.cream,
                foreground: AppColors.charcoal,
                borderColor: AppColors.parchment,
                borderWidth: 1.5,
                onPressed: count > min ? () => onChanged(count - 1) : null,
              ),
              SizedBox(
                width: 20,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              RoundIconButton(
                icon: AppIcon.plus,
                size: 32,
                iconSize: 20,
                background: AppColors.forest,
                foreground: AppColors.white,
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.method, required this.onChanged});

  final PaymentMethod method;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Payment Method', fontSize: 13, bottom: 14),
          for (final PaymentMethod option in PaymentMethod.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PaymentRow(
                option: option,
                selected: option == method,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.parchment,
            width: 2,
          ),
          color: selected
              ? AppColors.forest.withValues(alpha: 0.03)
              : AppColors.cream,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: option.color,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(
                option.logo,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: option == PaymentMethod.card ? 18 : 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              option.label,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.forest : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.forest : AppColors.muted,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.adults,
    required this.children,
    required this.total,
  });

  final int adults;
  final int children;
  final int total;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Order Summary', fontSize: 13, bottom: 12),
          if (adults > 0)
            _SummaryLine(
              label: '${adults}x Adult Entry',
              value: 'NPR ${_format(adults * MockData.adultPrice)}',
            ),
          if (children > 0)
            _SummaryLine(
              label: '${children}x Child Entry',
              value: 'NPR ${_format(children * MockData.childPrice)}',
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.parchment),
          ),
          _SummaryLine(
            label: 'Total',
            value: 'NPR ${_format(total)}',
            emphasised: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: emphasised ? 15 : 13,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w400,
              color: emphasised ? AppColors.charcoal : AppColors.muted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: emphasised ? 15 : 13,
              fontWeight: emphasised ? FontWeight.w700 : FontWeight.w400,
              color: emphasised ? AppColors.forest : AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
