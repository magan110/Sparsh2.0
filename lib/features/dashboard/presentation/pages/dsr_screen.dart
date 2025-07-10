import 'package:flutter/material.dart';
import 'home_screen.dart';

class DsrScreen extends StatefulWidget {
  const DsrScreen({super.key});

  @override
  State<DsrScreen> createState() => _DsrScreenState();
}

class _DsrScreenState extends State<DsrScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedCard({required Widget child}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: child,
    );
  }

  Widget textField(String label, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: InkWell(
              onTap: () {
                // Handle upload
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF2196F3).withOpacity(0.5),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Click to upload',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supported formats: JPG, PNG, PDF',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return _buildAnimatedCard(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
        elevation: 2,
        child: InkWell(
          onTap: () {
            // Handle selection
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 36, color: const Color(0xFF2196F3)),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    // You can also change this to Map<String, dynamic> to avoid the casts
    final List<Map<String, Object>> activities = [
      {'title': 'Personal Visit',                         'icon': Icons.person},
      {'title': 'Phone Call with Builder/Stockist',       'icon': Icons.call},
      {'title': 'Meetings With Contractor / Stockist',    'icon': Icons.group},
      {'title': 'Visit to Get / Check Sampling at Site',  'icon': Icons.visibility},
      {'title': 'Meeting with New Purchaser/Retailer',    'icon': Icons.store},
      {'title': 'BTL Activities',                         'icon': Icons.campaign},
      {'title': 'Internal Team/Review Meetings',          'icon': Icons.meeting_room},
      {'title': 'Office Work',                            'icon': Icons.work},
      {'title': 'On Leave / Off Day',                     'icon': Icons.beach_access},
      {'title': 'Work From Home',                         'icon': Icons.home},
      {'title': 'Any Other Activity',                     'icon': Icons.more_horiz},
      {'title': 'Phone call with Unregistered Purchasers','icon': Icons.phone},
    ];

    List<Widget> rows = [];
    for (int i = 0; i < activities.length; i += 2) {
      // cast Object → String and Object → IconData
      final title1 = activities[i]['title'] as String;
      final icon1  = activities[i]['icon']  as IconData;

      Widget first = _buildActivityCard(title1, icon1);

      Widget second;
      if (i + 1 < activities.length) {
        final title2 = activities[i + 1]['title'] as String;
        final icon2  = activities[i + 1]['icon']  as IconData;
        second = _buildActivityCard(title2, icon2);
      } else {
        // fill the gap if odd number of cards
        second = const Expanded(child: SizedBox());
      }

      rows.add(Row(children: [ first, second ]));
    }

    return Column(children: rows);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('DSR DATA'),
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2196F3).withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF2196F3),
                          const Color(0xFF2196F3).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2196F3).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basic Data',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter retailer information',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildSectionCard(
                  title: 'Company Information',
                  children: [
                    textField('Process Type'),
                    textField('Retailer Company'),
                    textField('Area'),
                    textField('District'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Registration Details',
                  children: [
                    Text(
                      'Register With PAN/GST',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('GST'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.credit_card),
                            label: const Text('PAN'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                _buildSectionCard(
                  title: 'Business Information',
                  children: [
                    textField('GST Number'),
                    textField('PAN Number'),
                    textField('Firm Name'),
                    textField('Mobile', keyboardType: TextInputType.phone),
                    textField('Official Telephone', keyboardType: TextInputType.phone),
                    textField('E - Mail Id', keyboardType: TextInputType.emailAddress),
                  ],
                ),

                _buildSectionCard(
                  title: 'Address Information',
                  children: [
                    textField('Address Name 1'),
                    textField('Address Name 2'),
                    textField('Address Name 3'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Contact Details',
                  children: [
                    textField('Stockiest Code'),
                    textField('Tally Retailer Code'),
                    textField('Concern Employee'),
                  ],
                ),

                _buildSectionCard(
                  title: 'Document Uploads',
                  children: [
                    _buildUploadSection(
                      context,
                      'Retailer Profile Image',
                      Icons.person,
                    ),
                    const SizedBox(height: 24),
                    _buildUploadSection(
                      context,
                      'PAN/GST No Image Upload',
                      Icons.receipt_long,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Additional Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    textField('Scheme required'),
                    textField('Aadhar card No.'),
                    const SizedBox(height: 16),
                    _buildUploadSection(
                      context,
                      'Aadhar Card Upload',
                      Icons.credit_card,
                    ),
                  ],
                ),

                // Activity Type Section (2 cards per row)
                _buildSectionCard(
                  title: 'Activity Type',
                  children: [
                    _buildActivitySection(),
                  ],
                ),

                const SizedBox(height: 24),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
