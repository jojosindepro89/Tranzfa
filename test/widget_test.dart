import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tranzfa_bank/main.dart';
import 'package:tranzfa_bank/services/banking_service.dart';

void main() {
  testWidgets('TranzfaApp renders onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BankingService(),
        child: const TranzfaApp(),
      ),
    );

    // Verify Tranzfa brand text is displayed
    expect(find.text('Tranzfa'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
