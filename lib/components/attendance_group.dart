import 'package:flutter/material.dart';

class AttendanceGroup extends StatelessWidget {
  final String name;
  final Map<String, int> status;
  final Function(String, int) onIncrement;
  final Function(String, int) onDecrement;

  const AttendanceGroup({
    super.key,
    required this.name,
    required this.status,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            _buildCounter('male', status['male'] ?? 0),
            const SizedBox(height: 20),
            _buildCounter('female', status['female'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String label, int count) {
    final labelTexts = {
      "male": "Male ಗಂಡು ",
      "female": "Female ಹೆಣ್ಣು ",
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          labelTexts[label]!,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: const Color.fromARGB(255, 236, 88, 88),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () => onDecrement(label.toLowerCase(), count),
              child: const Icon(Icons.remove, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 15),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: const Color.fromARGB(255, 0, 243, 126),
                padding: const EdgeInsets.all(15),
              ),
              onPressed: () => onIncrement(label.toLowerCase(), count),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
