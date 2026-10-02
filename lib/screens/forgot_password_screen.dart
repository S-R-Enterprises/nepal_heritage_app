import 'package:flutter/material.dart';

import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/form_chrome.dart';
import '../widgets/glass.dart';

/// A stub "Forgot Password" screen.
///
/// The spec calls for a password-reset flow stub at `/forgot-password`. The
/// actual email sending is not required, but the screen needs to exist so the
/// link on the login screen is routable.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FormScreenScaffold(
      title: 'Forgot Password',
      // Popping rather than pushing: login is already underneath, so a second
      // copy would leave a dead screen in the back stack.
      onBack: () => AppRouterScope.back(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const AppLogoBadge(size: 56),
            const SizedBox(height: 20),
            const Text(
              'We will send a password reset link to your email address.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                height: 1.6,
                color: AppColors.body,
              ),
            ),
            const SizedBox(height: 20),
            SolidActionButton(
              label: 'Return to Login',
              onPressed: () => AppRouterScope.back(context),
            ),
          ],
        ),
      ),
    );
  }
}
