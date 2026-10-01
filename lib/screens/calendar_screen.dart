import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../data/models.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/app_card.dart';
import '../widgets/app_status_bar.dart';
import '../widgets/network_photo.dart';

enum _CalendarView { list, month }

/// Cultural calendar with list and month views.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  _CalendarView _view = _CalendarView.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Column(
        children: <Widget>[
          _Header(
            view: _view,
            onViewChanged: (_CalendarView value) =>
                setState(() => _view = value),
          ),
          Expanded(
            child: _view == _CalendarView.list
                ? const _FestivalList()
                : const _MonthView(),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.view, required this.onViewChanged});

  final _CalendarView view;
  final ValueChanged<_CalendarView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.charcoal,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AppStatusBar(light: true),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Cultural Calendar',
                    style: TextStyle(
                      fontFamily: AppFonts.serif,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        for (final _CalendarView option in _CalendarView.values)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onViewChanged(option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: option == view
                                    ? AppColors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                option.name,
                                style: TextStyle(
                                  fontFamily: AppFonts.body,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: option == view
                                      ? AppColors.charcoal
                                      : AppColors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                MockData.calendarRange,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: AppColors.white.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FestivalList extends StatelessWidget {
  const _FestivalList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: MockData.festivals.length,
      itemBuilder: (BuildContext context, int index) {
        final Festival festival = MockData.festivals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            radius: AppRadii.xl,
            padding: EdgeInsets.zero,
            onTap: () => AppRouterScope.go(context, AppScreen.festivalDetail),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    width: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        NetworkPhoto(url: festival.image),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(height: 4, color: festival.color),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  festival.name,
                                  style: AppText.serifRow,
                                ),
                              ),
                              if (index == 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.145),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEXT UP',
                                    style: TextStyle(
                                      fontFamily: AppFonts.body,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoal,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            festival.date,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: festival.color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${festival.description.substring(0, 60)}\u2026',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView();

  /// Indra Jatra runs Oct 3-12, Dashain Oct 13-23.
  static Color? _colorFor(int day) {
    if (day >= 3 && day <= 12) {
      return AppColors.festivalIndraJatra;
    }
    if (day >= 13 && day <= 23) {
      return AppColors.festivalDashain;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final int blanks = MockData.octoberLeadingBlanks;
    final int days = MockData.octoberDays;
    final int totalCells = blanks + days;
    // Pad the final row out to a whole week.
    final int padded = (totalCells / 7).ceil() * 7;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: <Widget>[
        AppCard(
          child: Column(
            children: <Widget>[
              const Center(
                child: Text(
                  '\u2190 October 2026 \u2192',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  for (final String label in <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                    Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: padded,
                itemBuilder: (BuildContext context, int index) {
                  final int day = index - blanks + 1;
                  if (day < 1 || day > days) {
                    return const SizedBox.shrink();
                  }
                  final Color? color = _colorFor(day);
                  return Container(
                    decoration: BoxDecoration(
                      color: color?.withValues(alpha: 0.125),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '$day',
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 13,
                            fontWeight: color == null
                                ? FontWeight.w400
                                : FontWeight.w700,
                            color: color ?? AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (color != null)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              for (final Festival festival in MockData.festivals.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _LegendRow(festival: festival),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.festival});

  final Festival festival;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => AppRouterScope.go(context, AppScreen.festivalDetail),
      child: Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: festival.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13,
                  color: AppColors.charcoal,
                ),
                children: <InlineSpan>[
                  TextSpan(text: '${festival.date} \u00b7 '),
                  TextSpan(
                    text: festival.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
