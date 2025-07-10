import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning2/features/authentication/presentation/pages/login_screen.dart';
import 'package:learning2/core/constants/fonts.dart';

class WorkerAppDrawer extends StatefulWidget {
  const WorkerAppDrawer({super.key});

  @override
  State<WorkerAppDrawer> createState() => _WorkerAppDrawerState();
}

class _WorkerAppDrawerState extends State<WorkerAppDrawer> {
  // Selected category
  String _selectedCategory = 'Accounts';

  // List of categories
  final List<String> _categories = [
    'Accounts',
    'HR&Admin',
    'General',
    'Personnel',
    'Employee',
  ];

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminLoggedIn', false);
    await prefs.setBool('isLoggedIn', false);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer header with Birla White
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent, // A slightly more vibrant blue
                gradient: LinearGradient(
                  // Add a subtle gradient
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // Add a shadow for depth
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Error handling for image loading is good
                  SizedBox(
                    width: 700,
                    child: Image.asset(
                      'assets/logo.png', // Ensure this asset exists in pubspec.yaml
                      height: 97,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading drawer header image: $error');
                        return const Icon(
                          Icons.business,
                          size: 60,
                          color: Colors.white,
                        ); // Placeholder icon
                      },
                    ),
                  ),
                  const SizedBox(height: 12), // Increased spacing
                  const Text(
                    'Birla White',
                    style: Fonts.heading2,
                  ),
                ],
              ),
            ),

            // Categories list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return Container(
                    color: isSelected ? Colors.lightBlue : Colors.white,
                    child: ListTile(
                      title: Text(
                        category,
                        style: isSelected ? Fonts.bodyBold : Fonts.body,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Logout option
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: Fonts.bodyBold.copyWith(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
