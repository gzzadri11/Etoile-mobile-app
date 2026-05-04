library;

/// Scaffold principal de l'interface administrateur.
///
/// Fournit une barre de navigation basse avec 4 onglets :
/// Tableau de bord, Verifications, Signalements, Statistiques.
/// Meme pattern que MainScaffold mais pour l'experience admin.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

/// Scaffold admin avec barre de navigation inferieure a 4 onglets.
class AdminScaffold extends StatelessWidget {
  final Widget child;

  const AdminScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _AdminBottomNavBar(),
    );
  }
}

class _AdminBottomNavBar extends StatelessWidget {
  const _AdminBottomNavBar();

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location == AppRoutes.admin) return 0;
    if (location.startsWith(AppRoutes.adminVerifications)) return 1;
    if (location.startsWith(AppRoutes.adminReports)) return 2;
    if (location.startsWith(AppRoutes.adminStats)) return 3;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.admin);
      case 1:
        context.go(AppRoutes.adminVerifications);
      case 2:
        context.go(AppRoutes.adminReports);
      case 3:
        context.go(AppRoutes.adminStats);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    const items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Tableau de bord',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.verified_user_outlined),
        activeIcon: Icon(Icons.verified_user),
        label: 'Verifications',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.flag_outlined),
        activeIcon: Icon(Icons.flag),
        label: 'Signalements',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart_outlined),
        activeIcon: Icon(Icons.bar_chart),
        label: 'Statistiques',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => _onItemTapped(context, index),
            items: items,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
