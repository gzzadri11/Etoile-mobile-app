import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

/// Main scaffold with bottom navigation
///
/// Used as the shell for the main app screens:
/// - Feed
/// - Messages
/// - Profile
/// - Record (for seekers)
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isSeeker = state is AuthAuthenticated && state.isSeeker;

        return Scaffold(
          body: child,
          bottomNavigationBar: _EtoileBottomNavBar(
            showRecordTab: isSeeker,
          ),
        );
      },
    );
  }
}

class _EtoileBottomNavBar extends StatelessWidget {
  final bool showRecordTab;

  const _EtoileBottomNavBar({
    required this.showRecordTab,
  });

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith(AppRoutes.feed)) return 0;
    if (location.startsWith(AppRoutes.messages)) return 1;
    if (location.startsWith(AppRoutes.profile)) return 2;
    if (location.startsWith(AppRoutes.record)) return 3;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.feed);
        break;
      case 1:
        context.go(AppRoutes.messages);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
      case 3:
        context.go(AppRoutes.record);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Feed',
      ),
      const BottomNavigationBarItem(
        icon: _MessageIcon(hasUnread: false),
        activeIcon: _MessageIcon(hasUnread: false, isActive: true),
        label: 'Messages',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      if (showRecordTab)
        const BottomNavigationBarItem(
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
            color: Colors.black.withOpacity(0.05),
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
