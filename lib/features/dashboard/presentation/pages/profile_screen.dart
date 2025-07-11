import 'package:flutter/material.dart';
import 'package:learning2/core/theme/app_theme.dart';
import 'package:learning2/features/dashboard/presentation/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SparshTheme.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account Info'),
                      const SizedBox(height: 14),
                      _buildInfoCard([
                        _buildTextField('Username*', Icons.person_outline),
                        _buildTextField('Email Address*', Icons.email_outlined),
                        _buildTextField('Phone Number*', Icons.phone_outlined),
                      ]),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Dashboard Report'),
                      const SizedBox(height: 14),
                      _buildInfoCard([
                        _buildDropdownField('Select Report*', Icons.assessment_outlined),
                      ]),
                      const SizedBox(height: 22),
                      _buildSectionTitle('Personal Info'),
                      const SizedBox(height: 14),
                      _buildInfoCard([
                        _buildDropdownField('Gender*', Icons.person_outline),
                        _buildTextField('Address*', Icons.location_on_outlined),
                      ]),
                      const SizedBox(height: 32),
                      _buildLogoutButton(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: SparshTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.11),
                          blurRadius: 5,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: SparshTheme.primaryBlue,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Magan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.23),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'ID S2948',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'IT Department',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.work_outline,
                  value: '5',
                  label: 'Projects',
                ),
                _buildStatCard(
                  icon: Icons.star_outline,
                  value: '4.8',
                  label: 'Rating',
                ),
                _buildStatCard(
                  icon: Icons.calendar_today_outlined,
                  value: '2',
                  label: 'Years',
                ),
              ],
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAction(icon: Icons.edit_outlined, label: 'Edit'),
                _buildQuickAction(icon: Icons.settings_outlined, label: 'Settings'),
                _buildQuickAction(icon: Icons.notifications_outlined, label: 'Alerts'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon) {
    List<DropdownMenuItem<String>> items = [];

    if (label == 'Gender*') {
      items = const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ];
    } else if (label == 'Select Report*') {
      items = const [
        DropdownMenuItem(value: 'Sales Summary', child: Text('Sales Summary')),
        DropdownMenuItem(value: 'DSR VIST', child: Text('DSR VIST')),
        DropdownMenuItem(value: 'Token Scan', child: Text('Token Scan')),
      ];
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
        ),
        items: items,
        onChanged: (value) {},
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1976D2)),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildLogoutButton(context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final bool? confirmLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: Color(0xFF1976D2)),
                  ),
                ),
              ],
            ),
          );

          if (confirmLogout == true) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SplashScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1976D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
