import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'state/wallet_state.dart';
import 'services/mpesa_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Reads the .env file (declared as an asset in pubspec.yaml) into
  // memory. After this line, ANY file in the app can read values from
  // it via dotenv.env['SOME_KEY'] — this is what keeps
  // MPESA_CONSUMER_KEY and MPESA_CONSUMER_SECRET out of our actual
  // source code, and therefore out of git.
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    providerAndroid: AndroidDebugProvider(),
  );

  final walletState = WalletState();

  // TEMPORARY test call — proves the whole chain works (.env loaded
  // -> credentials read -> real Safaricom API request -> real token
  // returned) before we build the actual STK Push on top of it.
  // Remove this once confirmed working.
  try {
    final token = await MpesaService().getAccessToken();
    debugPrint('M-PESA ACCESS TOKEN: $token');
  } catch (e) {
    debugPrint('M-PESA TOKEN ERROR: $e');
  }

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