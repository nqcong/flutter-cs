import 'package:contact/model/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> fetchContacts();
  Future<Contact> getContactById(String id);
  Future<Contact> addContact(Contact contact);
  Future<Contact> updateContact(Contact contact);
  Future<void> deleteContact(String id);
  Future<Contact> toggleFavorite(String id);
  Future<List<Contact>> searchContacts(String query);
  Future<void> clearAllContacts();
  Future<int> getContactCount();
}
