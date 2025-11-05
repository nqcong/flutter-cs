// lib/blocs/contact_list/contact_list_cubit.dart

import 'dart:async';
import 'package:contact/blocs/contactList/ContactListState.dart';
import 'package:contact/coordinator/AppRoutes.dart';
import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';

class ContactListCubit extends Cubit<ContactListState> {
  final ContactRepository _repository;
  final GoRouter _router;

  StreamSubscription? _contactsSubscription;

  final BehaviorSubject<ContactFilter> _filterSubject =
      BehaviorSubject<ContactFilter>.seeded(const ContactFilter());

  ContactListCubit({
    required ContactRepository repository,
    required GoRouter router,
  }) : _repository = repository,
       _router = router,
       super(const ContactListInitial()) {
    _initialize();
  }

  void _initialize() {
    _contactsSubscription = _filterSubject.stream
        .switchMap((filter) => _repository.getFilteredContacts(filter))
        .listen(
          (filteredContacts) {
            emit(
              ContactListLoaded(
                contacts: filteredContacts,
                searchQuery: _filterSubject.value.searchQuery,
              ),
            );
          },
          onError: (error) {
            emit(ContactListError(error.toString()));
          },
        );

    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      emit(const ContactListLoading());
      await _repository.fetchContacts();
    } catch (e) {
      emit(ContactListError(e.toString()));
    }
  }

  // ============================================
  // BUSINESS LOGIC WITH NAVIGATION
  // ============================================

  Future<void> onContactTapped(Contact contact) async {
    try {
      // Business logic: Could fetch fresh data, validate permissions, etc.
      // final freshContact = await _repository.getContactById(contact.id);

      // Decide and execute navigation
      _router.push('${AppRoutes.contactList}/${contact.id}');
    } catch (e) {
      print('Failed to open contact: $e');
    }
  }

  void onAddContactButtonTapped() {
    // Business logic: Could check limits, permissions, etc.
    // if (contacts.length >= MAX_CONTACTS) return;

    // Decide and execute navigation
    _router.push(AppRoutes.addContact);
  }

  // ============================================
  // SEARCH & SORT
  // ============================================

  void searchContacts(String query) {
    final currentFilter = _filterSubject.value;
    if (query.isEmpty) {
      _filterSubject.add(currentFilter.copyWith(clearSearchQuery: true));
    } else {
      _filterSubject.add(currentFilter.copyWith(searchQuery: query));
    }
  }

  void changeSortType(ContactSortType? sortType) {
    final currentFilter = _filterSubject.value;

    if (sortType == null) {
      _filterSubject.add(currentFilter.copyWith(clearSortType: true));
    } else {
      _filterSubject.add(currentFilter.copyWith(sortType: sortType));
    }
  }

  void clearSortFilter() {
    final currentFilter = _filterSubject.value;
    _filterSubject.add(currentFilter.copyWith(clearSortType: true));
  }

  void clearFilters() {
    _filterSubject.add(const ContactFilter());
  }

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  Future<void> addContact(Contact contact) async {
    try {
      await _repository.addContact(contact);
      print('Contact added: ${contact.name}');
    } catch (e) {
      print('Failed to add contact: ${e.toString()}');
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _repository.updateContact(contact);
      print('Contact updated');
    } catch (e) {
      print('Failed to update contact: ${e.toString()}');
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _repository.deleteContact(id);
      print('Contact deleted');
    } catch (e) {
      print('Failed to delete contact: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
    } catch (e) {
      print('Failed to toggle favorite: ${e.toString()}');
    }
  }

  Future<void> refreshContacts() async {
    await loadContacts();
  }

  // Getters
  ContactFilter get currentFilter => _filterSubject.value;
  String get currentSearchQuery => _filterSubject.value.searchQuery ?? '';
  ContactSortType? get currentSortType => _filterSubject.value.sortType;

  Stream<ContactStatistics> get statisticsStream =>
      _repository.statisticsStream;

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    _filterSubject.close();
    _repository.dispose();
    return super.close();
  }
}
