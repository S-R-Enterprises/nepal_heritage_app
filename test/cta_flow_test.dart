import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/app.dart';
import 'package:nepal_np/data/mock_data.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/all_listings_screen.dart';
import 'package:nepal_np/screens/home_screen.dart';
import 'package:nepal_np/screens/hidden_gem_detail_screen.dart';
import 'package:nepal_np/screens/hidden_gems_screen.dart';
import 'package:nepal_np/screens/landing_screen.dart';
import 'package:nepal_np/screens/profile_screen.dart';
import 'package:nepal_np/screens/submit_gem_screen.dart';
import 'package:nepal_np/widgets/buttons.dart';

/// Batch-1 CTA coverage: the buttons that used to render but did nothing.
Future<void> loadRealFonts() async {
  const Map<String, List<String>> families = <String, List<String>>{
    'Lora': <String>['Lora-400normal.ttf', 'Lora-600normal.ttf', 'Lora-700normal.ttf'],
    'DMSans': <String>['DMSans-400normal.ttf', 'DMSans-500normal.ttf', 'DMSans-600normal.ttf'],
  };

  for (final MapEntry<String, List<String>> family in families.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String file in family.value) {
      loader.addFont(
        Future<ByteData>.value(
          ByteData.sublistView(File('assets/fonts/$file').readAsBytesSync()),
        ),
      );
    }
    await loader.load();
  }
}

/// Pumps the real app at phone size and jumps straight to home.
Future<AppRouterScope> pumpHome(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const NepalHeritageApp());
  final AppRouterScope scope = tester
      .element(find.byType(LandingScreen))
      .dependOnInheritedWidgetOfExactType<AppRouterScope>()!;
  scope.notifier!.start();
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);
  return scope;
}

void main() {
  setUpAll(loadRealFonts);

  setUp(MockData.gemSubmissions.clear);

  testWidgets('heritage "See all" opens the full sites list',
      (WidgetTester tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('See all →').first);
    await tester.pumpAndSettle();

    expect(find.byType(AllSitesScreen), findsOneWidget);
    expect(find.text(MockData.heritageSites.first.name), findsOneWidget);
    expect(find.text('${MockData.heritageSites.length} places to explore'),
        findsOneWidget);

    // Back returns home.
    await tester.tap(find.descendant(
      of: find.byType(AllSitesScreen),
      matching: find.byType(AppBackButton),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('guides "See all" opens the full guides list',
      (WidgetTester tester) async {
    await pumpHome(tester);

    // The guides section sits below the fold on a phone-sized viewport. After
    // scrolling it lands near the bottom, under the chat FAB — nudge it clear.
    final Finder guidesCta = find.text('See all →').last;
    await tester.scrollUntilVisible(guidesCta, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(guidesCta);
    await tester.pumpAndSettle();

    expect(find.byType(AllGuidesScreen), findsOneWidget);
    expect(find.text(MockData.guides.first.name), findsOneWidget);
    expect(find.text('${MockData.guides.length} local experts'), findsOneWidget);
  });

  testWidgets('gem submission validates, saves and returns',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.gems);
    await tester.pumpAndSettle();
    expect(find.byType(HiddenGemsScreen), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.byType(SubmitGemScreen), findsOneWidget);

    // Empty name is rejected with guidance, and the form stays put.
    await tester.tap(find.text('Submit for Verification'));
    await tester.pump();
    expect(find.text('Add a place name before submitting.'), findsOneWidget);
    expect(find.byType(SubmitGemScreen), findsOneWidget);

    // A named submission is stored and confirmed.
    final Finder nameField = find.byType(TextField).first;
    await tester.enterText(nameField, 'Rani Pokhari Pocket Park');
    await tester.tap(find.text('Submit for Verification'));
    await tester.pump();
    // The success SnackBar queues behind the error SnackBar's exit animation,
    // then plays its own entrance — pump past both.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(SubmitGemScreen), findsNothing);
    expect(find.byType(HiddenGemsScreen), findsOneWidget);
    expect(MockData.gemSubmissions, hasLength(1));
    expect(MockData.gemSubmissions.single['name'],
        'Rani Pokhari Pocket Park');
    expect(MockData.gemSubmissions.single['category'], 'Viewpoint');
    expect(find.textContaining('submitted for verification'), findsOneWidget);
  });

  testWidgets('"Become a Guide" opens the coming-soon sheet',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.profile);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);

    final Finder cta = find.text('Become a Guide');
    await tester.scrollUntilVisible(cta, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(find.text('COMING SOON'), findsOneWidget);
    expect(find.text('Guided Walks'), findsNothing);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('COMING SOON'), findsNothing);
  });

  testWidgets('"Start Guided Walk" opens the coming-soon sheet',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.gems);
    await tester.pumpAndSettle();

    await tester.tap(find.text(MockData.gems.first.name).first);
    await tester.pumpAndSettle();
    expect(find.byType(HiddenGemDetailScreen), findsOneWidget);

    await tester.tap(find.text('Start Guided Walk'));
    await tester.pumpAndSettle();
    expect(find.text('COMING SOON'), findsOneWidget);
    expect(find.text('Guided Walks'), findsOneWidget);
  });
}


