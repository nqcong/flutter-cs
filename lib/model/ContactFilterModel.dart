// lib/models/contact_filter.dart

import 'package:equatable/equatable.dart';

enum ContactSortType { nameAsc, nameDesc, emailAsc, emailDesc }

class ContactFilter extends Equatable {
  final String? searchQuery;
  final ContactSortType? sortType;

  const ContactFilter({this.searchQuery, this.sortType});

  // Fixed copyWith that properly handles null values
  ContactFilter copyWith({
    String? searchQuery,
    ContactSortType? sortType,
    bool clearSearchQuery = false,
    bool clearSortType = false,
  }) {
    return ContactFilter(
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      sortType: clearSortType ? null : (sortType ?? this.sortType),
    );
  }

  bool get hasFilters =>
      (searchQuery != null && searchQuery!.isNotEmpty) || sortType != null;

  @override
  List<Object?> get props => [searchQuery, sortType];

  @override
  String toString() {
    return 'ContactFilter(searchQuery: $searchQuery, sortType: $sortType)';
  }
}
