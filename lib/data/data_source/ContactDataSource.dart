import 'package:contact/model/contact.dart';

abstract class ContactDataSource {
  Future<List<Contact>> getContacts();
  Future<Contact> getContactById(String id);
  Future<Contact> addContact(Contact contact);
  Future<Contact> updateContact(Contact contact);
  Future<void> deleteContact(String id);
  Future<List<Contact>> searchContacts(String query);
  Future<void> clearAllContacts();
}
