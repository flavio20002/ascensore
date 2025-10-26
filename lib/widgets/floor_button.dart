import 'package:flutter/material.dart';

class FloorButton extends StatelessWidget {
  final int floor;
  final int currentFloor;
  final bool isMoving;
  final bool isDarkMode;
  final VoidCallback onPressed;

  const FloorButton({
    super.key,
    required this.floor,
    required this.currentFloor,
    required this.isMoving,
    required this.isDarkMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentFloor == floor;
    final borderColor = isSelected
        ? (isDarkMode ? Colors.amber.shade700 : Colors.green)
        : Colors.transparent;

    return OutlinedButton(
      onPressed: isMoving ? null : onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: borderColor, width: 3),
        padding: const EdgeInsets.all(24),
        backgroundColor: Colors.white,
      ),
      child: Text(
        '$floor',
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
    );
  }
}
