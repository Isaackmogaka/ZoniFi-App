import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:zonifi_app/main.dart';
import 'package:zonifi_app/state/wallet_state.dart';

void main() {
  testWidgets('ZonifiApp builds and shows the phone entry screen',
      (WidgetTester tester) async {
    // Same wrapping as main.dart itself — ZonifiApp expects a
    // WalletState to be available above it in the widget tree via
    // Provider, so the test needs to set that up too, or it would
    // crash the moment any screen tries to read WalletState.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => WalletState(),
        child: const ZonifiApp(),
      ),
    );

    // A simple smoke test: confirm the app actually builds and the
    // Login screen's heading text appears, proving nothing crashed
    // during startup.
    expect(find.text('Enter your phone number'), findsOneWidget);
  });
}
