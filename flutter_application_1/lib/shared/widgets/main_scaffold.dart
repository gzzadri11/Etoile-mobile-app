library;

/// Scaffold principal avec barre de navigation basse (chercheur).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

/// Main scaffold with bottom navigation (seeker-only).
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _EtoileBottomNavBar(),
    );
  }
}

class _EtoileBottomNavBar extends StatelessWidget {
  const _EtoileBottomNavBar();

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppRoutes.search)) return 0;
    if (location.startsWith(AppRoutes.feed)) return 1;
    if (location.startsWith(AppRoutes.messages)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    if (location.startsWith(AppRoutes.record)) return 4;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.search);
      case 1:
        context.go(AppRoutes.feed);
      case 2:
        context.go(AppRoutes.messages);
      case 3:
        context.go(AppRoutes.profile);
      case 4:
        context.go(AppRoutes.record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    const items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Rechercher',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Feed',
      ),
      BottomNavigationBarItem(
        icon: _MessageIcon(hasUnread: false),
        activeIcon: _MessageIcon(hasUnread: false, isActive: true),
        label: 'Messages',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.videocam_outlined),
        activeIcon: Icon(Icons.videocam),
        label: 'Enregistrer',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
            currentIndex: currentIndex.clamp(0, items.length - 1),
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

/// Message icon with optional unread badge
class _MessageIcon extends StatelessWidget {
  final bool hasUnread;
  final bool isActive;

  const _MessageIcon({
    required this.hasUnread,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          isActive ? Icons.chat_bubble : Icons.chat_bubble_outline,
        ),
        if (hasUnread)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
