// lib/coordinator/helpers/navigation_helper.dart

import 'package:contact/blocs/ContactList/ContactListCubit.dart';
import 'package:contact/coordinator/TabItem.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/screens/ContactList/ContactListScreen.dart';
import 'package:contact/screens/CreateProfile/CreateProfileScreen.dart';
import 'package:contact/screens/MyProfile/MyProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationHelper {
  final ContactRepository contactRepository;

  NavigationHelper({required this.contactRepository});

  // ... rest remains the same ...

  Map<TabItem, WidgetBuilder> getRouteBuilders({
    required Function(Map<String, String>) onProfileCreated,
    required Function(Contact) onNavigateToContactDetail,
    required VoidCallback onNavigateToAddContact,
    required VoidCallback onNavigateToEditProfile,
    required VoidCallback onNavigateToSettings,
  }) {
    return {
      TabItem.createProfile: (context) =>
          CreateProfileScreen(onProfileCreated: onProfileCreated),
      TabItem.contactList: (context) => BlocProvider(
        create: (context) => ContactListCubit(repository: contactRepository),
        child: ContactListScreen(
          onNavigateToContactDetail: onNavigateToContactDetail,
          onNavigateToAddContact: onNavigateToAddContact,
        ),
      ),
      TabItem.myProfile: (context) => MyProfileScreen(
        onNavigateToEditProfile: onNavigateToEditProfile,
        onNavigateToSettings: onNavigateToSettings,
      ),
    };
  }

  static Future<bool> handleBackPress({
    required TabItem currentTab,
    required Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys,
    required Function(TabItem) selectTab,
  }) async {
    final isFirstRouteInCurrentTab = !await navigatorKeys[currentTab]!
        .currentState!
        .maybePop();

    if (isFirstRouteInCurrentTab) {
      if (currentTab != TabItem.contactList) {
        selectTab(TabItem.contactList);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  static Widget buildOffstageNavigator({
    required TabItem tabItem,
    required TabItem currentTab,
    required GlobalKey<NavigatorState> navigatorKey,
    required WidgetBuilder builder,
  }) {
    return Offstage(
      offstage: currentTab != tabItem,
      child: Navigator(
        key: navigatorKey,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(builder: builder);
        },
      ),
    );
  }
}
