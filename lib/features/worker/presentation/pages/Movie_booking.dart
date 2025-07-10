import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learning2/core/constants/fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Booking',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const MovieBooking(),
    );
  }
}

class MovieBooking extends StatefulWidget {
  const MovieBooking({super.key});

  @override
  State<MovieBooking> createState() => _MovieBookingState();
}

class _MovieBookingState extends State<MovieBooking> {
  final TextEditingController _employeeCodeController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();

  String? _selectedShowTime;
  String? _selectedPersonalOfficial;
  final Set<int> _selectedSeats = {};
  final Set<int> _bookedSeats = {};

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(
            title,
            style: Fonts.heading2,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(25.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: Fonts.body,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String hintText,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(
              hintText,
              style: Fonts.body.copyWith(fontSize: 18),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: Fonts.body),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildSeat(int seatNumber) {
    Color seatColor;
    if (_bookedSeats.contains(seatNumber)) {
      seatColor = Colors.red;
    } else if (_selectedSeats.contains(seatNumber)) {
      seatColor = Colors.amber;
    } else {
      seatColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {
        if (_bookedSeats.contains(seatNumber)) return;
        setState(() {
          _selectedSeats.contains(seatNumber)
              ? _selectedSeats.remove(seatNumber)
              : _selectedSeats.add(seatNumber);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: seatColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            seatNumber.toString(),
            style: Fonts.bodyBold.copyWith(fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatRow(int startSeat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First 2 seats
          _buildSeat(startSeat),
          const SizedBox(width: 4),
          _buildSeat(startSeat + 1),
          const SizedBox(width: 12),
          // Middle 4 seats
          _buildSeat(startSeat + 2),
          const SizedBox(width: 4),
          _buildSeat(startSeat + 3),
          const SizedBox(width: 4),
          _buildSeat(startSeat + 4),
          const SizedBox(width: 4),
          _buildSeat(startSeat + 5),
          const SizedBox(width: 12),
          // Last 2 seats
          _buildSeat(startSeat + 6),
          const SizedBox(width: 4),
          _buildSeat(startSeat + 7),
        ],
      ),
    );
  }

  Widget _buildSeatLayout() {
    return Column(
      children: [
        for (int i = 0; i < 6; i++) _buildSeatRow(i * 8 + 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie Booking',
          style: Fonts.heading2.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FB), Color(0xFFE0ECFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildSectionTitle("Select Show Time and Movie", Icons.schedule),
                const SizedBox(height: 10),
                _buildStyledDropdown(
                  hintText: "Select Show Time & Movie",
                  items: ['10:00 AM - Movie A', '02:00 PM - Movie B', '06:00 PM - Movie C'],
                  selectedValue: _selectedShowTime,
                  onChanged: (value) => setState(() => _selectedShowTime = value),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Personal / Official Guest", Icons.person_pin),
                const SizedBox(height: 10),
                _buildStyledDropdown(
                  hintText: "Personal / Official",
                  items: ['Personal', 'Official'],
                  selectedValue: _selectedPersonalOfficial,
                  onChanged: (value) => setState(() => _selectedPersonalOfficial = value),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Employee Code", Icons.badge),
                const SizedBox(height: 10),
                _buildStyledTextField(
                  controller: _employeeCodeController,
                  hintText: 'Enter Employee Code',
                ),
                const SizedBox(height: 20),
                _buildSectionTitle("Mobile No (Entry Pass SMS)", Icons.phone),
                const SizedBox(height: 10),
                _buildStyledTextField(
                  controller: _mobileNumberController,
                  hintText: 'Enter Mobile Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                _buildSectionTitle("Select Seats", Icons.event_seat),
                _buildSeatLayout(),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedSeats.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one seat')),
                        );
                        return;
                      }
                      setState(() {
                        _bookedSeats.addAll(_selectedSeats);
                        _selectedSeats.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entry Pass(es) booked successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 10,
                      shadowColor: Colors.deepPurple.withOpacity(0.3),
                    ),
                    child: const Text('🎟 Book Entry Pass', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}