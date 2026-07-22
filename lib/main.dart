import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'state/wallet_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // App Check proves to Firebase that requests are genuinely coming
  // from OUR app, not some other unauthorized source. On a real,
  // Play Store-published app, androidProvider: AndroidProvider.playIntegrity
  // would work automatically. Since we're still in development on a
  // debug build (not yet published), we use AndroidProvider.debug
  // instead — this prints a unique debug token to the terminal logs
  // the first time it runs, which we then register in the Firebase
  // Console to mark this specific development device as trusted.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
  );

  final walletState = WalletState();

  runApp(
    ChangeNotifierProvider.value(
      value: walletState,
      child: const ZonifiApp(),
    ),
  );
}

class ZonifiApp extends StatelessWidget {
  const ZonifiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zonifi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}