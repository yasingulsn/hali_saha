import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/bildirim_provider.dart';
import 'providers/konum_provider.dart';
import 'providers/tema_provider.dart';
import 'screens/splash_screen.dart';
import 'services/fcm_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // google-services.json eklenmemişse sessizce geç
  }
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
        ChangeNotifierProvider(create: (_) => TemaProvider()),
      ],
      child: Consumer<TemaProvider>(
        builder: (_, tema, __) => MaterialApp(
          title: 'Halı Saha',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: tema.themeMode,
          home: const _AppEntryPoint(),
        ),
      ),
    );
  }
}

class _AppEntryPoint extends StatefulWidget {
  const _AppEntryPoint();

  @override
  State<_AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<_AppEntryPoint> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmService().init(context);
    });
  }

  @override
  Widget build(BuildContext context) => const SplashScreen();
}
