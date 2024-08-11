import 'package:flutter/material.dart';

class AttendanceOptions extends StatelessWidget {
  final String name;
  final String currentStatus;
  final Function(String, String) onStatusChanged;

  const AttendanceOptions({
    super.key,
    required this.name,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOption('Present', Colors.green),
        _buildOption('Absent', Colors.red),
        _buildOption('Half Day', Colors.orange),
      ],
    );
  }

  Widget _buildOption(String status, Color color) {
    return GestureDetector(
      onTap: () => onStatusChanged(name, status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              currentStatus == status ? color.withOpacity(0.7) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          status,
          style:
              TextStyle(color: currentStatus == status ? Colors.white : color),
        ),
      ),
    );
  }
}
