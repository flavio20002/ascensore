import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../localization/localized_strings.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/user_settings_dialog.dart';
import '../widgets/floor_button.dart';
import '../widgets/emergency_button.dart';

class ElevatorControl extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const ElevatorControl({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<ElevatorControl> createState() => _ElevatorControlState();
}

class _ElevatorControlState extends State<ElevatorControl> {
  int _currentFloor = 1;
  bool _isMoving = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;
  String _ipAddress = '192.168.0.1';
  String _doorImage = 'assets/images/frame_3.jpg';

  Timer? _vibrationTimer;
  AudioPlayer? _alarmAudioPlayer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Map<String, String> get strings =>
      localizedStrings[widget.currentLanguage] ?? localizedStrings['it']!;

  Future<void> _goToFloor(int floor) async {
    if (_isMoving || floor == _currentFloor) return;

    setState(() => _isMoving = true);

    // chiusura porte
    setState(() => _doorImage = 'assets/images/frame_2.jpg');
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _doorImage = 'assets/images/frame_1.jpg');
    await Future.delayed(const Duration(milliseconds: 700));

    int step = floor > _currentFloor ? 1 : -1;
    while (_currentFloor != floor) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _currentFloor += step);
    }

    if (_isVibrationEnabled && !Platform.isWindows) Vibration.vibrate(duration: 500);
    if (_isSoundEnabled) await _audioPlayer.play(AssetSource('sounds/elevator_bell.mp3'));

    // apertura porte
    setState(() => _doorImage = 'assets/images/frame_2.jpg');
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _doorImage = 'assets/images/frame_3.jpg';
      _isMoving = false;
    });
  }

  void _emergencyAlarm() {
    if (_isVibrationEnabled  && !Platform.isWindows) {
      _vibrationTimer?.cancel();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
        Vibration.vibrate(duration: 500);
      });
    }

    if (_isSoundEnabled) {
      _alarmAudioPlayer ??= AudioPlayer();
      _alarmAudioPlayer!
        ..setReleaseMode(ReleaseMode.loop)
        ..play(AssetSource('sounds/allarm_elevator.mp3'));
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings['emergency']!),
        content: Text(strings['emergencyMessage']!),
        actions: [
          TextButton(
            onPressed: () {
              _vibrationTimer?.cancel();
              _alarmAudioPlayer?.stop();
              _alarmAudioPlayer = null;
              Navigator.pop(context);
            },
            child: Text(strings['close']!),
          )
        ],
      ),
    );
  }

  void _openSettings() async {
    final result = await showSettingsDialog(
      context,
      strings,
      widget.isDarkMode,
      widget.currentLanguage,
      _isSoundEnabled,
      _isVibrationEnabled,
    );

    if (result != null) {
      setState(() {
        _isSoundEnabled = result.sound;
        _isVibrationEnabled = result.vibration;
        widget.onThemeChanged(result.dark);
        widget.onLanguageChanged(result.language);
      });
    }
  }

  void _openUserSettings() async {
    final newIp = await showUserSettingsDialog(context, strings, _ipAddress);
    if (newIp != null) setState(() => _ipAddress = newIp);
  }

  @override
  void dispose() {
    _vibrationTimer?.cancel();
    _alarmAudioPlayer?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;

    Widget info = Column(
      children: [
        Text('${strings['floor']}: $_currentFloor', style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(_doorImage, key: ValueKey(_doorImage), width: 250),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 22,
          child: Center(
            child: _isMoving
                ? Text(strings['moving']!, style: const TextStyle(fontSize: 18))
                : null,
          ),
        ),
      ],
    );

    Widget controls = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 2, 3]
              .map((f) => FloorButton(
                    floor: f,
                    currentFloor: _currentFloor,
                    isMoving: _isMoving,
                    isDarkMode: widget.isDarkMode,
                    onPressed: () => _goToFloor(f),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        EmergencyButton(onPressed: _emergencyAlarm),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['title']!),
        leading: IconButton(icon: const Icon(Icons.settings), onPressed: _openSettings),
        actions: [
          IconButton(icon: const Icon(Icons.person), onPressed: _openUserSettings),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isPortrait
            ? Column(children: [info, const SizedBox(height: 20), controls])
            : Row(children: [
                Expanded(child: info),
                const SizedBox(width: 30),
                Expanded(child: controls),
              ]),
      ),
    );
  }
}
