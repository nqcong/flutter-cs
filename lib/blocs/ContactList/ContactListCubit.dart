// lib/blocs/contact_list/contact_list_cubit.dart

import 'package:contact/blocs/ContactList/ContactListState.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ContactListCubit extends Cubit<ContactListState> {
  final ContactRepository _repository;
  
  ContactListCubit({required ContactRepository repository})
      : _repository = repository,
        super(const ContactListInitial());

  // Load all contacts
  Future<void> loadContacts() async {
    try {
      emit(const ContactListLoading());
      final contacts = await _repository.fetchContacts();
      emit(ContactListLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactListError(e.toString()));
    }
  }

  // Search contacts
  Future<void> searchContacts(String query) async {
    try {
      // Keep current contacts visible while searching
      if (state is ContactListLoaded) {
        final currentState = state as ContactListLoaded;
        emit(ContactListActionInProgress(
          contacts: currentState.contacts,
          actionId: 'search',
        ));
      }

      final contacts = await _repository.searchContacts(query);
      emit(ContactListLoaded(
        contacts: contacts,
        searchQuery: query,
      ));
    } catch (e) {
      emit(ContactListError(e.toString()));
    }
  }

  // Add contact
  Future<void> addContact(Contact contact) async {
    try {
      if (state is ContactListLoaded) {
        final currentState = state as ContactListLoaded;
        
        // Optimistically add contact to UI
        final updatedContacts = List<Contact>.from(currentState.contacts)
          ..add(contact);
        emit(ContactListLoaded(contacts: updatedContacts));

        // Then sync with repository
        await _repository.addContact(contact);
      }
    } catch (e) {
      // Reload contacts on error
      await loadContacts();
      emit(ContactListError('Failed to add contact: ${e.toString()}'));
    }
  }

  // Update contact
  Future<void> updateContact(Contact contact) async {
    try {
      if (state is ContactListLoaded) {
        final currentState = state as ContactListLoaded;
        
        // Optimistically update in UI
        final updatedContacts = currentState.contacts.map((c) {
          return c.id == contact.id ? contact : c;
        }).toList();
        
        emit(ContactListLoaded(contacts: updatedContacts));

        // Then sync with repository
        await _repository.updateContact(contact);
      }
    } catch (e) {
      await loadContacts();
      emit(ContactListError('Failed to update contact: ${e.toString()}'));
    }
  }

  // Delete contact
  Future<void> deleteContact(String id) async {
    try {
      if (state is ContactListLoaded) {
        final currentState = state as ContactListLoaded;
        
        // Optimistically remove from UI
        final updatedContacts = currentState.contacts
            .where((c) => c.id != id)
            .toList();
        
        emit(ContactListLoaded(contacts: updatedContacts));

        // Then sync with repository
        await _repository.deleteContact(id);
      }
    } catch (e) {
      await loadContacts();
      emit(ContactListError('Failed to delete contact: ${e.toString()}'));
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String id) async {
    try {
      if (state is ContactListLoaded) {
        final currentState = state as ContactListLoaded;
        
        // Optimistically toggle in UI
        final updatedContacts = currentState.contacts.map((c) {
          return c.id == id ? c.copyWith(isFavorite: !c.isFavorite) : c;
        }).toList();
        
        emit(ContactListLoaded(contacts: updatedContacts));

        // Then sync with repository
        await _repository.toggleFavorite(id);
      }
    } catch (e) {
      await loadContacts();
      emit(ContactListError('Failed to toggle favorite: ${e.toString()}'));
    }
  }

  // Refresh contacts
  Future<void> refreshContacts() async {
    await loadContacts();
  }
}