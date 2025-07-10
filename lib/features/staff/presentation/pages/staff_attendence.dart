import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learning2/core/constants/fonts.dart';

class StaffAttendence extends StatefulWidget {
  const StaffAttendence({super.key});

  @override
  State<StaffAttendence> createState() => _StaffAttendenceState();
}

class _StaffAttendenceState extends State<StaffAttendence> {
  final TextEditingController _empController = TextEditingController(text: '0557');
  DateTime selectedMonth = DateTime.now();

  // Example attendance data: you should replace it with actual data from API/db
  // Status: 'G' = Present, 'A' = Absent, 'WO' = Weekly Off, 'R' = Regularize
  // Can add 'H' for Holiday, etc.
  final Map<String, String> attendance = {
    '2025-05-01': 'G',
    '2025-05-02': 'G',
    '2025-05-03': 'G',
    '2025-05-04': 'WO',
    '2025-05-05': 'G',
    '2025-05-06': 'G',
    '2025-05-07': 'G',
    '2025-05-08': 'G',
    '2025-05-09': 'G',
    '2025-05-10': 'G',
    '2025-05-11': 'WO',
    '2025-05-12': 'G',
    '2025-05-13': 'G',
    '2025-05-14': 'G',
    '2025-05-15': 'G',
    '2025-05-16': 'G',
    '2025-05-17': 'G',
    '2025-05-18': 'WO',
    '2025-05-19': 'G',
    '2025-05-20': 'G',
    '2025-05-21': 'G',
    '2025-05-22': 'G',
    '2025-05-23': 'G',
    '2025-05-24': 'G',
    '2025-05-25': 'WO',
    '2025-05-26': 'G',
    '2025-05-27': 'G',
    '2025-05-28': 'G',
    '2025-05-29': 'G',
    '2025-05-30': 'G',
    '2025-05-31': 'G',
  };

  List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);

    // Start from the first day of the month
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);

    // To build vertical weeks, get the weekday of firstDay (1=Mon,...)
    int startOffset = firstDay.weekday - 1;

    List<DateTime?> calendarDays = List.generate(startOffset, (index) => null);
    for (int i = 0; i < daysInMonth; i++) {
      calendarDays.add(DateTime(selectedMonth.year, selectedMonth.month, i + 1));
    }

    // Add nulls at end to complete the last week (total % 7 == 0)
    while (calendarDays.length % 7 != 0) {
      calendarDays.add(null);
    }

    List<List<DateTime?>> weeks = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      weeks.add(calendarDays.sublist(i, i + 7));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'STAFF ATTENDANCE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            _buildFilters(context),
            const SizedBox(height: 10),
            _buildLegend(),
            const SizedBox(height: 10),
            _buildCalendarHeader(),
            ...weeks.map((week) => _buildWeekRow(week)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Employee Code", style: Fonts.bodyBold),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _empController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blue[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showMonthPicker(context, selectedMonth);
                      if (picked != null) setState(() => selectedMonth = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style: Fonts.body,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text("Go"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendBox("Regularize", Colors.green[300]!),
        _legendBox("Improper/Absent", Colors.red[300]!),
        _legendBox("Weekly Off / Paid Holiday", Colors.grey[400]!),
      ],
    );
  }

  Widget _legendBox(String text, Color color) {
    return Row(
      children: [
        Container(width: 18, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(text, style: Fonts.small),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((day) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              gradient: day == "Sun"
                  ? LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400])
                  : LinearGradient(colors: [Colors.pink.shade100, Colors.pink.shade200]),
            ),
            child: Center(
              child: Text(
                day,
                style: Fonts.bodyBold.copyWith(color: Colors.black87),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeekRow(List<DateTime?> week) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: week.map((date) => Expanded(child: _buildDayCell(date))).toList(),
    );
  }

  Widget _buildDayCell(DateTime? date) {
    if (date == null) {
      return Container(
        margin: const EdgeInsets.all(2),
        height: 70,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade100),
          color: Colors.transparent,
        ),
      );
    }

    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    String? status = attendance[dateKey];

    Color cellColor;
    String label = "";
    if (status == 'G') {
      cellColor = Colors.white;
      label = "Sft:G";
    } else if (status == 'WO') {
      cellColor = Colors.grey[300]!;
      label = "WO";
    } else if (status == 'A') {
      cellColor = Colors.red[100]!;
      label = "Absent";
    } else if (status == 'R') {
      cellColor = Colors.green[100]!;
      label = "Regularize";
    } else {
      cellColor = Colors.white;
    }

    TextStyle numStyle = Fonts.bodyBold.copyWith(fontSize: 16, color: status == 'WO' ? Colors.black : Colors.black87);

    return Container(
      margin: const EdgeInsets.all(2),
      height: 70,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border.all(color: Colors.blue.shade100),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 8,
            child: Text(
              '${date.day}',
              style: numStyle,
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Text(
              label,
              style: Fonts.small.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Month Picker
  Future<DateTime?> showMonthPicker(BuildContext context, DateTime selectedDate) {
    return showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(selectedDate.year - 3),
      lastDate: DateTime(selectedDate.year + 3),
      helpText: "Select Month",
      fieldHintText: "Month/Year",
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.lightBlue),
          ),
          child: child!,
        );
      },
    );
  }
}
