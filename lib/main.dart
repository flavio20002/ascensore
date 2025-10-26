import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const ElevatorApp());
}

class ElevatorApp extends StatefulWidget {
  const ElevatorApp({super.key});

  @override
  State<ElevatorApp> createState() => _ElevatorAppState();
}

class _ElevatorAppState extends State<ElevatorApp> {
  bool _isDarkMode = false;
  String _currentLanguage = 'it';

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void _changeLanguage(String langCode) {
    setState(() {
      _currentLanguage = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascensore a 3 piani',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ElevatorControl(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
        currentLanguage: _currentLanguage,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

// Mappa delle stringhe tradotte (semplice implementazione)
Map<String, Map<String, String>> localizedStrings = {
  'it': {
    'title': 'Comando Ascensore',
    'floor': 'Piano attuale',
    'moving': 'Ascensore in movimento...',
    'emergency': 'EMERGENZA! 🚨',
    'emergencyMessage': 'Campanello di emergenza attivato.',
    'close': 'Chiudi',
    'settings': 'Impostazioni',
    'user': 'Utente',
    'audio': 'Audio',
    'vibration': 'Vibrazione',
    'darkTheme': 'Tema scuro',
    'language': 'Lingua',
    'ipAddress': 'Indirizzo IP',
    'save': 'Salva',
    'cancel': 'Annulla',
  },
  'en': {
    'title': 'Elevator Control',
    'floor': 'Current floor',
    'moving': 'Elevator moving...',
    'emergency': 'EMERGENCY! 🚨',
    'emergencyMessage': 'Emergency bell activated.',
    'close': 'Close',
    'settings': 'Settings',
    'user': 'User',
    'audio': 'Audio',
    'vibration': 'Vibration',
    'darkTheme': 'Dark theme',
    'language': 'Language',
    'ipAddress': 'IP Address',
    'save': 'Save',
    'cancel': 'Cancel',
  },
  'es': {
    'title': 'Control del Ascensor',
    'floor': 'Piso actual',
    'moving': 'Ascensor en movimiento...',
    'emergency': '¡EMERGENCIA! 🚨',
    'emergencyMessage': 'Timbre de emergencia activado.',
    'close': 'Cerrar',
    'settings': 'Configuración',
    'user': 'Usuario',
    'audio': 'Audio',
    'vibration': 'Vibración',
    'darkTheme': 'Tema oscuro',
    'language': 'Idioma',
    'ipAddress': 'Dirección IP',
    'save': 'Guardar',
    'cancel': 'Cancelar',
  },
  'fr': {
    'title': 'Contrôle de l\'Ascenseur',
    'floor': 'Étage actuel',
    'moving': 'Ascenseur en mouvement...',
    'emergency': 'URGENCE! 🚨',
    'emergencyMessage': 'Sonnette d\'urgence activée.',
    'close': 'Fermer',
    'settings': 'Paramètres',
    'user': 'Utilisateur',
    'audio': 'Audio',
    'vibration': 'Vibration',
    'darkTheme': 'Thème sombre',
    'language': 'Langue',
    'ipAddress': 'Adresse IP',
    'save': 'Enregistrer',
    'cancel': 'Annuler',
  },
  'de': {
    'title': 'Aufzugssteuerung',
    'floor': 'Aktueller Stock',
    'moving': 'Aufzug in Bewegung...',
    'emergency': 'NOTFALL! 🚨',
    'emergencyMessage': 'Notrufknopf aktiviert.',
    'close': 'Schließen',
    'settings': 'Einstellungen',
    'user': 'Benutzer',
    'audio': 'Audio',
    'vibration': 'Vibration',
    'darkTheme': 'Dunkles Thema',
    'language': 'Sprache',
    'ipAddress': 'IP-Adresse',
    'save': 'Speichern',
    'cancel': 'Abbrechen',
  },
};

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
  String _ipAddress = '192.168.0.1';

  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  String _doorImage = 'assets/images/frame_3.jpg';

  Timer? _vibrationTimer;
  AudioPlayer? _alarmAudioPlayer; // Player per suono allarme
  final AudioPlayer _audioPlayer = AudioPlayer(); // Per suono piano

  Map<String, String> get strings =>
      localizedStrings[widget.currentLanguage] ?? localizedStrings['it']!;

  Future<void> _vibrateOnce() async {
    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator && _isVibrationEnabled) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _playBellSound() async {
    if (!_isSoundEnabled) return;

    try {
      await _audioPlayer.play(AssetSource('sounds/elevator_bell.mp3'));
    } catch (e) {
      print('Errore riproduzione audio: $e');
    }
  }

  Future<void> _goToFloor(int targetFloor) async {
    if (_isMoving || targetFloor == _currentFloor) return;

    setState(() {
      _isMoving = true;
    });

    // Chiudi porte gradualmente
    setState(() {
      _doorImage = 'assets/images/frame_2.jpg';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _doorImage = 'assets/images/frame_1.jpg';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    int step = targetFloor > _currentFloor ? 1 : -1;
    while (_currentFloor != targetFloor) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _currentFloor += step;
      });
    }

    // Vibrazione e audio all'arrivo
    await _vibrateOnce();
    await _playBellSound();

    // Apri porte gradualmente
    setState(() {
      _doorImage = 'assets/images/frame_2.jpg';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _doorImage = 'assets/images/frame_3.jpg';
      _isMoving = false;
    });
  }

  void _startEmergencyAlarmSound() async {
    if (!_isSoundEnabled) return;

    _alarmAudioPlayer ??= AudioPlayer();
    await _alarmAudioPlayer!.setReleaseMode(ReleaseMode.loop);
    try {
      await _alarmAudioPlayer!.play(AssetSource('sounds/allarm_elevator.mp3'));
    } catch (e) {
      print('Errore riproduzione allarme: $e');
    }
  }

  void _stopEmergencyAlarmSound() async {
    if (_alarmAudioPlayer != null) {
      await _alarmAudioPlayer!.stop();
      await _alarmAudioPlayer!.release();
      _alarmAudioPlayer = null;
    }
  }

  void _emergencyAlarm() {
    if (_isSoundEnabled) {
      print('🔊 Suono emergenza attivato');
    } else {
      print('🔇 Audio disattivato');
    }

    if (_isVibrationEnabled) {
      _vibrationTimer?.cancel();
      _vibrationTimer = Timer.periodic(const Duration(milliseconds: 700), (
        timer,
      ) {
        Vibration.vibrate(duration: 500);
      });
    }

    _startEmergencyAlarmSound();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings['emergency']!),
        content: Text(strings['emergencyMessage']!),
        actions: [
          TextButton(
            onPressed: () {
              _vibrationTimer?.cancel();
              _vibrationTimer = null;
              _stopEmergencyAlarmSound();
              Navigator.of(context).pop();
            },
            child: Text(strings['close']!),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    String tempLanguage = widget.currentLanguage;
    bool tempSound = _isSoundEnabled;
    bool tempVibration = _isVibrationEnabled;
    bool tempDark = widget.isDarkMode;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: Text(strings['settings']!),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings['audio']!),
                      Switch(
                        value: tempSound,
                        onChanged: (val) {
                          setLocalState(() => tempSound = val);
                        },
                      ),
                    ],
                  ),
                  // Vibration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings['vibration']!),
                      Switch(
                        value: tempVibration,
                        onChanged: (val) {
                          setLocalState(() => tempVibration = val);
                        },
                      ),
                    ],
                  ),
                  // Dark theme
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings['darkTheme']!),
                      Switch(
                        value: tempDark,
                        onChanged: (val) {
                          setLocalState(() => tempDark = val);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Language dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(strings['language']!),
                      DropdownButton<String>(
                        value: tempLanguage,
                        onChanged: (val) {
                          if (val != null)
                            setLocalState(() => tempLanguage = val);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'it',
                            child: const Text('Italiano'),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: const Text('English'),
                          ),
                          DropdownMenuItem(
                            value: 'es',
                            child: const Text('Español'),
                          ),
                          DropdownMenuItem(
                            value: 'fr',
                            child: const Text('Français'),
                          ),
                          DropdownMenuItem(
                            value: 'de',
                            child: const Text('Deutsch'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(strings['cancel']!),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isSoundEnabled = tempSound;
                    _isVibrationEnabled = tempVibration;
                    widget.onThemeChanged(tempDark);
                    widget.onLanguageChanged(tempLanguage);
                  });
                  Navigator.of(context).pop();
                },
                child: Text(strings['save']!),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openUserSettings() {
    TextEditingController ipController = TextEditingController(
      text: _ipAddress,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(strings['user']!),
        content: TextField(
          controller: ipController,
          decoration: InputDecoration(labelText: strings['ipAddress']!),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _ipAddress = ipController.text;
              });
              Navigator.of(context).pop();
            },
            child: Text(strings['save']!),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings['cancel']!),
          ),
        ],
      ),
    );
  }

  Widget _floorButton(int floor) {
    final bool isSelected = _currentFloor == floor;
    final bool isDark = widget.isDarkMode;

    Color borderColor;
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;

    if (isSelected) {
      borderColor = isDark ? Colors.amber.shade700 : Colors.green;
    } else {
      borderColor = Colors.transparent;
    }

    return OutlinedButton(
      onPressed: _isMoving ? null : () => _goToFloor(floor),
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: borderColor, width: 3),
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.all(24),
      ),
      child: Text('$floor', style: TextStyle(fontSize: 20, color: textColor)),
    );
  }

  Widget _emergencyButton() {
    return ElevatedButton(
      onPressed: _emergencyAlarm,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: Colors.red,
      ),
      child: const Icon(
        Icons.notifications_active,
        size: 30,
        color: Colors.white,
      ),
    );
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

    Widget elevatorInfo = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${strings['floor']}: $_currentFloor',
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Image.asset(
            _doorImage,
            key: ValueKey<String>(_doorImage),
            width: 250,
          ),
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

    Widget floorsRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_floorButton(1), _floorButton(2), _floorButton(3)],
    );

    Widget emergencyRow = Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(child: _emergencyButton()),
    );

    Widget buttonsColumn = Column(
      mainAxisSize: MainAxisSize.min,
      children: [floorsRow, emergencyRow],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['title']!),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
          tooltip: strings['settings'],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _openUserSettings,
            tooltip: strings['user'],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: isPortrait
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  elevatorInfo,
                  const SizedBox(height: 20),
                  buttonsColumn,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: elevatorInfo),
                  const SizedBox(width: 30),
                  Expanded(child: buttonsColumn),
                ],
              ),
      ),
    );
  }
}
