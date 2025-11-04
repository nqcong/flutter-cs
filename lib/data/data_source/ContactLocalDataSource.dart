import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/data/storage/JSONStorageService.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/rxdart.dart';

class ContactLocalDataSource implements ContactDataSource {
  final JsonStorageService _storageService;

  // Main contacts stream - BehaviorSubject holds current state
  final BehaviorSubject<List<Contact>> _contactsSubject =
      BehaviorSubject<List<Contact>>.seeded([]);

  // Event stream for operations
  final PublishSubject<ContactEvent> _eventSubject =
      PublishSubject<ContactEvent>();

  ContactLocalDataSource({JsonStorageService? storageService})
    : _storageService = storageService ?? JsonStorageService() {
    _initialize();
  }

  void _initialize() {
    // Listen to events and handle them
    _eventSubject.listen(_handleEvent);

    // Load initial data
    _loadInitialContacts();
  }

  Future<void> _loadInitialContacts() async {
    try {
      final contacts = await _readContactsFromJson();
      _contactsSubject.add(contacts);
      print('Loaded ${contacts.length} contacts from local storage');
    } catch (e) {
      print('Error loading initial contacts: $e');
      _contactsSubject.addError(e);
    }
  }

  // ============================================
  // STREAMS IMPLEMENTATION
  // ============================================

  @override
  Stream<List<Contact>> get contactsStream => _contactsSubject.stream;

  @override
  List<Contact> get currentContacts => _contactsSubject.value;

  @override
  Stream<ContactStatistics> get statisticsStream {
    return contactsStream.map((contacts) {
      return ContactStatistics(
        total: contacts.length,
        favorites: contacts.where((c) => c.isFavorite).length,
        withPhone: contacts
            .where((c) => c.phone != null && c.phone!.isNotEmpty)
            .length,
        withoutPhone: contacts
            .where((c) => c.phone == null || c.phone!.isEmpty)
            .length,
      );
    });
  }

  @override
  Stream<List<Contact>> get favoritesStream {
    return contactsStream.map((contacts) {
      return contacts.where((c) => c.isFavorite).toList();
    });
  }

  @override
  Stream<List<Contact>> searchContacts(Stream<String> queryStream) {
    return queryStream
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .switchMap((query) {
          if (query.isEmpty) {
            return contactsStream;
          }

          return contactsStream.map((contacts) {
            final lowercaseQuery = query.toLowerCase();
            return contacts.where((contact) {
              return contact.name.toLowerCase().contains(lowercaseQuery) ||
                  contact.email.toLowerCase().contains(lowercaseQuery) ||
                  (contact.phone?.toLowerCase().contains(lowercaseQuery) ??
                      false);
            }).toList();
          });
        });
  }

  @override
  Stream<List<Contact>> getFilteredContacts(ContactFilter filter) {
    return contactsStream.map((contacts) {
      var filtered = List<Contact>.from(contacts);

      // Apply search filter
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        filtered = filtered.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
              contact.email.toLowerCase().contains(query) ||
              (contact.phone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      // Apply favorites filter
      if (filter.favoritesOnly == true) {
        filtered = filtered.where((c) => c.isFavorite).toList();
      }

      // Apply color filter
      if (filter.colorFilter != null && filter.colorFilter!.isNotEmpty) {
        filtered = filtered
            .where((c) => c.avatarColor == filter.colorFilter)
            .toList();
      }

      // Apply sorting
      if (filter.sortType != null) {
        switch (filter.sortType!) {
          case ContactSortType.nameAsc:
            filtered.sort((a, b) => a.name.compareTo(b.name));
            break;
          case ContactSortType.nameDesc:
            filtered.sort((a, b) => b.name.compareTo(a.name));
            break;
          case ContactSortType.emailAsc:
            filtered.sort((a, b) => a.email.compareTo(b.email));
            break;
          case ContactSortType.emailDesc:
            filtered.sort((a, b) => b.email.compareTo(a.email));
            break;
          case ContactSortType.recentlyAdded:
            filtered.sort((a, b) => b.id.compareTo(a.id));
            break;
          case ContactSortType.oldestFirst:
            filtered.sort((a, b) => a.id.compareTo(b.id));
            break;
        }
      }

      return filtered;
    });
  }

  // ============================================
  // CRUD OPERATIONS IMPLEMENTATION
  // ============================================

  @override
  Future<List<Contact>> getContacts() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      return currentContacts;
    } catch (e) {
      print('Error getting contacts: $e');
      throw Exception('Failed to load contacts');
    }
  }

  @override
  Future<Contact> getContactById(String id) async {
    try {
      final contact = currentContacts.firstWhere(
        (c) => c.id == id,
        orElse: () => throw Exception('Contact not found'),
      );
      return contact;
    } catch (e) {
      print('Error getting contact by id: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    _eventSubject.add(AddContactEvent(contact));
    return contact;
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    _eventSubject.add(UpdateContactEvent(contact));
    return contact;
  }

  @override
  Future<void> deleteContact(String id) async {
    _eventSubject.add(DeleteContactEvent(id));
  }

  @override
  Future<Contact> toggleFavorite(String id) async {
    _eventSubject.add(ToggleFavoriteEvent(id));
    final contact = await getContactById(id);
    return contact;
  }

  @override
  Future<void> clearAllContacts() async {
    _eventSubject.add(ClearAllContactsEvent());
  }

  @override
  Future<int> getContactCount() async {
    return currentContacts.length;
  }

  @override
  Future<void> initializeWithSampleData() async {
    try {
      if (currentContacts.isEmpty) {
        print('Initializing with sample data...');

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
        _contactsSubject.add(sampleContacts);
        print('Sample data initialized successfully');
      }
    } catch (e) {
      print('Error initializing sample data: $e');
    }
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  Future<void> _handleEvent(ContactEvent event) async {
    try {
      final currentContacts = List<Contact>.from(_contactsSubject.value);

      if (event is AddContactEvent) {
        if (currentContacts.any((c) => c.id == event.contact.id)) {
          throw Exception('Contact with this ID already exists');
        }
        currentContacts.add(event.contact);
      } else if (event is UpdateContactEvent) {
        final index = currentContacts.indexWhere(
          (c) => c.id == event.contact.id,
        );
        if (index == -1) throw Exception('Contact not found');
        currentContacts[index] = event.contact;
      } else if (event is DeleteContactEvent) {
        currentContacts.removeWhere((c) => c.id == event.contactId);
      } else if (event is ToggleFavoriteEvent) {
        final index = currentContacts.indexWhere(
          (c) => c.id == event.contactId,
        );
        if (index != -1) {
          currentContacts[index] = currentContacts[index].copyWith(
            isFavorite: !currentContacts[index].isFavorite,
          );
        }
      } else if (event is ClearAllContactsEvent) {
        currentContacts.clear();
      }

      // Save to storage
      await _writeContactsToJson(currentContacts);

      // Emit new state
      _contactsSubject.add(currentContacts);
    } catch (e) {
      print('Error handling event: $e');
      _contactsSubject.addError(e);
    }
  }

  Future<List<Contact>> _readContactsFromJson() async {
    try {
      final data = await _storageService.readJson();
      final contactsList = data['contacts'] as List<dynamic>? ?? [];

      return contactsList
          .map((json) => Contact.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error reading contacts from JSON: $e');
      return [];
    }
  }

  Future<void> _writeContactsToJson(List<Contact> contacts) async {
    try {
      final contactJsonList = contacts.map((c) => c.toJson()).toList();
      final data = <String, dynamic>{'contacts': contactJsonList};
      await _storageService.writeJson(data);
    } catch (e) {
      print('Error writing contacts to JSON: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _contactsSubject.close();
    _eventSubject.close();
  }
}

// ============================================
// EVENT CLASSES
// ============================================

abstract class ContactEvent {}

class AddContactEvent extends ContactEvent {
  final Contact contact;
  AddContactEvent(this.contact);
}

class UpdateContactEvent extends ContactEvent {
  final Contact contact;
  UpdateContactEvent(this.contact);
}

class DeleteContactEvent extends ContactEvent {
  final String contactId;
  DeleteContactEvent(this.contactId);
}

class ToggleFavoriteEvent extends ContactEvent {
  final String contactId;
  ToggleFavoriteEvent(this.contactId);
}

class ClearAllContactsEvent extends ContactEvent {}
