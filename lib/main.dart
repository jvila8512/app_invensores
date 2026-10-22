
import 'package:etecsa_supervision/config/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:etecsa_supervision/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  // Asegúrate de que el binding de Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
   await dotenv.load(fileName: ".env");
  
  // Ejecutar la app
  runApp(

     const ProviderScope( child: MainApp())

  );
}
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(), // Asegúrate de que AppTheme tenga un método 
    );
  }
}
