// lib/presentation/org/pages/invitations_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/org/pending_invites_notifier.dart';
import 'package:sport_tech_app/domain/org/entities/pending_invite.dart';
import 'package:intl/intl.dart';

class InvitationsManagementPage extends ConsumerStatefulWidget {
  const InvitationsManagementPage({super.key});

  @override
  ConsumerState<InvitationsManagementPage> createState() =>
      _InvitationsManagementPageState();
}

class _InvitationsManagementPageState
    extends ConsumerState<InvitationsManagementPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(pendingInvitesNotifierProvider.notifier).loadAllInvites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final invitesState = ref.watch(pendingInvitesNotifierProvider);

    final filteredInvites = _filterInvites(invitesState.invites);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Invitaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(pendingInvitesNotifierProvider.notifier).loadAllInvites();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 8),
                      Text(
                        'Filtros y Búsqueda',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Status filter
                  DropdownButtonFormField<String>(
                    value: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos los estados'),
                      ),
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'accepted',
                        child: Text('Aceptada'),
                      ),
                      DropdownMenuItem(
                        value: 'expired',
                        child: Text('Expirada'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _statusFilter = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Invitations list
          Expanded(
            child: invitesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : invitesState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${invitesState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(pendingInvitesNotifierProvider.notifier)
                                    .loadAllInvites();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredInvites.isEmpty
                        ? const Center(
                            child: Text('No se encontraron invitaciones'),
                          )
                        : Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.mail_outline),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Invitaciones (${filteredInvites.length})',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredInvites.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final invite = filteredInvites[index];
                                      return _InvitationListItem(invite: invite);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to new invitation page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use the admin panel to create new invitations'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Invitación'),
      ),
    );
  }

  List<PendingInvite> _filterInvites(List<PendingInvite> invites) {
    return invites.where((invite) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !invite.email.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Status filter
      if (_statusFilter == 'pending' && (invite.accepted || invite.isExpired)) {
        return false;
      }
      if (_statusFilter == 'accepted' && !invite.accepted) {
        return false;
      }
      if (_statusFilter == 'expired' && !invite.isExpired) {
        return false;
      }

      return true;
    }).toList();
  }
}

class _InvitationListItem extends ConsumerWidget {
  final PendingInvite invite;

  const _InvitationListItem({required this.invite});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(context),
        child: Icon(
          _getStatusIcon(),
          color: Colors.white,
        ),
      ),
      title: Text(invite.email),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rol: ${_formatRole(invite.role)}'),
          if (invite.playerName != null)
            Text('Jugador: ${invite.playerName}'),
          Text(
            'Creada: ${DateFormat('dd/MM/yyyy HH:mm').format(invite.createdAt)}',
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(_getStatusText()),
            backgroundColor: _getStatusColor(context),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'player':
        return 'Jugador';
      case 'coach':
        return 'Entrenador';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  String _getStatusText() {
    if (invite.accepted) {
      return 'Aceptada';
    } else if (invite.isExpired) {
      return 'Expirada';
    } else {
      return 'Pendiente';
    }
  }

  IconData _getStatusIcon() {
    if (invite.accepted) {
      return Icons.check;
    } else if (invite.isExpired) {
      return Icons.close;
    } else {
      return Icons.schedule;
    }
  }

  Color _getStatusColor(BuildContext context) {
    if (invite.accepted) {
      return Colors.green;
    } else if (invite.isExpired) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Invitación'),
        content: Text('¿Estás seguro de que quieres eliminar la invitación para "${invite.email}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(pendingInvitesNotifierProvider.notifier)
                  .deleteInvite(invite.id);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invitación eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
