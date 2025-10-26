import 'package:flutter/material.dart';

class SettingsResult {
  final bool sound;
  final bool vibration;
  final bool dark;
  final String language;
  SettingsResult({
    required this.sound,
    required this.vibration,
    required this.dark,
    required this.language,
  });
}

Future<SettingsResult?> showSettingsDialog(
  BuildContext context,
  Map<String, String> strings,
  bool isDark,
  String currentLanguage,
  bool sound,
  bool vibration,
) async {
  bool tempSound = sound;
  bool tempVibration = vibration;
  bool tempDark = isDark;
  String tempLanguage = currentLanguage;

  return showDialog<SettingsResult>(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (_, setState) => AlertDialog(
        title: Text(strings['settings']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _switchRow(strings['audio']!, tempSound, (v) => setState(() => tempSound = v)),
            _switchRow(strings['vibration']!, tempVibration, (v) => setState(() => tempVibration = v)),
            _switchRow(strings['darkTheme']!, tempDark, (v) => setState(() => tempDark = v)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings['language']!),
                DropdownButton<String>(
                  value: tempLanguage,
                  onChanged: (val) => setState(() => tempLanguage = val!),
                  items: const [
                    DropdownMenuItem(value: 'it', child: Text('Italiano')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(strings['cancel']!)),
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              SettingsResult(
                sound: tempSound,
                vibration: tempVibration,
                dark: tempDark,
                language: tempLanguage,
              ),
            ),
            child: Text(strings['save']!),
          ),
        ],
      ),
    ),
  );
}

Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Switch(value: value, onChanged: onChanged),
    ],
  );
}
