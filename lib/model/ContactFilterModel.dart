import 'package:equatable/equatable.dart';

enum ContactSortType {
  nameAsc,
  nameDesc,
  emailAsc,
  emailDesc,
  recentlyAdded,
  oldestFirst,
}

class ContactFilter extends Equatable {
  final String? searchQuery;
  final bool? favoritesOnly;
  final ContactSortType? sortType;
  final String? colorFilter;

  const ContactFilter({
    this.searchQuery,
    this.favoritesOnly,
    this.sortType,
    this.colorFilter,
  });

  ContactFilter copyWith({
    String? searchQuery,
    bool? favoritesOnly,
    ContactSortType? sortType,
    String? colorFilter,
  }) {
    return ContactFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sortType: sortType ?? this.sortType,
      colorFilter: colorFilter ?? this.colorFilter,
    );
  }

  bool get hasFilters =>
      searchQuery != null ||
      favoritesOnly == true ||
      sortType != null ||
      colorFilter != null;

  @override
  List<Object?> get props => [
    searchQuery,
    favoritesOnly,
    sortType,
    colorFilter,
  ];
}
