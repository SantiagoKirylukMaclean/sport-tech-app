// lib/presentation/org/pages/users_management_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_tech_app/application/profiles/profiles_notifier.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';
import 'package:sport_tech_app/domain/profiles/entities/user_profile.dart';
import 'package:intl/intl.dart';

class UsersManagementPage extends ConsumerStatefulWidget {
  const UsersManagementPage({super.key});

  @override
  ConsumerState<UsersManagementPage> createState() =>
      _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage> {
  String _searchQuery = '';
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profilesNotifierProvider.notifier).loadAllProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profilesState = ref.watch(profilesNotifierProvider);

    final filteredProfiles = _filterProfiles(profilesState.profiles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(profilesNotifierProvider.notifier).loadAllProfiles();
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
                      labelText: 'Buscar por email o nombre',
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
                  // Role filter
                  DropdownButtonFormField<String>(
                    value: _roleFilter,
                    decoration: const InputDecoration(
                      labelText: 'Rol',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Todos los roles'),
                      ),
                      DropdownMenuItem(
                        value: 'player',
                        child: Text('Jugador'),
                      ),
                      DropdownMenuItem(
                        value: 'coach',
                        child: Text('Entrenador'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(
                        value: 'super_admin',
                        child: Text('Super Admin'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _roleFilter = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Users list
          Expanded(
            child: profilesState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : profilesState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error: ${profilesState.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(profilesNotifierProvider.notifier)
                                    .loadAllProfiles();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredProfiles.isEmpty
                        ? const Center(
                            child: Text('No se encontraron usuarios'),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Nombre')),
                                DataColumn(label: Text('Rol')),
                                DataColumn(label: Text('Fecha de Registro')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: filteredProfiles.map((profile) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(profile.userId)),
                                    DataCell(Text(profile.displayName)),
                                    DataCell(_buildRoleChip(context, profile.role)),
                                    DataCell(
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(profile.createdAt),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showEditDialog(context, profile),
                                            tooltip: 'Editar',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.lock_reset, size: 20),
                                            onPressed: () => _showResetPasswordDialog(context, profile),
                                            tooltip: 'Reset Password',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  List<UserProfile> _filterProfiles(List<UserProfile> profiles) {
    return profiles.where((profile) {
      // Search filter
      if (_searchQuery.isNotEmpty &&
          !profile.userId.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !profile.displayName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Role filter
      if (_roleFilter != 'all' && profile.role.value != _roleFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildRoleChip(BuildContext context, UserRole role) {
    Color color;
    String label;

    switch (role) {
      case UserRole.player:
        color = Colors.blue;
        label = 'Player';
        break;
      case UserRole.coach:
        color = Colors.green;
        label = 'Coach';
        break;
      case UserRole.admin:
        color = Colors.orange;
        label = 'Admin';
        break;
      case UserRole.superAdmin:
        color = Colors.red;
        label = 'Super Admin';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }

  void _showEditDialog(BuildContext context, UserProfile profile) {
    String selectedRole = profile.role.value;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Usuario: ${profile.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: ${profile.userId}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rol',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'player',
                  child: Text('Player'),
                ),
                DropdownMenuItem(
                  value: 'coach',
                  child: Text('Coach'),
                ),
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'super_admin',
                  child: Text('Super Admin'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedRole = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(profilesNotifierProvider.notifier)
                  .updateUserRole(profile.userId, selectedRole);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rol actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          '¿Estás seguro de que quieres resetear la contraseña para "${profile.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(profilesNotifierProvider.notifier)
                  .resetUserPassword(profile.userId);

              if (context.mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset enviado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
