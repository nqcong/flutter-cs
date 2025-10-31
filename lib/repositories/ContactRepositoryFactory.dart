
import 'package:contact/data/data_source/ContactLocalDataSource.dart';
import 'package:contact/data/data_source/ContactRemoteDataSource.dart';
import 'package:contact/data/storage/JSONStorageService.dart';
import 'package:contact/repositories/ContactRepository.dart';
import 'package:contact/repositories/ContactRepositoryImpl.dart';

enum DataSourceType {
  local,
  remote,
}

class ContactRepositoryFactory {
  static ContactRepository create({
    DataSourceType type = DataSourceType.local,
  }) {
    switch (type) {
      case DataSourceType.local:
        return ContactRepositoryImpl(
          dataSource: ContactLocalDataSource(
            storageService: JsonStorageService(),
          ),
        );
      
      case DataSourceType.remote:
        return ContactRepositoryImpl(
          dataSource: ContactRemoteDataSource(),
        );
    }
  }

  // Create repository with local data source (default)
  static ContactRepository createLocal() {
    return create(type: DataSourceType.local);
  }

  // Create repository with remote data source
  static ContactRepository createRemote() {
    return create(type: DataSourceType.remote);
  }

  // Create repository with both local and remote (sync strategy)
  // This could be used for offline-first approach
  static Future<ContactRepository> createWithSync() async {
    // TODO: Implement sync strategy
    // For now, just return local
    return createLocal();
  }
}