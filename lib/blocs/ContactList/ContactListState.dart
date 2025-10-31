// lib/blocs/contact_list/contact_list_state.dart

import 'package:contact/model/contact.dart';
import 'package:equatable/equatable.dart';

abstract class ContactListState extends Equatable {
  const ContactListState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ContactListInitial extends ContactListState {
  const ContactListInitial();
}

// Loading state
class ContactListLoading extends ContactListState {
  const ContactListLoading();
}

// Success state - contacts loaded
class ContactListLoaded extends ContactListState {
  final List<Contact> contacts;
  final String? searchQuery;

  const ContactListLoaded({
    required this.contacts,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [contacts, searchQuery];

  ContactListLoaded copyWith({
    List<Contact>? contacts,
    String? searchQuery,
  }) {
    return ContactListLoaded(
      contacts: contacts ?? this.contacts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Error state
class ContactListError extends ContactListState {
  final String message;

  const ContactListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Action in progress (like toggling favorite while keeping UI visible)
class ContactListActionInProgress extends ContactListState {
  final List<Contact> contacts;
  final String actionId; // ID of contact being updated

  const ContactListActionInProgress({
    required this.contacts,
    required this.actionId,
  });

  @override
  List<Object?> get props => [contacts, actionId];
}