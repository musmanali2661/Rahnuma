import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'screens/map_screen.dart';
import 'screens/offline_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/offline',
      builder: (context, state) => const OfflineScreen(),
    ),
  ],
);

class RahnumaApp extends ConsumerWidget {
  const RahnumaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rahnuma',
      theme: rahnumaTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
