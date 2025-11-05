// lib/blocs/contactDetails/ContactDetailCubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/coordinator/AppRoutes.dart';

class ContactDetailCubit extends Cubit<ContactDetailState> {
  final ContactRepository _repository;
  final GoRouter _router;
  final String contactId;

  ContactDetailCubit({
    required ContactRepository repository,
    required GoRouter router,
    required this.contactId,
  }) : _repository = repository,
       _router = router,
       super(ContactDetailInitial()) {
    loadContact();
  }

  Future<void> loadContact() async {
    try {
      emit(ContactDetailLoading());

      // Business logic: Fetch contact data
      final contact = await _repository.getContactById(contactId);

      emit(ContactDetailLoaded(contact));
    } catch (e) {
      emit(ContactDetailError(e.toString()));
      print('Failed to load contact: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final currentState = state;
    if (currentState is! ContactDetailLoaded) return;

    try {
      // Optimistic update
      final updatedContact = currentState.contact.copyWith(
        isFavorite: !currentState.contact.isFavorite,
      );
      emit(ContactDetailLoaded(updatedContact));

      // Save to repository
      await _repository.toggleFavorite(contactId);
    } catch (e) {
      // Revert on error
      emit(currentState);
      print('Failed to toggle favorite: $e');
    }
  }

  Future<void> deleteContact() async {
    try {
      // Business logic: Delete contact
      await _repository.deleteContact(contactId);

      print('Contact deleted');

      // Navigate back using router
      _router.pop();
    } catch (e) {
      print('Failed to delete contact: $e');
    }
  }

  void editContact() {
    final currentState = state;
    if (currentState is ContactDetailLoaded) {
      // Business logic: Check permissions, etc.

      // Navigate using router
      _router.push('${AppRoutes.contactList}/$contactId/edit');
    }
  }
}

// States
abstract class ContactDetailState {}

class ContactDetailInitial extends ContactDetailState {}

class ContactDetailLoading extends ContactDetailState {}

class ContactDetailLoaded extends ContactDetailState {
  final Contact contact;
  ContactDetailLoaded(this.contact);
}

class ContactDetailError extends ContactDetailState {
  final String message;
  ContactDetailError(this.message);
}
