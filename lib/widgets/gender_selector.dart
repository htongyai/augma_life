import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 12),
            child: Text(
              'Gender',
              style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  context: context,
                  gender: 'Male',
                  icon: Icons.male,
                ),
              ),
              Expanded(
                child: _buildGenderOption(
                  context: context,
                  gender: 'Female',
                  icon: Icons.female,
                ),
              ),
              Expanded(
                child: _buildGenderOption(
                  context: context,
                  gender: 'Other',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required BuildContext context,
    required String gender,
    required IconData icon,
  }) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.red[900]!.withOpacity(0.3)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.red[900]! : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.red[900] : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              gender,
              style: GoogleFonts.nunito(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
