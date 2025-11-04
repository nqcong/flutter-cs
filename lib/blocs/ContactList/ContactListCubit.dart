// lib/blocs/contact_list/contact_list_cubit.dart

import 'package:contact/blocs/ContactList/ContactListState.dart';
import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class ContactListCubit extends Cubit<ContactListState> {
  final ContactRepository _repository;
  StreamSubscription? _contactsSubscription;

  // Filter subjects
  final BehaviorSubject<ContactFilter> _filterSubject =
      BehaviorSubject<ContactFilter>.seeded(const ContactFilter());

  ContactListCubit({required ContactRepository repository})
    : _repository = repository,
      super(const ContactListInitial()) {
    _initialize();
  }

  void _initialize() {
    // Listen to filtered contacts stream
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

    // Load initial contacts
    loadContacts();
  }

  // Load contacts
  Future<void> loadContacts() async {
    try {
      emit(const ContactListLoading());
      await _repository.fetchContacts();
      // Contacts will be emitted through stream subscription
    } catch (e) {
      emit(ContactListError(e.toString()));
    }
  }

  // Update filter
  void updateFilter(ContactFilter filter) {
    _filterSubject.add(filter);
  }

  // Search
  void searchContacts(String query) {
    final currentFilter = _filterSubject.value;
    _filterSubject.add(currentFilter.copyWith(searchQuery: query));
  }

  // Toggle favorites filter
  void toggleFavoritesFilter() {
    final currentFilter = _filterSubject.value;
    _filterSubject.add(
      currentFilter.copyWith(
        favoritesOnly: !(currentFilter.favoritesOnly ?? false),
      ),
    );
  }

  // Change sort type
  void changeSortType(ContactSortType sortType) {
    final currentFilter = _filterSubject.value;
    _filterSubject.add(currentFilter.copyWith(sortType: sortType));
  }

  // Filter by color
  void filterByColor(String? color) {
    final currentFilter = _filterSubject.value;
    _filterSubject.add(currentFilter.copyWith(colorFilter: color));
  }

  // Clear all filters
  void clearFilters() {
    _filterSubject.add(const ContactFilter());
  }

  // CRUD operations
  Future<void> addContact(Contact contact) async {
    try {
      await _repository.addContact(contact);
    } catch (e) {
      emit(ContactListError('Failed to add contact: ${e.toString()}'));
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _repository.updateContact(contact);
    } catch (e) {
      emit(ContactListError('Failed to update contact: ${e.toString()}'));
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      await _repository.deleteContact(id);
    } catch (e) {
      emit(ContactListError('Failed to delete contact: ${e.toString()}'));
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _repository.toggleFavorite(id);
    } catch (e) {
      emit(ContactListError('Failed to toggle favorite: ${e.toString()}'));
    }
  }

  Future<void> refreshContacts() async {
    await loadContacts();
  }

  // Getters
  ContactFilter get currentFilter => _filterSubject.value;
  String get currentSearchQuery => _filterSubject.value.searchQuery ?? '';
  bool get showingFavoritesOnly => _filterSubject.value.favoritesOnly ?? false;
  ContactSortType? get currentSortType => _filterSubject.value.sortType;

  // Statistics stream
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
