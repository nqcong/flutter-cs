// lib/coordinator/tab_item.dart
import 'package:flutter/material.dart';

enum TabItem { createProfile, contactList, myProfile }

extension TabItemExtension on TabItem {
  String get title {
    switch (this) {
      case TabItem.createProfile:
        return 'Create Profile';
      case TabItem.contactList:
        return 'Contacts';
      case TabItem.myProfile:
        return 'My Profile';
    }
  }

  IconData get icon {
    switch (this) {
      case TabItem.createProfile:
        return Icons.person_add;
      case TabItem.contactList:
        return Icons.contacts;
      case TabItem.myProfile:
        return Icons.person;
    }
  }

  IconData get activeIcon {
    switch (this) {
      case TabItem.createProfile:
        return Icons.person_add;
      case TabItem.contactList:
        return Icons.contacts;
      case TabItem.myProfile:
        return Icons.person;
    }
  }

  Color get color {
    switch (this) {
      case TabItem.createProfile:
        return Colors.blue.shade400;
      case TabItem.contactList:
        return Colors.green.shade400;
      case TabItem.myProfile:
        return Colors.purple.shade400;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TabItem.createProfile:
        return Colors.blue.shade50;
      case TabItem.contactList:
        return Colors.green.shade50;
      case TabItem.myProfile:
        return Colors.purple.shade50;
    }
  }
}
