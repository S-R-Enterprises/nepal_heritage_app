import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/app.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/home_screen.dart';
import 'package:nepal_np/screens/landing_screen.dart';

/// Loads the bundled brand fonts so text measurements match production.
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
