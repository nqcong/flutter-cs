import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:rxdart/rxdart.dart';

/// Abstract repository interface with reactive streams
abstract class ContactRepository {
  Stream<List<Contact>> get contactsStream;
  Stream<ContactStatistics> get statisticsStream;
  Stream<List<Contact>> get favoritesStream;
  Stream<List<Contact>> searchContacts(Stream<String> queryStream);
  Stream<List<Contact>> getFilteredContacts(ContactFilter filter);

  Future<List<Contact>> fetchContacts();
  Future<Contact> getContactById(String id);
  Future<Contact> addContact(Contact contact);
  Future<Contact> updateContact(Contact contact);
  Future<void> deleteContact(String id);
  Future<Contact> toggleFavorite(String id);
  Future<void> clearAllContacts();
  Future<int> getContactCount();

  void dispose();
}
