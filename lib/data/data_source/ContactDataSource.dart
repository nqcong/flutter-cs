// lib/data/data_sources/contact_data_source.dart

import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/model/contact.dart';
import 'package:rxdart/rxdart.dart';

/// Abstract interface for contact data sources with reactive streams
/// Both Local and Remote implementations must provide these streams
abstract class ContactDataSource {
  // ============================================
  // STREAMS - Reactive data access
  // ============================================
  
  /// Main contacts stream - emits whenever contacts change
  Stream<List<Contact>> get contactsStream;
  
  /// Current contacts value (synchronous access)
  List<Contact> get currentContacts;
  
  /// Statistics stream - emits contact statistics
  Stream<ContactStatistics> get statisticsStream;
  
  // ============================================
  // CRUD OPERATIONS - Return Futures
  // ============================================
  
  /// Get all contacts (one-time fetch)
  Future<List<Contact>> getContacts();
  
  /// Get contact by ID
  Future<Contact> getContactById(String id);
  
  /// Add new contact
  Future<Contact> addContact(Contact contact);
  
  /// Update existing contact
  Future<Contact> updateContact(Contact contact);
  
  /// Delete contact
  Future<void> deleteContact(String id);
  
  /// Toggle favorite status
  Future<Contact> toggleFavorite(String id);
  
  // ============================================
  // SEARCH & FILTER - Return Streams
  // ============================================
  
  /// Search contacts with query (reactive)
  Stream<List<Contact>> searchContacts(Stream<String> queryStream);
  
  /// Get filtered contacts based on criteria
  Stream<List<Contact>> getFilteredContacts(ContactFilter filter);
  
  /// Get only favorite contacts
  Stream<List<Contact>> get favoritesStream;
  
  // ============================================
  // UTILITY METHODS
  // ============================================
  
  /// Clear all contacts
  Future<void> clearAllContacts();
  
  /// Get contact count
  Future<int> getContactCount();
  
  /// Initialize with sample data (for testing/demo)
  Future<void> initializeWithSampleData();
  
  /// Dispose resources (close streams)
  void dispose();
}

/// Contact statistics model
class ContactStatistics {
  final int total;
  final int favorites;
  final int withPhone;
  final int withoutPhone;

  const ContactStatistics({
    required this.total,
    required this.favorites,
    required this.withPhone,
    required this.withoutPhone,
  });

  @override
  String toString() {
    return 'ContactStatistics(total: $total, favorites: $favorites, withPhone: $withPhone)';
  }
}