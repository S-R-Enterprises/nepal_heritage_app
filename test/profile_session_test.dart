import 'package:flutter_test/flutter_test.dart';

import 'package:nepal_np/data/auth_service.dart';
import 'package:nepal_np/data/mock_data.dart';
import 'package:nepal_np/navigation/app_router.dart';
import 'package:nepal_np/screens/profile_screen.dart';

import 'test_helpers.dart';

/// Profile identity: the signed-in account when a session exists, the
/// prototype visitor identity otherwise.
void main() {
  setUpAll(loadRealFonts);

  tearDown(AuthService.instance.signOut);

  testWidgets('falls back to the prototype identity without a session',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);
    scope.notifier!.switchTab(AppTab.profile);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text(MockData.userName), findsOneWidget);
    expect(find.text(MockData.userMeta), findsOneWidget);
  });

  testWidgets('shows the signed-in account once a session exists',
      (WidgetTester tester) async {
    final AppRouterScope scope = await pumpHome(tester);

    // The mock round-trip uses a fake timer; pump the clock past its latency.
    final Future<AuthUser> login = AuthService.instance.login(
      identifier: AuthService.demoEmail,
      password: AuthService.demoPassword,
      rememberMe: false,
    );
    await tester.pump(AuthService.latency);
    final AuthUser user = await login;
    expect(user.fullName, 'Demo Visitor');

    scope.notifier!.switchTab(AppTab.profile);
    await tester.pumpAndSettle();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Demo Visitor'), findsOneWidget);
    expect(find.text(AuthService.demoEmail), findsOneWidget);
    expect(find.text(MockData.userName), findsNothing);
  });
}
