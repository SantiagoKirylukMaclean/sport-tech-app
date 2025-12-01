// lib/presentation/org/pages/super_admin_panel_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_tech_app/core/constants/app_constants.dart';

class SuperAdminPanelPage extends StatelessWidget {
  const SuperAdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(AppConstants.dashboardRoute);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AdminOptionTile(
            icon: Icons.sports_outlined,
            title: 'Deportes',
            subtitle: 'Gestionar deportes del sistema',
            onTap: () {
              context.go(AppConstants.sportsManagementRoute);
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.business_outlined,
            title: 'Clubes',
            subtitle: 'Gestionar clubes y organizaciones',
            onTap: () {
              context.go(AppConstants.clubsManagementRoute);
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.groups_outlined,
            title: 'Equipos',
            subtitle: 'Gestionar equipos del sistema',
            onTap: () {
              context.go(AppConstants.teamsManagementRoute);
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.person_add_outlined,
            title: 'Invitar Entrenador/Admin',
            subtitle: 'Enviar invitaciones a nuevos entrenadores o administradores',
            onTap: () {
              // TODO: Implementar invitación de entrenadores/admins
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.group_add_outlined,
            title: 'Invitar Jugador',
            subtitle: 'Enviar invitaciones a nuevos jugadores',
            onTap: () {
              // TODO: Implementar invitación de jugadores
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.mail_outline,
            title: 'Invitaciones',
            subtitle: 'Ver y gestionar invitaciones pendientes',
            onTap: () {
              // TODO: Implementar gestión de invitaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _AdminOptionTile(
            icon: Icons.people_outline,
            title: 'Usuarios',
            subtitle: 'Gestionar usuarios del sistema',
            onTap: () {
              // TODO: Implementar gestión de usuarios
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
