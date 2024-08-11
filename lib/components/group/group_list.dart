import 'package:flutter/material.dart';

class GroupList extends StatelessWidget {
  final String label;

  const GroupList({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.blueAccent,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (String value) {
            if (value == 'delete') {
              // Handle delete option
            } else if (value == 'edit') {
              // Handle edit option
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Delete'),
            ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}
