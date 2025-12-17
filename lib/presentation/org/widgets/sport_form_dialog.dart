// lib/presentation/org/widgets/sport_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class SportFormDialog extends StatefulWidget {
  final String? initialName;
  final Future<void> Function(String name) onSubmit;

  const SportFormDialog({
    required this.onSubmit,
    super.key,
    this.initialName,
  });

  @override
  State<SportFormDialog> createState() => _SportFormDialogState();
}

class _SportFormDialogState extends State<SportFormDialog> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editSport : l10n.createSport),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.sportName,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseEnterSportName;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? l10n.update : l10n.create),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(_nameController.text.trim());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
