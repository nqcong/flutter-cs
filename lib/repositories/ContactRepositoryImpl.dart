import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';

// lib/data/repositories/contact_repository_impl.dart

import 'package:rxdart/rxdart.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDataSource _dataSource;

  ContactRepositoryImpl({required ContactDataSource dataSource})
    : _dataSource = dataSource;

  // ============================================
  // STREAMS - Delegate to data source
  // ============================================

  @override
  Stream<List<Contact>> get contactsStream => _dataSource.contactsStream;

  @override
  Stream<ContactStatistics> get statisticsStream =>
      _dataSource.statisticsStream;

  @override
  Stream<List<Contact>> get favoritesStream => _dataSource.favoritesStream;

  @override
  Stream<List<Contact>> searchContacts(Stream<String> queryStream) {
    return _dataSource.searchContacts(queryStream);
  }

  @override
  Stream<List<Contact>> getFilteredContacts(ContactFilter filter) {
    return _dataSource.getFilteredContacts(filter);
  }

  // ============================================
  // CRUD OPERATIONS - Delegate to data source
  // ============================================

  @override
  Future<List<Contact>> fetchContacts() async {
    try {
      return await _dataSource.getContacts();
    } catch (e) {
      print('Repository error fetching contacts: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> getContactById(String id) async {
    try {
      return await _dataSource.getContactById(id);
    } catch (e) {
      print('Repository error getting contact by id: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    try {
      // Generate ID if not provided
      final contactToAdd = contact.id.isEmpty
          ? contact.copyWith(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
            )
          : contact;

      return await _dataSource.addContact(contactToAdd);
    } catch (e) {
      print('Repository error adding contact: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    try {
      return await _dataSource.updateContact(contact);
    } catch (e) {
      print('Repository error updating contact: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      await _dataSource.deleteContact(id);
    } catch (e) {
      print('Repository error deleting contact: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> toggleFavorite(String id) async {
    try {
      return await _dataSource.toggleFavorite(id);
    } catch (e) {
      print('Repository error toggling favorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllContacts() async {
    try {
      await _dataSource.clearAllContacts();
    } catch (e) {
      print('Repository error clearing contacts: $e');
      rethrow;
    }
  }

  @override
  Future<int> getContactCount() async {
    try {
      return await _dataSource.getContactCount();
    } catch (e) {
      print('Repository error getting contact count: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    _dataSource.dispose();
  }
}
