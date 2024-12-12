import 'package:flutter/material.dart';
import 'package:member_link/views/product/product_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function onLogout;

  const AppDrawer({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(198, 25, 26, 26),
            ),
            child: Text(
              'Member Link',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('News'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart), // New Icon for Products
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const ProductScreen()), // Navigate to Product Screen
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Events'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const EventsPage()), // Navigate to Events Page
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // Navigate to a Settings page (not implemented here)
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              onLogout(); // Call the logout function
            },
          ),
        ],
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: const Center(
        child: Text("No events available yet."),
      ),
    );
  }
}
