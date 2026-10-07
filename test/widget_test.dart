import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_minds/main.dart';
import 'package:market_minds/core/constants/app_constants.dart';

void main() {
  testWidgets('MarketMindsApp initial splash smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MarketMindsApp(),
      ),
    );

    // Verify app name appears on the splash screen
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Advance virtual clock past the splash animation & navigation timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
