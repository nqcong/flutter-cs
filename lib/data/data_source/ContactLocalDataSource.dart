import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/data/storage/JSONStorageService.dart';
import 'package:contact/model/contact.dart';

class ContactLocalDataSource implements ContactDataSource {
  final JsonStorageService _storageService;

  ContactLocalDataSource({JsonStorageService? storageService})
    : _storageService = storageService ?? JsonStorageService();

  // Helper method to read contacts from JSON
  Future<List<Contact>> _readContactsFromJson() async {
    try {
      final data = await _storageService.readJson();
      final contactsList = data['contacts'] as List<dynamic>? ?? [];

      print('Read ${contactsList.length} contacts from JSON');

      return contactsList
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error in _readContactsFromJson: $e');
      return [];
    }
  }

  // Helper method to write contacts to JSON
  Future<void> _writeContactsToJson(List<Contact> contacts) async {
    try {
      // Convert contacts to JSON maps
      final contactJsonList = contacts.map((c) => c.toJson()).toList();

      print('Converting ${contacts.length} contacts to JSON');

      // Create the data structure
      final data = <String, dynamic>{'contacts': contactJsonList};

      // Write to file
      await _storageService.writeJson(data);

      print('Successfully wrote ${contacts.length} contacts to JSON');
    } catch (e) {
      print('Error in _writeContactsToJson: $e');
      rethrow;
    }
  }

  @override
  Future<List<Contact>> getContacts() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      return await _readContactsFromJson();
    } catch (e) {
      print('Error getting contacts: $e');
      throw Exception('Failed to load contacts');
    }
  }

  @override
  Future<Contact> getContactById(String id) async {
    try {
      final contacts = await _readContactsFromJson();

      return contacts.firstWhere(
        (contact) => contact.id == id,
        orElse: () => throw Exception('Contact not found'),
      );
    } catch (e) {
      print('Error getting contact by id: $e');
      throw Exception('Contact not found');
    }
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    try {
      final contacts = await _readContactsFromJson();

      // Check if contact with same id already exists
      if (contacts.any((c) => c.id == contact.id)) {
        throw Exception('Contact with this ID already exists');
      }

      contacts.add(contact);
      await _writeContactsToJson(contacts);

      print('Contact added: ${contact.name}');
      return contact;
    } catch (e) {
      print('Error adding contact: $e');
      throw Exception('Failed to add contact');
    }
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    try {
      final contacts = await _readContactsFromJson();

      final index = contacts.indexWhere((c) => c.id == contact.id);
      if (index == -1) {
        throw Exception('Contact not found');
      }

      contacts[index] = contact;
      await _writeContactsToJson(contacts);

      print('Contact updated: ${contact.name}');
      return contact;
    } catch (e) {
      print('Error updating contact: $e');
      throw Exception('Failed to update contact');
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      final contacts = await _readContactsFromJson();

      final beforeCount = contacts.length;
      contacts.removeWhere((c) => c.id == id);
      final afterCount = contacts.length;

      if (beforeCount == afterCount) {
        throw Exception('Contact not found');
      }

      await _writeContactsToJson(contacts);
      print('Contact deleted: $id');
    } catch (e) {
      print('Error deleting contact: $e');
      throw Exception('Failed to delete contact');
    }
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    try {
      final contacts = await _readContactsFromJson();

      if (query.isEmpty) return contacts;

      final lowercaseQuery = query.toLowerCase();
      final results = contacts.where((contact) {
        return contact.name.toLowerCase().contains(lowercaseQuery) ||
            contact.email.toLowerCase().contains(lowercaseQuery) ||
            (contact.phone?.toLowerCase().contains(lowercaseQuery) ?? false);
      }).toList();

      print('Search for "$query" returned ${results.length} results');
      return results;
    } catch (e) {
      print('Error searching contacts: $e');
      throw Exception('Failed to search contacts');
    }
  }

  @override
  Future<void> clearAllContacts() async {
    try {
      await _writeContactsToJson([]);
      print('All contacts cleared');
    } catch (e) {
      print('Error clearing contacts: $e');
      throw Exception('Failed to clear contacts');
    }
  }

  // Additional helper methods for local storage

  Future<bool> hasContacts() async {
    try {
      final contacts = await _readContactsFromJson();
      return contacts.isNotEmpty;
    } catch (e) {
      print('Error checking hasContacts: $e');
      return false;
    }
  }

  Future<int> getContactCount() async {
    try {
      final contacts = await _readContactsFromJson();
      return contacts.length;
    } catch (e) {
      print('Error getting contact count: $e');
      return 0;
    }
  }

  Future<void> initializeWithSampleData() async {
    try {
      print('Checking if initialization is needed...');

      final hasData = await hasContacts();

      if (!hasData) {
        print('No contacts found, initializing with sample data...');

        final sampleContacts = <Contact>[
          const Contact(
            id: '1',
            name: 'Savannah Nguyen',
            email: 'savannah.nguyen@example.com',
            avatarUrl: '',
            avatarColor: 'yellow',
            phone: '+1 234 567 8901',
          ),
          const Contact(
            id: '2',
            name: 'Ralph Edwards',
            email: 'ralph.edwards@example.com',
            avatarUrl: '',
            avatarColor: 'purple',
            phone: '+1 234 567 8902',
          ),
          const Contact(
            id: '3',
            name: 'Kathryn Murphy',
            email: 'kathryn.murphy@example.com',
            avatarUrl: '',
            avatarColor: 'blue',
            phone: '+1 234 567 8903',
          ),
          const Contact(
            id: '4',
            name: 'Albert Flores',
            email: 'albert.flores@example.com',
            avatarUrl: '',
            avatarColor: 'grey',
            phone: '+1 234 567 8904',
          ),
          const Contact(
            id: '5',
            name: 'Courtney Henry',
            email: 'courtney.henry@example.com',
            avatarUrl: '',
            avatarColor: 'yellow',
            phone: '+1 234 567 8905',
          ),
        ];

        await _writeContactsToJson(sampleContacts);
        print(
          'Sample data initialized successfully with ${sampleContacts.length} contacts',
        );
      } else {
        print('Contacts already exist, skipping initialization');
      }
    } catch (e) {
      print('Error initializing sample data: $e');
      // Don't throw - let the app continue even if initialization fails
    }
  }

  // Debug helper - print file path
  Future<void> printFilePath() async {
    final path = await _storageService.getFilePath();
    print('Contacts file path: $path');
  }
}
