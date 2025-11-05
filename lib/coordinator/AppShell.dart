// lib/coordinator/app_shell.dart

import 'package:contact/coordinator/AppRoutes.dart';
import 'package:contact/coordinator/TabItem.dart';
import 'package:contact/widget/AnimatedTabButton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShell({Key? key, required this.child, required this.currentPath})
    : super(key: key);

  static const double _tabBarHeight = 90.0;
  static const double _backgroundHeight = 45.0;

  TabItem _getCurrentTab() {
    if (currentPath.startsWith(AppRoutes.createProfile)) {
      return TabItem.createProfile;
    } else if (currentPath.startsWith(AppRoutes.contactList)) {
      return TabItem.contactList;
    } else if (currentPath.startsWith(AppRoutes.myProfile)) {
      return TabItem.myProfile;
    }
    return TabItem.contactList; // Default
  }

  void _onTabTap(BuildContext context, TabItem tabItem) {
    switch (tabItem) {
      case TabItem.createProfile:
        context.go(AppRoutes.createProfile);
        break;
      case TabItem.contactList:
        context.go(AppRoutes.contactList);
        break;
      case TabItem.myProfile:
        context.go(AppRoutes.myProfile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = _getCurrentTab();

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        height: _tabBarHeight,
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Stack(
          children: [
            // Bottom background
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: _backgroundHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
              ),
            ),

            // Tab buttons
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: TabItem.values.map((tabItem) {
                    return AnimatedTabButton(
                      tabItem: tabItem,
                      isActive: currentTab == tabItem,
                      onTap: () => _onTabTap(context, tabItem),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
