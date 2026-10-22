import 'package:etecsa_supervision/presentation/screen/screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: PlaceholderScreen.name,
      builder: (context, state) => const PlaceholderScreen(),
    ),
  ],
);
