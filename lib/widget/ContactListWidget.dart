// lib/widgets/contact_list.dart
import 'package:flutter/material.dart';
import '../model/contact.dart';
import '../share/widget/ContactCardItem.dart';

class ContactList extends StatelessWidget {
  final List<Contact> contacts;
  final Function(Contact)? onContactTap;

  const ContactList({Key? key, required this.contacts, this.onContactTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactCardItem(
          contact: contact,
          onTap: () {
            if (onContactTap != null) {
              onContactTap!(contact);
            }
          },
        );
      },
    );
  }
}
