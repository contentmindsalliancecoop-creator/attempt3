// settings_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Importamos para tener acceso a la clase SettingsData

class SettingsScreen extends StatefulWidget {
  final SettingsData currentSettings;
  final Function(SettingsData) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsData _tempSettings;

  @override
  void initState() {
    super.initState();
    _tempSettings = widget.currentSettings.copyWith();
  }

  // Este método ahora contiene la lógica correcta para reiniciar el progreso
  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Estás seguro de que quieres reiniciar todo tu progreso? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reiniciar'),
            // --- AQUÍ VA LA LÓGICA QUE ESTABA FLOTANDO ---
            onPressed: () async { 
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('highScore_basic');
              await prefs.remove('highScore_intermediate');
              await prefs.remove('highScore_advanced');

              // Es buena práctica verificar el contexto antes de usarlo en un async
              if (!mounted) return;

              Navigator.of(ctx).pop(); // Cierra el diálogo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progreso reiniciado')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          _SettingsSection(
            title: 'Apariencia',
            tiles: [
              ListTile(
                leading: const Icon(Icons.brightness_6_rounded),
                title: const Text('Tema de la aplicación'),
                subtitle: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
                    ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro')),
                  ],
                  selected: {_tempSettings.themeMode},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _tempSettings.themeMode = newSelection.first;
                      widget.onSettingsChanged(_tempSettings);
                    });
                  },
                ),
              ),
            ],
          ),
          _SettingsSection(
            title: 'Juego',
            tiles: [
              SwitchListTile(
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text('Efectos de sonido'),
                value: _tempSettings.soundEffectsEnabled,
                onChanged: (newValue) {
                  setState(() {
                    _tempSettings.soundEffectsEnabled = newValue;
                    widget.onSettingsChanged(_tempSettings);
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration_rounded),
                title: const Text('Vibración al responder'),
                value: _tempSettings.vibrationsEnabled,
                onChanged: (newValue) {
                  setState(() {
                    _tempSettings.vibrationsEnabled = newValue;
                    widget.onSettingsChanged(_tempSettings);
                  });
                },
              ),
            ],
          ),
          _SettingsSection(
            title: 'Datos',
            tiles: [
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                title: const Text('Reiniciar progreso', style: TextStyle(color: Colors.redAccent)),
                onTap: _showResetConfirmationDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para crear secciones de ajustes (sin cambios)
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Divider(),
          ...tiles,
        ],
      ),
    );
  }
}