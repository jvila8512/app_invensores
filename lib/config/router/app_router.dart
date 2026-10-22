import 'package:go_router/go_router.dart';

import 'package:etecsa_supervision/presentation/screen/movis/home_screen.dart';



final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),



  ]
);