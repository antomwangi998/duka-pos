// Basic Flutter widget smoke test for Duka POS.
//
// NOTE: The original template test pumped MyApp() directly, but MyApp
// depends on GetIt (BillingBloc, ProductBloc, ShopBloc, PrinterBloc) being
// registered via `di.init()`, plus Hive being initialized — neither of
// which happens outside of main(). It also asserted on counter-app text
// ('0'/'1') left over from `flutter create`, which doesn't exist in this
// app at all. That's why `flutter test` was failing in CI and blocking
// the APK build step.
//
// This replaces it with a dependency-free smoke test so CI is unblocked.
// TODO: add real bloc/widget tests once GetIt + Hive are mockable in a
// test harness (e.g. via bloc_test / mockito, or a setUp() that calls
// di.init() against an in-memory Hive box and fakes the camera/vibration
// platform channels used by HomePage).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dukaepos/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme renders a MaterialApp without dependency injection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Text('Duka POS')),
      ),
    );

    expect(find.text('Duka POS'), findsOneWidget);
  });

  test('AppTheme.lightTheme builds a valid ThemeData', () {
    final theme = AppTheme.lightTheme;
    expect(theme, isA<ThemeData>());
    expect(theme.primaryColor, AppTheme.primaryColor);
  });
}
