import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/data/data_source/ContactLocalDataSource.dart';
import 'package:contact/data/data_source/ContactRemoteDataSource.dart';
import 'package:contact/data/storage/JSONStorageService.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/repositories/ContactRepositoryImpl.dart';

enum DataSourceType { local, remote }

class ContactRepositoryFactory {
  static ContactRepository create({
    DataSourceType type = DataSourceType.local,
  }) {
    ContactDataSource dataSource;

    switch (type) {
      case DataSourceType.local:
        dataSource = ContactLocalDataSource(
          storageService: JsonStorageService(),
        );
        break;

      case DataSourceType.remote:
        dataSource = ContactRemoteDataSource(
          // apiClient: ApiClient(),
          // baseUrl: 'https://api.example.com',
        );
        break;
    }

    return ContactRepositoryImpl(dataSource: dataSource);
  }

  // Create repository with local data source (default)
  static ContactRepository createLocal() {
    return create(type: DataSourceType.local);
  }

  // Create repository with remote data source
  static ContactRepository createRemote() {
    return create(type: DataSourceType.remote);
  }

  // Create repository with sync strategy (local + remote)
  // This could implement offline-first approach
  static Future<ContactRepository> createWithSync() async {
    // TODO: Implement sync strategy
    // Could use local as primary and sync with remote
    return createLocal();
  }
}
