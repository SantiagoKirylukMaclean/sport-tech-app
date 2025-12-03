import 'package:flutter/material.dart';
import '../../../domain/trainings/entities/training_session.dart';

class TrainingSessionFormDialog extends StatefulWidget {
  final TrainingSession? session;

  const TrainingSessionFormDialog({
    super.key,
    this.session,
  });

  @override
  State<TrainingSessionFormDialog> createState() =>
      _TrainingSessionFormDialogState();
}

class _TrainingSessionFormDialogState extends State<TrainingSessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _sessionDate;
  late TimeOfDay _sessionTime;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    if (widget.session != null) {
      _sessionDate = widget.session!.sessionDate;
      _sessionTime = TimeOfDay.fromDateTime(widget.session!.sessionDate);
    } else {
      _sessionDate = DateTime.now();
      _sessionTime = const TimeOfDay(hour: 18, minute: 0);
    }
    _notesController = TextEditingController(text: widget.session?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _sessionDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _sessionTime,
    );
    if (picked != null) {
      setState(() {
        _sessionTime = picked;
      });
    }
  }

  DateTime _getCombinedDateTime() {
    return DateTime(
      _sessionDate.year,
      _sessionDate.month,
      _sessionDate.day,
      _sessionTime.hour,
      _sessionTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.session != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Training Session' : 'New Training Session'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${_sessionDate.day}/${_sessionDate.month}/${_sessionDate.year}',
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 8),

              // Time picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_sessionTime.format(context)),
                onTap: _selectTime,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add training notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final result = {
                'sessionDate': _getCombinedDateTime(),
                'notes': _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
              };
              Navigator.of(context).pop(result);
            }
          },
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}
