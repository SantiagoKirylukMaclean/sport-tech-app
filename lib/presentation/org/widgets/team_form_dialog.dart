// lib/presentation/org/widgets/team_form_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamFormDialog extends StatefulWidget {
  final String? initialName;
  final String? initialStandingsUrl;
  final String? initialResultsUrl;
  final String? initialCalendarUrl;
  final Future<void> Function({
    required String name,
    String? standingsUrl,
    String? resultsUrl,
    String? calendarUrl,
  }) onSubmit;

  const TeamFormDialog({
    required this.onSubmit,
    super.key,
    this.initialName,
    this.initialStandingsUrl,
    this.initialResultsUrl,
    this.initialCalendarUrl,
  });

  @override
  State<TeamFormDialog> createState() => _TeamFormDialogState();
}

class _TeamFormDialogState extends State<TeamFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _standingsUrlController;
  late final TextEditingController _resultsUrlController;
  late final TextEditingController _calendarUrlController;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _standingsUrlController = TextEditingController(text: widget.initialStandingsUrl);
    _resultsUrlController = TextEditingController(text: widget.initialResultsUrl);
    _calendarUrlController = TextEditingController(text: widget.initialCalendarUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _standingsUrlController.dispose();
    _resultsUrlController.dispose();
    _calendarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Equipo' : 'Crear Equipo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Equipo',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                validator: (value) {
                  final l10n = AppLocalizations.of(context)!;
                  if (value == null || value.trim().isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'URLs del Campeonato',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _standingsUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Clasificación',
                  hintText: 'https://ejemplo.com/clasificacion',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.leaderboard),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  final l10n = AppLocalizations.of(context)!;
                  if (value != null && value.trim().isNotEmpty) {
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return l10n.urlMustStartWithHttp;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resultsUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Resultados',
                  hintText: 'https://ejemplo.com/resultados',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_score),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  final l10n = AppLocalizations.of(context)!;
                  if (value != null && value.trim().isNotEmpty) {
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return l10n.urlMustStartWithHttp;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calendarUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Calendario',
                  hintText: 'https://ejemplo.com/calendario',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  final l10n = AppLocalizations.of(context)!;
                  if (value != null && value.trim().isNotEmpty) {
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return l10n.urlMustStartWithHttp;
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
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
        name: _nameController.text.trim(),
        standingsUrl: _standingsUrlController.text.trim().isEmpty
            ? null
            : _standingsUrlController.text.trim(),
        resultsUrl: _resultsUrlController.text.trim().isEmpty
            ? null
            : _resultsUrlController.text.trim(),
        calendarUrl: _calendarUrlController.text.trim().isEmpty
            ? null
            : _calendarUrlController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
