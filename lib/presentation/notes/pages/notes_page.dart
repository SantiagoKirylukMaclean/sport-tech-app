// lib/presentation/notes/pages/notes_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/notes/notes_notifier.dart';
import 'package:sport_tech_app/application/notes/notes_state.dart';
import 'package:sport_tech_app/domain/notes/entities/note.dart';
import 'package:sport_tech_app/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  @override
  void initState() {
    super.initState();
    // Load notes when page is initialized
    Future.microtask(() => ref.read(notesNotifierProvider.notifier).loadNotes());
  }

  void _showNoteDialog({Note? note}) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: note?.content ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? l10n.addNote : l10n.editNote),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 5,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.noteContent,
              hintText: l10n.enterNoteContent,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.noteContentRequired;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                if (note == null) {
                  ref
                      .read(notesNotifierProvider.notifier)
                      .createNote(controller.text);
                } else {
                  ref
                      .read(notesNotifierProvider.notifier)
                      .updateNote(note.id, controller.text);
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      note == null ? l10n.noteCreated : l10n.noteUpdated,
                    ),
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Note note) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteNote),
        content: Text(l10n.confirmDeleteNote),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notesNotifierProvider.notifier).deleteNote(note.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.noteDeleted)),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesState = ref.watch(notesNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notesNotifierProvider.notifier).loadNotes();
        },
        child: _buildBody(notesState, l10n, theme),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(NotesState state, AppLocalizations l10n, ThemeData theme) {
    return switch (state) {
      NotesStateInitial() => Center(child: Text(l10n.loading)),
      NotesStateLoading() => const Center(child: CircularProgressIndicator()),
      NotesStateError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(notesNotifierProvider.notifier).loadNotes(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.loading),
              ),
            ],
          ),
        ),
      NotesStateLoaded(:final notes) => notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noNotes,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) => _buildNoteCard(notes[index], l10n),
            ),
    };
  }

  Widget _buildNoteCard(Note note, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showNoteDialog(note: note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(note.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showNoteDialog(note: note),
                    tooltip: l10n.edit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(note),
                    tooltip: l10n.delete,
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                note.content,
                style: theme.textTheme.bodyLarge,
              ),
              if (note.updatedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${l10n.update}: ${dateFormat.format(note.updatedAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
