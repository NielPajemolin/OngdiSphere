import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/loading.dart';

void main() {
  testWidgets('LoadingScreen shows default loading message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const LoadingScreen()),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('LoadingScreen shows custom message in dialog mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: LoadingScreen(
            message: 'Creating account...',
            isFullScreen: false,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Creating account...'), findsOneWidget);
  });
}
