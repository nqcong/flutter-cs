// lib/screens/contact_list/contact_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:contact/blocs/contactList/ContactListCubit.dart';
import 'package:contact/blocs/contactList/ContactListState.dart';
import 'package:contact/data/data_source/ContactDataSource.dart';
import 'package:contact/model/ContactFilterModel.dart';
import 'package:contact/share/widget/ContactCardItem.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ContactListCubit>().searchContacts(query);
  }

  Future<void> _onRefresh() async {
    await context.read<ContactListCubit>().refreshContacts();
  }

  void _showSortOptions() {
    final cubit = context.read<ContactListCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSortOption(
              'Name (A-Z)',
              ContactSortType.nameAsc,
              cubit.currentSortType,
              cubit,
            ),
            _buildSortOption(
              'Name (Z-A)',
              ContactSortType.nameDesc,
              cubit.currentSortType,
              cubit,
            ),
            _buildSortOption(
              'Email (A-Z)',
              ContactSortType.emailAsc,
              cubit.currentSortType,
              cubit,
            ),
            _buildSortOption(
              'Email (Z-A)',
              ContactSortType.emailDesc,
              cubit.currentSortType,
              cubit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String label,
    ContactSortType sortType,
    ContactSortType? currentSortType,
    ContactListCubit cubit,
  ) {
    final isSelected = sortType == currentSortType;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.green.shade400)
          : null,
      selected: isSelected,
      selectedTileColor: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        if (isSelected) {
          cubit.changeSortType(null);
        } else {
          cubit.changeSortType(sortType);
        }
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Contact',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.black),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              context.read<ContactListCubit>().onAddContactButtonTapped();
            },
            tooltip: 'Add Contact',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Banner
          BlocBuilder<ContactListCubit, ContactListState>(
            builder: (context, state) {
              final cubit = context.read<ContactListCubit>();

              return StreamBuilder<ContactStatistics>(
                stream: cubit.statisticsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final stats = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border(
                        bottom: BorderSide(color: Colors.blue.shade100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          stats.total.toString(),
                          Icons.contacts,
                        ),
                        _buildStatItem(
                          'Favorites',
                          stats.favorites.toString(),
                          Icons.favorite,
                        ),
                        _buildStatItem(
                          'With Phone',
                          stats.withPhone.toString(),
                          Icons.phone,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.green.shade400,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Active Sort Display
          BlocBuilder<ContactListCubit, ContactListState>(
            builder: (context, state) {
              final cubit = context.read<ContactListCubit>();
              final sortType = cubit.currentSortType;

              if (sortType == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Sorted by: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Chip(
                      avatar: const Icon(Icons.sort, size: 16),
                      label: Text(_getSortLabel(sortType)),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => cubit.clearSortFilter(),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
              );
            },
          ),

          // Contact List
          Expanded(
            child: BlocBuilder<ContactListCubit, ContactListState>(
              builder: (context, state) {
                if (state is ContactListLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ContactListError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<ContactListCubit>().loadContacts();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade400,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ContactListLoaded ||
                    state is ContactListActionInProgress) {
                  final contacts = state is ContactListLoaded
                      ? state.contacts
                      : (state as ContactListActionInProgress).contacts;

                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contacts_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No contacts found'
                                : 'No contacts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Try a different search'
                                : 'Tap + to add your first contact',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 100),
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ContactCardItem(
                          contact: contact,
                          onTap: () {
                            context.read<ContactListCubit>().onContactTapped(
                              contact,
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('Pull to refresh'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _getSortLabel(ContactSortType sortType) {
    switch (sortType) {
      case ContactSortType.nameAsc:
        return 'Name (A-Z)';
      case ContactSortType.nameDesc:
        return 'Name (Z-A)';
      case ContactSortType.emailAsc:
        return 'Email (A-Z)';
      case ContactSortType.emailDesc:
        return 'Email (Z-A)';
    }
  }
}
