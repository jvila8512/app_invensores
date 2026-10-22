import 'package:etecsa_supervision/config/router/app_router.dart';
import 'package:etecsa_supervision/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables de entorno (.env). Si el archivo no existe la app sigue booting:
  // Environment usa valores por defecto.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Sin .env se usan los valores por defecto de Environment.
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
