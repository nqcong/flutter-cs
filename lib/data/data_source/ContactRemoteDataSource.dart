import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:rxdart/rxdart.dart';

class ContactRemoteDataSource implements ContactDataSource {
  // final ApiClient _apiClient;
  // final String baseUrl;

  // Main contacts stream
  final BehaviorSubject<List<Contact>> _contactsSubject =
      BehaviorSubject<List<Contact>>.seeded([]);

  // WebSocket or polling stream (for real-time updates)
  // StreamSubscription? _realtimeSubscription;

  ContactRemoteDataSource() {
    _initialize();
  }

  void _initialize() {
    // TODO: Setup WebSocket connection or polling for real-time updates
    // _realtimeSubscription = _setupRealtimeConnection();

    // Load initial data
    _loadInitialContacts();
  }

  Future<void> _loadInitialContacts() async {
    try {
      // TODO: Fetch from API
      // final contacts = await _apiClient.get('$baseUrl/contacts');
      // _contactsSubject.add(contacts);

      print('Remote data source initialized (implementation pending)');
    } catch (e) {
      print('Error loading contacts from API: $e');
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
        .debounceTime(
          const Duration(milliseconds: 500),
        ) // Longer debounce for API
        .distinct()
        .switchMap((query) async* {
          if (query.isEmpty) {
            yield* contactsStream;
            return;
          }

          try {
            // TODO: Call API search endpoint
            // final results = await _apiClient.get('$baseUrl/contacts/search?q=$query');
            // yield results;

            // For now, filter locally
            yield* contactsStream.map((contacts) {
              final lowercaseQuery = query.toLowerCase();
              return contacts.where((contact) {
                return contact.name.toLowerCase().contains(lowercaseQuery) ||
                    contact.email.toLowerCase().contains(lowercaseQuery) ||
                    (contact.phone?.toLowerCase().contains(lowercaseQuery) ??
                        false);
              }).toList();
            });
          } catch (e) {
            print('Error searching contacts via API: $e');
            yield [];
          }
        });
  }

  @override
  Stream<List<Contact>> getFilteredContacts(ContactFilter filter) {
    // TODO: Send filter to API and return results
    // For now, filter locally
    return contactsStream.map((contacts) {
      var filtered = List<Contact>.from(contacts);

      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final query = filter.searchQuery!.toLowerCase();
        filtered = filtered.where((contact) {
          return contact.name.toLowerCase().contains(query) ||
              contact.email.toLowerCase().contains(query) ||
              (contact.phone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      if (filter.favoritesOnly == true) {
        filtered = filtered.where((c) => c.isFavorite).toList();
      }

      if (filter.colorFilter != null && filter.colorFilter!.isNotEmpty) {
        filtered = filtered
            .where((c) => c.avatarColor == filter.colorFilter)
            .toList();
      }

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
      // TODO: Implement API call
      // final response = await _apiClient.get('$baseUrl/contacts');
      // return response.map((json) => Contact.fromJson(json)).toList();

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error getting contacts from API: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> getContactById(String id) async {
    try {
      // TODO: Implement API call
      // final response = await _apiClient.get('$baseUrl/contacts/$id');
      // return Contact.fromJson(response);

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error getting contact by id from API: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    try {
      // TODO: Implement API call
      // final response = await _apiClient.post('$baseUrl/contacts', contact.toJson());
      // final newContact = Contact.fromJson(response);

      // Update local stream
      // final updatedContacts = [...currentContacts, newContact];
      // _contactsSubject.add(updatedContacts);

      // return newContact;

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error adding contact via API: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    try {
      // TODO: Implement API call
      // final response = await _apiClient.put('$baseUrl/contacts/${contact.id}', contact.toJson());
      // final updatedContact = Contact.fromJson(response);

      // Update local stream
      // final updatedContacts = currentContacts.map((c) {
      //   return c.id == contact.id ? updatedContact : c;
      // }).toList();
      // _contactsSubject.add(updatedContacts);

      // return updatedContact;

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error updating contact via API: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      // TODO: Implement API call
      // await _apiClient.delete('$baseUrl/contacts/$id');

      // Update local stream
      // final updatedContacts = currentContacts.where((c) => c.id != id).toList();
      // _contactsSubject.add(updatedContacts);

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error deleting contact via API: $e');
      rethrow;
    }
  }

  @override
  Future<Contact> toggleFavorite(String id) async {
    try {
      // TODO: Implement API call
      // final response = await _apiClient.post('$baseUrl/contacts/$id/favorite');
      // final updatedContact = Contact.fromJson(response);

      // Update local stream
      // final updatedContacts = currentContacts.map((c) {
      //   return c.id == id ? updatedContact : c;
      // }).toList();
      // _contactsSubject.add(updatedContacts);

      // return updatedContact;

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error toggling favorite via API: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllContacts() async {
    try {
      // TODO: Implement API call
      // await _apiClient.delete('$baseUrl/contacts');

      // Update local stream
      // _contactsSubject.add([]);

      throw UnimplementedError('API implementation pending');
    } catch (e) {
      print('Error clearing contacts via API: $e');
      rethrow;
    }
  }

  @override
  Future<int> getContactCount() async {
    return currentContacts.length;
  }

  @override
  Future<void> initializeWithSampleData() async {
    // Not applicable for remote data source
    print('initializeWithSampleData not applicable for remote source');
  }

  @override
  void dispose() {
    _contactsSubject.close();
    // _realtimeSubscription?.cancel();
  }
}
