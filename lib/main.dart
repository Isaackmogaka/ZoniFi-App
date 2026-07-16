import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'state/wallet_state.dart';
import 'firebase_options.dart';

/// main() is now `async` (notice the added keyword), and the body uses
/// `await` before runApp(). This matters because connecting to
/// Firebase is a real network operation — it takes a small but
/// non-zero amount of time. Without `await`, Flutter would try to
/// start showing screens before Firebase finished connecting, and
/// anything trying to use Firebase early could crash or behave
/// unpredictably.
Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized() is required whenever you
  // do ANY async work in main() before runApp() — it makes sure
  // Flutter's own internal engine is ready to handle platform calls
  // (like the ones Firebase needs) before we start using them.
  WidgetsFlutterBinding.ensureInitialized();

  // This actually connects to Firebase, using the exact project
  // details generated earlier in firebase_options.dart.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => WalletState(),
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