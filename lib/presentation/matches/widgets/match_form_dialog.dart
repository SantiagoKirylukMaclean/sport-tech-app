// lib/presentation/matches/widgets/match_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/matches/matches_notifier.dart';
import 'package:sport_tech_app/domain/matches/entities/match.dart';
import 'package:sport_tech_app/domain/org/entities/team.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';

class MatchFormDialog extends ConsumerStatefulWidget {
  final Team team;
  final Match? matchToEdit;

  const MatchFormDialog({
    required this.team,
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
  late final TextEditingController _numberOfPeriodsController;
  late final TextEditingController _periodDurationController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final match = widget.matchToEdit;
    _opponentController = TextEditingController(text: match?.opponent ?? '');
    _locationController = TextEditingController(text: match?.location ?? '');
    _notesController = TextEditingController(text: match?.notes ?? '');
    _numberOfPeriodsController =
        TextEditingController(text: match?.numberOfPeriods?.toString() ?? '4');
    _periodDurationController =
        TextEditingController(text: match?.periodDuration?.toString() ?? '10');
    _selectedDate = match?.matchDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _opponentController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _numberOfPeriodsController.dispose();
    _periodDurationController.dispose();
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

    setState(() => _isLoading = true);

    final notifier = ref.read(matchesNotifierProvider(widget.team.id).notifier);

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
        numberOfPeriods: int.tryParse(_numberOfPeriodsController.text),
        periodDuration: int.tryParse(_periodDurationController.text),
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
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.matchToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? l10n.editMatch : l10n.newMatch),
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
                  decoration: InputDecoration(
                    labelText: l10n.opponent,
                    hintText: l10n.enterOpponentName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.opponentNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.matchDate,
                      border: const OutlineInputBorder(),
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
                  decoration: InputDecoration(
                    labelText: l10n.locationOptional,
                    hintText: l10n.enterMatchLocation,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    hintText: l10n.enterAnyNotes,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                if (widget.team.sportName?.toLowerCase().contains('bask') ==
                        true ||
                    widget.team.sportName?.toLowerCase().contains('básq') ==
                        true) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numberOfPeriodsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.numberOfPeriods,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _periodDurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.periodDuration,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (widget.team.sportName?.toLowerCase().contains('bask') ==
                        true ||
                    widget.team.sportName?.toLowerCase().contains('básq') ==
                        true) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numberOfPeriodsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.numberOfPeriods,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _periodDurationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.periodDuration,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
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
}
