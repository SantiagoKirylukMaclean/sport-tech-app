// lib/presentation/org/widgets/player_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sport_tech_app/domain/org/entities/position.dart';

class PlayerFormDialog extends StatefulWidget {
  final String? initialFullName;
  final int? initialJerseyNumber;
  final String? initialPositionId;
  final List<Position> positions;
  final Future<void> Function(
      String fullName, int? jerseyNumber, String? positionId) onSubmit;

  const PlayerFormDialog({
    required this.positions,
    required this.onSubmit,
    super.key,
    this.initialFullName,
    this.initialJerseyNumber,
    this.initialPositionId,
  });

  @override
  State<PlayerFormDialog> createState() => _PlayerFormDialogState();
}

class _PlayerFormDialogState extends State<PlayerFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _jerseyController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  String? _selectedPositionId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialFullName);
    _jerseyController = TextEditingController(
      text: widget.initialJerseyNumber?.toString(),
    );
    _selectedPositionId = widget.initialPositionId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialFullName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Player' : 'Add Player'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jerseyController,
                decoration: const InputDecoration(
                  labelText: 'Jersey Number (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Position (Optional)',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedPositionId,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...widget.positions.map(
                    (position) => DropdownMenuItem(
                      value: position.id,
                      child:
                          Text('${position.name} (${position.abbreviation})'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedPositionId = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final jerseyNumber = _jerseyController.text.trim().isEmpty
          ? null
          : int.parse(_jerseyController.text.trim());

      await widget.onSubmit(
        _nameController.text.trim(),
        jerseyNumber,
        _selectedPositionId,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
