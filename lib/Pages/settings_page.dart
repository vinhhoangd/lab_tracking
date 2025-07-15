import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.greenAccent.shade400,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: const Text('Profile'),
            subtitle: const Text('Manage your account settings'),
            onTap: () {
              // Add profile settings functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile settings coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.orange),
            title: const Text('Notifications'),
            subtitle: const Text('Configure app notifications'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Privacy & Security'),
            subtitle: const Text('Manage your privacy settings'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.purple),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.teal),
            title: const Text('About'),
            subtitle: const Text('App version and information'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Lab Tracking',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 64),
                children: const [
                  Text('A barcode scanning app for lab inventory management.'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Add logout functionality here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logout functionality coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 