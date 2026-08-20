import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/banking_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BankingService()),
      ],
      child: const TranzfaApp(),
    ),
  );
}

class TranzfaApp extends StatelessWidget {
  const TranzfaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tranzfa - Speed Money Transfer & Neobank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<BankingService>(context).themeMode,
      home: Consumer<BankingService>(
        builder: (context, bankService, child) {
          if (bankService.isLoggedIn) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
