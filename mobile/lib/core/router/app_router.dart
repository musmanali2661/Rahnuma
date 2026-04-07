import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/map_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/navigation_screen.dart';
import '../../presentation/screens/offline_screen.dart';
import '../../data/models/route_model.dart';

/// Named route constants.
class AppRoutes {
  AppRoutes._();

  static const String map = '/';
  static const String search = '/search';
  static const String navigation = '/navigation';
  static const String offline = '/offline';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.map,
  routes: [
    GoRoute(
      path: AppRoutes.map,
      name: 'map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.navigation,
      name: 'navigation',
      builder: (context, state) {
        final route = state.extra as RouteModel?;
        return NavigationScreen(route: route);
      },
    ),
    GoRoute(
      path: AppRoutes.offline,
      name: 'offline',
      builder: (context, state) => const OfflineScreen(),
    ),
  ],
);
