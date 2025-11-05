// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contact/coordinator/AppRoutes.dart';
import 'package:contact/repositories/ContactRepositoryFactory.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/data/data_source/ContactLocalDataSource.dart';
import 'package:contact/blocs/contactList/ContactListCubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeData();
  runApp(const MyApp());
}

Future<void> _initializeData() async {
  try {
    print('Starting data initialization...');
    final dataSource = ContactLocalDataSource();
    await dataSource.initializeWithSampleData();
    print('Data initialization complete');
  } catch (e) {
    print('Error during initialization: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ContactRepository _contactRepository;
  late final _route;
  @override
  void initState() {
    super.initState();
    _contactRepository = ContactRepositoryFactory.createLocal();
    _route = AppRoutes.createRouter(contactRepository: _contactRepository);
  }

  @override
  void dispose() {
    _contactRepository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ContactListCubit(repository: _contactRepository, router: _route)
            ..loadContacts(),
      child: MaterialApp.router(
        title: 'Contact App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        routerConfig: _route,
      ),
    );
  }
}
