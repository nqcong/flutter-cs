import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/contact.dart';

class ContactRemoteDataSource implements ContactDataSource {
  // final ApiClient _apiClient;
  // final String baseUrl;

  // ContactRemoteDataSource({
  //   required ApiClient apiClient,
  //   required this.baseUrl,
  // }) : _apiClient = apiClient;

  @override
  Future<List<Contact>> getContacts() async {
    // TODO: Implement API call
    // final response = await _apiClient.get('$baseUrl/contacts');
    // return (response.data as List).map((json) => Contact.fromJson(json)).toList();
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<Contact> getContactById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<Contact> addContact(Contact contact) async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<void> deleteContact(String id) async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<List<Contact>> searchContacts(String query) async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }

  @override
  Future<void> clearAllContacts() async {
    // TODO: Implement API call
    throw UnimplementedError('API implementation coming soon');
  }
}
