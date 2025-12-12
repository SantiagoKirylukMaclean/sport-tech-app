// lib/presentation/org/widgets/club_color_picker.dart

import 'package:flutter/material.dart';

/// Color picker widget for club theme colors
///
/// Displays a preview of the selected color and opens a dialog
/// with a Material Design 3 color palette when tapped.
class ClubColorPicker extends StatelessWidget {
  final String label;
  final Color? color;
  final ValueChanged<Color?> onColorChanged;

  const ClubColorPicker({
    required this.label,
    required this.color,
    required this.onColorChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Color preview box
            InkWell(
              onTap: () => _showColorPicker(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color ?? Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: color == null
                    ? const Icon(Icons.palette_outlined, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    color != null ? _colorToHex(color!) : 'No seleccionado',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextButton.icon(
                    onPressed: () => _showColorPicker(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      color == null ? 'Seleccionar Color' : 'Cambiar Color',
                    ),
                  ),
                ],
              ),
            ),
            if (color != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onColorChanged(null),
                tooltip: 'Limpiar color',
              ),
          ],
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: color,
        onColorSelected: onColorChanged,
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

/// Simple color picker dialog with Material Design 3 color palette
class _ColorPickerDialog extends StatefulWidget {
  final Color? initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color selectedColor;

  // Material Design 3 color palette
  static const List<Color> colors = [
    // Reds
    Color(0xFFB71C1C),
    Color(0xFFD32F2F),
    Color(0xFFE53935),
    Color(0xFFEF5350),
    // Pinks
    Color(0xFFAD1457),
    Color(0xFFC2185B),
    Color(0xFFE91E63),
    Color(0xFFEC407A),
    // Purples
    Color(0xFF6A1B9A),
    Color(0xFF7B1FA2),
    Color(0xFF8E24AA),
    Color(0xFFAB47BC),
    // Deep Purples
    Color(0xFF4527A0),
    Color(0xFF512DA8),
    Color(0xFF5E35B1),
    Color(0xFF7E57C2),
    // Indigos
    Color(0xFF283593),
    Color(0xFF303F9F),
    Color(0xFF3F51B5),
    Color(0xFF5C6BC0),
    // Blues
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFF2196F3),
    // Light Blues
    Color(0xFF01579B),
    Color(0xFF0277BD),
    Color(0xFF0288D1),
    Color(0xFF039BE5),
    // Cyans
    Color(0xFF006064),
    Color(0xFF00838F),
    Color(0xFF0097A7),
    Color(0xFF00ACC1),
    // Teals
    Color(0xFF004D40),
    Color(0xFF00695C),
    Color(0xFF00796B),
    Color(0xFF00897B),
    // Greens
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF388E3C),
    Color(0xFF4CAF50),
    // Light Greens
    Color(0xFF33691E),
    Color(0xFF558B2F),
    Color(0xFF689F38),
    Color(0xFF7CB342),
    // Limes
    Color(0xFF827717),
    Color(0xFF9E9D24),
    Color(0xFFAFB42B),
    Color(0xFFC0CA33),
    // Yellows
    Color(0xFFF57F17),
    Color(0xFFF9A825),
    Color(0xFFFBC02D),
    Color(0xFFFDD835),
    // Ambers
    Color(0xFFFF6F00),
    Color(0xFFFF8F00),
    Color(0xFFFFA000),
    Color(0xFFFFB300),
    // Oranges
    Color(0xFFE65100),
    Color(0xFFEF6C00),
    Color(0xFFF57C00),
    Color(0xFFFF9800),
    // Deep Oranges
    Color(0xFFBF360C),
    Color(0xFFD84315),
    Color(0xFFE64A19),
    Color(0xFFFF5722),
    // Browns
    Color(0xFF3E2723),
    Color(0xFF4E342E),
    Color(0xFF5D4037),
    Color(0xFF6D4C41),
    // Greys
    Color(0xFF212121),
    Color(0xFF424242),
    Color(0xFF616161),
    Color(0xFF757575),
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor ?? colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Color'),
      content: SizedBox(
        width: 300,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final color = colors[index];
            final isSelected = color.toARGB32() == selectedColor.toARGB32();

            return InkWell(
              onTap: () => setState(() => selectedColor = color),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(selectedColor);
            Navigator.pop(context);
          },
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}
