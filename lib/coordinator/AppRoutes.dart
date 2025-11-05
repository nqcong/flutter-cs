// lib/coordinator/app_routes.dart

import 'package:contact/blocs/ContactList/ContactListCubit.dart';
import 'package:contact/blocs/contactDetails/ContactDetailCubit.dart';
import 'package:contact/blocs/createProfile/CreateProfileCubit.dart';
import 'package:contact/coordinator/AppShell.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/screens/AddContact/AddContactScreen.dart';
import 'package:contact/screens/ContactDetail/ContactDetailScreen.dart';
import 'package:contact/screens/ContactList/ContactListScreen.dart';
import 'package:contact/screens/CreateProfile/CreateProfileScreen.dart';
import 'package:contact/screens/MyProfile/MyProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoutes {
  static const String createProfile = '/create-profile';
  static const String contactList = '/contacts';
  static const String myProfile = '/my-profile';
  static const String contactDetail = '/contacts/:id';
  static const String addContact = '/contacts/add';
  static const String editContact = '/contacts/:id/edit';
  static const String settings = '/settings';

  static GoRouter createRouter({required ContactRepository contactRepository}) {
    late final GoRouter router;

    router = GoRouter(
      initialLocation: contactList,
      debugLogDiagnostics: true,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AppShell(child: child, currentPath: state.uri.path);
          },
          routes: [
            // Create Profile Tab
            GoRoute(
              path: createProfile,
              name: 'create-profile',
              pageBuilder: (context, state) => NoTransitionPage(
                child: BlocProvider(
                  create: (context) => CreateProfileCubit(
                    repository: contactRepository,
                    router: router,
                  ),
                  child: const CreateProfileScreen(),
                ),
              ),
            ),

            // Contact List Tab
            GoRoute(
              path: contactList,
              name: 'contacts',
              pageBuilder: (context, state) => NoTransitionPage(
                child: BlocProvider(
                  create: (context) => ContactListCubit(
                    repository: contactRepository,
                    router: router,
                  ),
                  child: const ContactListScreen(),
                ),
              ),
              routes: [
                // Contact Detail
                GoRoute(
                  path: ':id',
                  name: 'contact-detail',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return BlocProvider(
                      create: (context) => ContactDetailCubit(
                        repository: contactRepository,
                        router: router,
                        contactId: id,
                      ),
                      child: const ContactDetailScreen(),
                    );
                  },
                ),

                // Add Contact
                GoRoute(
                  path: 'add',
                  name: 'add-contact',
                  builder: (context, state) {
                    return AddContactScreen(
                      repository: contactRepository,
                      router: router,
                    );
                  },
                ),
              ],
            ),

            // My Profile Tab
            GoRoute(
              path: myProfile,
              name: 'my-profile',
              pageBuilder: (context, state) =>
                  NoTransitionPage(child: MyProfileScreen(router: router)),
            ),
          ],
        ),

        // Settings (outside shell)
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(title: Text('Settings')),
              body: Center(child: Text('Settings Screen')),
            );
          },
        ),
      ],

      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Page not found: ${state.uri.path}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => router.go(contactList),
                  child: const Text('Go to Contacts'),
                ),
              ],
            ),
          ),
        );
      },
    );

    return router;
  }
}
