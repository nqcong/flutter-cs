import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/contact.dart';
import 'package:contact/repositories/ContactRepository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDataSource _dataSource;

  ContactRepositoryImpl({required ContactDataSource dataSource})
    : _dataSource = dataSource;

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
      final contact = await _dataSource.getContactById(id);
      final updatedContact = contact.copyWith(isFavorite: !contact.isFavorite);
      return await _dataSource.updateContact(updatedContact);
    } catch (e) {
      print('Repository error toggling favorite: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    try {
      return await _dataSource.searchContacts(query);
    } catch (e) {
      print('Repository error searching contacts: $e');
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
      final contacts = await _dataSource.getContacts();
      return contacts.length;
    } catch (e) {
      print('Repository error getting contact count: $e');
      return 0;
    }
  }
}
