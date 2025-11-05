// lib/blocs/createProfile/CreateProfileCubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/coordinator/AppRoutes.dart';

class CreateProfileCubit extends Cubit<CreateProfileState> {
  final ContactRepository _repository;
  final GoRouter _router;

  CreateProfileCubit({
    required ContactRepository repository,
    required GoRouter router,
  }) : _repository = repository,
       _router = router,
       super(CreateProfileInitial());

  Future<void> createProfile({
    required String name,
    required String email,
    String? phone,
    required String color,
  }) async {
    try {
      emit(CreateProfileLoading());

      // Business logic: Validation
      if (name.isEmpty || email.isEmpty) {
        throw Exception('Name and email are required');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      // Create contact
      final newContact = Contact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        phone: phone,
        avatarUrl: '',
        avatarColor: color,
      );

      // Save to repository
      await _repository.addContact(newContact);

      emit(CreateProfileSuccess());

      print('Profile created: $name');

      // Navigate using router
      _router.go(AppRoutes.contactList);
    } catch (e) {
      emit(CreateProfileError(e.toString()));
      print('Failed to create profile: $e');
    }
  }
}

// States
abstract class CreateProfileState {}

class CreateProfileInitial extends CreateProfileState {}

class CreateProfileLoading extends CreateProfileState {}

class CreateProfileSuccess extends CreateProfileState {}

class CreateProfileError extends CreateProfileState {
  final String message;
  CreateProfileError(this.message);
}
