import 'package:flutter/material.dart';

Future<String?> showUserSettingsDialog(
  BuildContext context,
  Map<String, String> strings,
  String currentIp,
) {
  final controller = TextEditingController(text: currentIp);
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(strings['user']!),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: strings['ipAddress']!),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(strings['cancel']!)),
        TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text(strings['save']!)),
      ],
    ),
  );
}
