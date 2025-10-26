import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const EmergencyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
      ),
      child: const Icon(Icons.notifications_active, size: 30, color: Colors.white),
    );
  }
}
