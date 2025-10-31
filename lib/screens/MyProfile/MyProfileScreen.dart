// lib/screens/my_profile/my_profile_screen.dart
import 'package:flutter/material.dart';

class MyProfileScreen extends StatelessWidget {
  final VoidCallback onNavigateToEditProfile;
  final VoidCallback onNavigateToSettings;

  const MyProfileScreen({
    Key? key,
    required this.onNavigateToEditProfile,
    required this.onNavigateToSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: onNavigateToSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple.shade100,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Name
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              'john.doe@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onNavigateToEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Profile Stats
            _buildStatCard(),
            const SizedBox(height: 20),

            // Menu Items
            _buildMenuItem(
              icon: Icons.contacts,
              title: 'My Contacts',
              subtitle: '45 contacts',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.favorite,
              title: 'Favorites',
              subtitle: '12 contacts',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Recent Activity',
              subtitle: 'Last 7 days',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.backup,
              title: 'Backup & Sync',
              subtitle: 'Last synced 2 hours ago',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Contacts', '45'),
          Container(width: 1, height: 40, color: Colors.purple.shade200),
          _buildStat('Groups', '8'),
          Container(width: 1, height: 40, color: Colors.purple.shade200),
          _buildStat('Favorites', '12'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade50,
          child: Icon(icon, color: Colors.purple.shade400),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
