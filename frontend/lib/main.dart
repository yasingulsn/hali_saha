import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/konum_provider.dart';
import 'providers/bildirim_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HalisahaApp());
}

class HalisahaApp extends StatelessWidget {
  const HalisahaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KonumProvider()),
        ChangeNotifierProvider(create: (_) => BildirimProvider()),
      ],
      child: MaterialApp(
        title: 'Halı Saha',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
