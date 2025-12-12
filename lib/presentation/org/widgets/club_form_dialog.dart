// lib/presentation/org/widgets/club_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:sport_tech_app/config/theme/color_scheme_generator.dart';
import 'package:sport_tech_app/presentation/org/widgets/club_color_picker.dart';

class ClubFormDialog extends StatefulWidget {
  final String? initialName;
  final Color? initialPrimaryColor;
  final Color? initialSecondaryColor;
  final Color? initialTertiaryColor;
  final Future<void> Function(
    String name, {
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
  }) onSubmit;

  const ClubFormDialog({
    required this.onSubmit,
    super.key,
    this.initialName,
    this.initialPrimaryColor,
    this.initialSecondaryColor,
    this.initialTertiaryColor,
  });

  @override
  State<ClubFormDialog> createState() => _ClubFormDialogState();
}

class _ClubFormDialogState extends State<ClubFormDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  Color? _primaryColor;
  Color? _secondaryColor;
  Color? _tertiaryColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _primaryColor = widget.initialPrimaryColor;
    _secondaryColor = widget.initialSecondaryColor;
    _tertiaryColor = widget.initialTertiaryColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Club' : 'Crear Club'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Club',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa un nombre para el club';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Color pickers section
                Text(
                  'Colores del Tema (Opcional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona hasta 3 colores para el tema de tu club. Déjalos en blanco para usar los colores predeterminados.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),

                ClubColorPicker(
                  label: 'Color Primario',
                  color: _primaryColor,
                  onColorChanged: (color) =>
                      setState(() => _primaryColor = color),
                ),
                const SizedBox(height: 16),

                ClubColorPicker(
                  label: 'Color Secundario',
                  color: _secondaryColor,
                  onColorChanged: (color) =>
                      setState(() => _secondaryColor = color),
                ),
                const SizedBox(height: 16),

                ClubColorPicker(
                  label: 'Color Terciario',
                  color: _tertiaryColor,
                  onColorChanged: (color) =>
                      setState(() => _tertiaryColor = color),
                ),
                const SizedBox(height: 24),

                // Theme preview
                if (_primaryColor != null ||
                    _secondaryColor != null ||
                    _tertiaryColor != null)
                  _ThemePreview(
                    primaryColor: _primaryColor,
                    secondaryColor: _secondaryColor,
                    tertiaryColor: _tertiaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Actualizar' : 'Crear'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        _nameController.text.trim(),
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        tertiaryColor: _tertiaryColor,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Live preview of the theme colors
class _ThemePreview extends StatelessWidget {
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;

  const _ThemePreview({
    this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Generate preview color scheme
    final colorScheme = ColorSchemeGenerator.generateLightScheme(
      primarySeed: primaryColor ?? ColorSchemeGenerator.defaultPrimary,
      secondarySeed: secondaryColor ?? ColorSchemeGenerator.defaultSecondary,
      tertiarySeed: tertiaryColor ?? ColorSchemeGenerator.defaultTertiary,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vista Previa del Tema',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ColorSwatch(
                  'Primario',
                  colorScheme.primary,
                  colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ColorSwatch(
                  'Secundario',
                  colorScheme.secondary,
                  colorScheme.onSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ColorSwatch(
                  'Terciario',
                  colorScheme.tertiary,
                  colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final Color onColor;

  const _ColorSwatch(this.label, this.color, this.onColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: onColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
