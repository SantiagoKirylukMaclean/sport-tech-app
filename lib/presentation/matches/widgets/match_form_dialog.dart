// lib/presentation/matches/widgets/match_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';

class MatchFormDialog extends ConsumerStatefulWidget {
  final String teamId;
  final Match? matchToEdit;

  const MatchFormDialog({
    required this.teamId,
    this.matchToEdit,
    super.key,
  });

  @override
  ConsumerState<MatchFormDialog> createState() => _MatchFormDialogState();
}

class _MatchFormDialogState extends ConsumerState<MatchFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _opponentController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final match = widget.matchToEdit;
    _opponentController = TextEditingController(text: match?.opponent ?? '');
    _locationController = TextEditingController(text: match?.location ?? '');
    _notesController = TextEditingController(text: match?.notes ?? '');
    _selectedDate = match?.matchDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final notifier =
        ref.read(matchesNotifierProvider(widget.teamId).notifier);

    if (widget.matchToEdit != null) {
      await notifier.updateMatch(
        id: widget.matchToEdit!.id,
        opponent: _opponentController.text.trim(),
        matchDate: _selectedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    } else {
      await notifier.createMatch(
        opponent: _opponentController.text.trim(),
        matchDate: _selectedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.matchToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Match' : 'New Match'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _opponentController,
                  decoration: const InputDecoration(
                    labelText: 'Opponent',
                    hintText: 'Enter opponent name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Opponent name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Match Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    hintText: 'Enter match location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Enter any notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
