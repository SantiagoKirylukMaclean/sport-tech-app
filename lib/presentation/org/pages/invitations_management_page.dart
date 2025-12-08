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
                    initialValue: _statusFilter,
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
      if (_statusFilter == 'pending' && invite.status != 'pending') {
        return false;
      }
      if (_statusFilter == 'accepted' && invite.status != 'accepted') {
        return false;
      }
      if (_statusFilter == 'expired' && invite.status != 'canceled') {
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
          if (invite.displayName != null)
            Text('Nombre: ${invite.displayName}'),
          if (invite.playerId != null)
            Text('Player ID: ${invite.playerId}'),
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
          // Only show resend options for pending invites
          if (invite.isPending)
            PopupMenuButton<String>(
              icon: const Icon(Icons.send, color: Colors.blue),
              tooltip: 'Opciones de invitación',
              onSelected: (value) {
                if (value == 'email') {
                  _showResendConfirmation(context, ref, sendEmail: true);
                } else if (value == 'link') {
                  _showResendConfirmation(context, ref, sendEmail: false);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'email',
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 20),
                      SizedBox(width: 8),
                      Text('Enviar Email'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'link',
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 20),
                      SizedBox(width: 8),
                      Text('Obtener Enlace'),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar invitación',
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
    switch (invite.status) {
      case 'accepted':
        return 'Aceptada';
      case 'canceled':
        return 'Cancelada';
      case 'pending':
      default:
        return 'Pendiente';
    }
  }

  IconData _getStatusIcon() {
    switch (invite.status) {
      case 'accepted':
        return Icons.check;
      case 'canceled':
        return Icons.close;
      case 'pending':
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (invite.status) {
      case 'accepted':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  void _showResendConfirmation(
    BuildContext context,
    WidgetRef ref, {
    required bool sendEmail,
  }) {
    final title = sendEmail ? 'Enviar Email de Invitación' : 'Generar Enlace de Invitación';
    final message = sendEmail
        ? '¿Deseas enviar un email de invitación a "${invite.email}"?\n\nEl usuario recibirá un correo con instrucciones.'
        : '¿Deseas generar un enlace de invitación para "${invite.email}"?\n\nPodrás compartir el enlace manualmente por WhatsApp u otro medio.';
    final buttonText = sendEmail ? 'Enviar Email' : 'Generar Enlace';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final result = await ref
                  .read(pendingInvitesNotifierProvider.notifier)
                  .resendInvite(invite.id, sendEmail: sendEmail);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (result != null) {
                  // Show success dialog with result
                  _showSignupUrlDialog(context, result);
                } else {
                  final error = ref.read(pendingInvitesNotifierProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${error ?? "Desconocido"}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _showSignupUrlDialog(BuildContext context, String message) {
    // Check if it's an email sent confirmation or a URL to share
    final isEmailSent = message.contains('Email sent') ||
                        message.contains('exitosamente') ||
                        !message.startsWith('http');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEmailSent ? '✅ Invitación Enviada' : 'Enlace de Invitación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEmailSent) ...[
              const Text('Se ha enviado un email de invitación a:'),
              const SizedBox(height: 8),
              Text(
                invite.email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'El usuario recibirá un correo con instrucciones para establecer su contraseña y acceder a la aplicación.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              const Text(
                '💡 Tip: Pídele que revise su carpeta de spam si no lo encuentra.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ] else ...[
              Text('Comparte este enlace con ${invite.email}:'),
              const SizedBox(height: 16),
              SelectableText(
                message,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'El usuario debe crear su cuenta usando este enlace y el email de la invitación.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          if (!isEmailSent)
            TextButton(
              onPressed: () {
                // Copy to clipboard functionality would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidad de copiar pendiente de implementar'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Copiar'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
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
