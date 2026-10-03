import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_icons.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/buttons.dart';
import '../widgets/network_photo.dart';
import '../widgets/pill.dart';

/// Guide profile with credentials, stats, reviews and a booking form whose
/// total scales with the selected duration.
class GuideProfileScreen extends StatefulWidget {
  const GuideProfileScreen({super.key});

  @override
  State<GuideProfileScreen> createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  int _hours = 4;
  int _dateIndex = 0;

  /// The prototype charges a flat daily rate pro-rated by hours in an 8h day.
  int get _price => (MockData.guideHourlyRate * _hours / 8).round();

  /// Confirms the booking on a summary sheet instead of dumping the user on
  /// the entry-ticket QR screen (a guide walk has no ticket to scan).
  void _confirmBooking(BuildContext context) {
    final Object? arg = AppRouterScope.of(context).arg;
    final String guideName = arg is Guide ? arg.name : MockData.guideName;
    final String date = MockData.guideDates[_dateIndex];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'BOOKING REQUESTED',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.forest.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Booking requested!',
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$guideName · $date · $_hours hrs — total \$$_price. '
                  'The guide confirms within a few hours and payment follows '
                  'the walk.',
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.body,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Done',
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The tapped guide (home row, all-guides list); static copy is the
    // no-payload fallback.
    final Guide? guide =
        AppRouterScope.of(context).arg is Guide
            ? AppRouterScope.of(context).arg as Guide
            : null;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          ScreenHeader(
            title: 'Guide Profile',
            background: AppColors.charcoal,
            onBack: () => AppRouterScope.back(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  _ProfileCard(guide: guide),
                  const SizedBox(height: 16),
                  const _StatsRow(),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const CardHeading('About'),
                        Text(
                          MockData.guideAbout,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _ReviewsSection(),
                  const SizedBox(height: 16),
                  _BookingCard(
                    hours: _hours,
                    dateIndex: _dateIndex,
                    price: _price,
                    onHoursChanged: (int value) =>
                        setState(() => _hours = value),
                    onDateChanged: (int value) =>
                        setState(() => _dateIndex = value),
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: 'Confirm Booking \u00b7 \$$_price',
              color: AppColors.forest,
              foregroundColor: AppColors.white,
              onPressed: () => _confirmBooking(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({this.guide});

  /// The guide being viewed; falls back to the prototype's static profile.
  final Guide? guide;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      shadows: const <BoxShadow>[],
      child: Column(
        children: <Widget>[
          Avatar(
            url: guide?.avatar ?? Img.avatarAaravLarge,
            size: 80,
            borderWidth: 3,
          ),
          const SizedBox(height: 14),
          Text(
            guide?.name ?? MockData.guideName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            MockData.guideCredentials,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const StarRow(count: 5),
              const SizedBox(width: 4),
              Text(
                guide?.rating.toStringAsFixed(1) ?? '4.9',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                ' ${MockData.guideReviewCount}',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String tag in MockData.guideTags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.forest,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < MockData.guideStats.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              shadows: const <BoxShadow>[],
              child: Column(
                children: <Widget>[
                  Text(
                    MockData.guideStats[i].value,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MockData.guideStats[i].label,
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CardHeading('Recent Reviews', bottom: 0),
        ),
        for (final Review review in MockData.guideReviews)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              radius: AppRadii.lg,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.parchment,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          review.flag!,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            review.name,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                          StarRow(count: review.rating),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${review.text}"',
                    style: const TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.hours,
    required this.dateIndex,
    required this.price,
    required this.onHoursChanged,
    required this.onDateChanged,
  });

  final int hours;
  final int dateIndex;
  final int price;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const CardHeading('Book This Guide', bottom: 14),
          const Text(
            'Select Date',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MockData.guideDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final bool active = index == dateIndex;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDateChanged(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.forest : AppColors.cream,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      MockData.guideDates[index],
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
          const SizedBox(height: 12),
          const Text(
            'Duration',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
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
                onPressed: hours > 2 ? () => onHoursChanged(hours - 1) : null,
              ),
              const SizedBox(width: 16),
              Text(
                '$hours hours',
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              RoundIconButton(
                icon: AppIcon.plus,
                size: 32,
                iconSize: 20,
                background: AppColors.forest,
                foreground: AppColors.white,
                onPressed: hours < 8 ? () => onHoursChanged(hours + 1) : null,
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                  children: <InlineSpan>[
                    const TextSpan(text: 'Total: '),
                    TextSpan(
                      text: '\$$price',
                      style: const TextStyle(
                        color: AppColors.forest,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
