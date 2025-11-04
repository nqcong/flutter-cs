// lib/coordinator/app_coordinator.dart

import 'package:contact/coordinator/TabItem.dart';
import 'package:contact/data/data_source/ContactLocalDataSource.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/repositories/ContactRepositoryFactory.dart';
import 'package:contact/share/helper/DialogHelper.dart';
import 'package:contact/share/helper/NavigationHelper.dart';
import 'package:contact/widget/AnimatedTabButton.dart';
import 'package:flutter/material.dart';

class AppCoordinator extends StatefulWidget {
  const AppCoordinator({Key? key}) : super(key: key);

  @override
  State<AppCoordinator> createState() => _AppCoordinatorState();
}

class _AppCoordinatorState extends State<AppCoordinator> {
  TabItem _currentTab = TabItem.contactList;

  static const double _tabBarHeight = 90.0;
  static const double _backgroundHeight = 45.0;

  // Dependencies
  late final ContactRepository _contactRepository;
  late final NavigationHelper _navigationHelper;

  final Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.createProfile: GlobalKey<NavigatorState>(),
    TabItem.contactList: GlobalKey<NavigatorState>(),
    TabItem.myProfile: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();

    // Create repository using factory - defaults to local storage
    _contactRepository = ContactRepositoryFactory.createLocal();

    _navigationHelper = NavigationHelper(contactRepository: _contactRepository);

    // Initialize with sample data
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('Starting data initialization...');

      // Initialize sample data directly from data source
      final dataSource = ContactLocalDataSource();
      await dataSource.initializeWithSampleData();

      print('Data initialization complete');
    } catch (e) {
      print('Error during initialization: $e');
      if (mounted) {
        DialogHelper.showErrorMessage(
          context: context,
          message: 'Failed to initialize data: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _contactRepository.dispose();
    super.dispose();
  }

  // ============================================
  // TAB SELECTION LOGIC
  // ============================================

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      _navigatorKeys[tabItem]!.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  // ============================================
  // NAVIGATION CALLBACKS
  // ============================================

  void _onProfileCreated(Map<String, String> profileData) {
    // Create a new contact from the profile data
    final newContact = Contact(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: profileData['name']!,
      email: profileData['email']!,
      phone: profileData['phone'],
      avatarUrl: '',
      avatarColor: profileData['color'] ?? 'blue',
    );

    // Add to repository (will automatically update streams)
    _contactRepository.addContact(newContact);

    DialogHelper.showSuccessMessage(
      context: context,
      message: 'Profile created: ${profileData['name']}',
    );
    _selectTab(TabItem.contactList);
  }

  void _navigateToContactDetail(Contact contact) {
    DialogHelper.showContactDetail(
      context: context,
      contact: contact,
      onEdit: () {
        DialogHelper.showInfoMessage(
          context: context,
          message: 'Edit feature coming soon',
        );
      },
    );
  }

  void _navigateToAddContact() {
    DialogHelper.showAddContactModal(
      context: context,
      onSave: (data) {
        final newContact = Contact(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: data['name']!,
          email: data['email']!,
          phone: data['phone'],
          avatarUrl: '',
          avatarColor: 'blue',
        );

        // Add to repository (will automatically update streams)
        _contactRepository.addContact(newContact);

        DialogHelper.showSuccessMessage(
          context: context,
          message: 'Contact added: ${data['name']}',
        );
      },
    );
  }

  void _navigateToEditProfile() {
    _selectTab(TabItem.createProfile);
  }

  void _navigateToSettings() {
    DialogHelper.showInfoMessage(
      context: context,
      message: 'Settings feature coming soon',
    );
  }

  // ============================================
  // BUILD METHODS
  // ============================================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => NavigationHelper.handleBackPress(
        currentTab: _currentTab,
        navigatorKeys: _navigatorKeys,
        selectTab: _selectTab,
      ),
      child: Scaffold(
        extendBody: true,
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    final routeBuilders = _navigationHelper.getRouteBuilders(
      onProfileCreated: _onProfileCreated,
      onNavigateToContactDetail: _navigateToContactDetail,
      onNavigateToAddContact: _navigateToAddContact,
      onNavigateToEditProfile: _navigateToEditProfile,
      onNavigateToSettings: _navigateToSettings,
    );

    return Stack(
      children: TabItem.values.map((tabItem) {
        return NavigationHelper.buildOffstageNavigator(
          tabItem: tabItem,
          currentTab: _currentTab,
          navigatorKey: _navigatorKeys[tabItem]!,
          builder: routeBuilders[tabItem]!,
        );
      }).toList(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: _tabBarHeight,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(children: [_buildBottomBackground(), _buildTabButtons()]),
    );
  }

  Widget _buildBottomBackground() {
    return Positioned(
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
    );
  }

  Widget _buildTabButtons() {
    return Positioned.fill(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: TabItem.values.map((tabItem) {
            return AnimatedTabButton(
              tabItem: tabItem,
              isActive: _currentTab == tabItem,
              onTap: () => _selectTab(tabItem),
            );
          }).toList(),
        ),
      ),
    );
  }
}
