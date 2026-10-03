import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/data/mock_data.dart';
import 'package:nepal_np/data/models.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/calendar_screen.dart';
import 'package:nepal_np/screens/festival_detail_screen.dart';
import 'package:nepal_np/screens/heritage_detail_screen.dart';
import 'package:nepal_np/screens/guide_profile_screen.dart';
import 'package:nepal_np/screens/hidden_gems_screen.dart';
import 'package:nepal_np/screens/ticket_confirm_screen.dart';

import 'test_helpers.dart';

/// Batch-2 coverage: router payloads, the gems filter, the guide-booking
/// confirmation and the calendar truncation crash.
void main() {
  setUpAll(loadRealFonts);

  test('calendarSnippet never throws on short descriptions', () {
    expect(calendarSnippet('Short one.'), 'Short one.');
    expect(calendarSnippet('y' * 60), 'y' * 60);
    expect(calendarSnippet('x' * 80), '${'x' * 60}\u2026');
  });

  testWidgets('tapped site opens the detail carrying that site',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final HeritageSite site = MockData.heritageSites.first;
    final Finder card = find.text(site.name);
    await tester.scrollUntilVisible(card, 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(HeritageDetailScreen), findsOneWidget);
    expect(find.text(site.name), findsWidgets);
    expect(find.text(site.location), findsWidgets);
  });

  testWidgets('tapped festival opens the detail carrying that festival',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.calendar);
    await tester.pumpAndSettle();

    // The generic (no-payload) entry is Indra Jatra — Dashain proves the
    // payload reached the screen.
    final Finder card = find.text('Dashain');
    await tester.scrollUntilVisible(card, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(card);
    await tester.pumpAndSettle();

    expect(find.byType(FestivalDetailScreen), findsOneWidget);
    expect(find.text('Dashain'), findsWidgets);
    expect(find.textContaining('Oct 13'), findsWidgets);
  });

  testWidgets('gems feed filters by category and distance',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.gems);
    await tester.pumpAndSettle();
    expect(find.byType(HiddenGemsScreen), findsOneWidget);

    await tester.tap(find.text('Temples'));
    await tester.pumpAndSettle();
    expect(find.text('Khokana Hidden Temple'), findsWidgets);
    expect(find.text('Sankhu Bajrayogini'), findsWidgets);
    expect(find.text('Nagarkot Sunrise Spot'), findsNothing);

    await tester.tap(find.text('Near Me'));
    await tester.pumpAndSettle();
    expect(find.text('Shivapuri Peak Trail'), findsWidgets);
    expect(find.text('Khokana Hidden Temple'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('Nagarkot Sunrise Spot'), findsWidgets);
  });

  testWidgets('guide booking confirms on a summary sheet, not a ticket QR',
      (WidgetTester tester) async {
    await pumpHome(tester);

    final Guide guide = MockData.guides.first;
    final Finder card = find.text(guide.name);
    await tester.scrollUntilVisible(card, 200,
        scrollable: find.byType(Scrollable).first);
    // The lazy scroll stops at the bottom edge, where the tab bar obscures the
    // card — nudge it into the clear before tapping.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byType(GuideProfileScreen), findsOneWidget);

    await tester.tap(find.textContaining('Confirm Booking'));
    await tester.pumpAndSettle();

    expect(find.byType(TicketConfirmScreen), findsNothing);
    expect(find.text('Booking requested!'), findsOneWidget);
    expect(find.textContaining(guide.name), findsWidgets);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(GuideProfileScreen), findsOneWidget);
    expect(find.text('Booking requested!'), findsNothing);
  });
}
