import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.label,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.red[900]!,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[900],
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.nunito(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedDate != null
                            ? DateFormat('MMMM d, y').format(selectedDate!)
                            : 'Select date',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
