# Sistema de Auto-Actualización

## 📱 Cómo Funciona

La app verifica automáticamente si hay una nueva versión disponible en GitHub Releases cada vez que se inicia.

### Flujo de Actualización

1. **Al iniciar la app** (2 segundos después del primer frame)
2. **Consulta GitHub Releases** para obtener la última versión
3. **Compara versiones** (build number) con la versión instalada
4. **Muestra diálogo** si hay una actualización disponible
5. **Descarga el APK** cuando el usuario acepta
6. **Instala automáticamente** el APK descargado

## ⚙️ Configuración Requerida

### 1. Actualizar información del repositorio

Edita el archivo `lib/infrastructure/services/app_update_service.dart` y reemplaza:

```dart
static const String githubOwner = 'TU_USUARIO'; // Tu usuario de GitHub
static const String githubRepo = 'sport-tech-app'; // Nombre de tu repositorio
```

### 2. Asegúrate de que los releases tengan APKs

El workflow de GitHub Actions ya está configurado para:
- Generar APKs automáticamente cuando haces push a `main` o `stage`
- Crear releases con los APKs adjuntos
- Nombrar los releases con el formato: `stage-v1.0.0+1-123`

## 📋 Permisos de Android

Los siguientes permisos ya están configurados en `AndroidManifest.xml`:

- `INTERNET` - Para consultar GitHub API
- `REQUEST_INSTALL_PACKAGES` - Para instalar APKs
- `WRITE_EXTERNAL_STORAGE` - Para guardar el APK descargado (solo Android ≤ 12)

## 🔄 Cómo Incrementar la Versión

Edita `pubspec.yaml`:

```yaml
version: 1.0.0+1
         # ^     ^
         # |     └─ Build number (DEBE incrementarse en cada release)
         # └─ Version name
```

**IMPORTANTE:** El sistema compara **build numbers** (+1, +2, +3, etc.), NO version names.

## 🧪 Pruebas Locales

### Simular una actualización disponible:

1. Instala la app con build number `1.0.0+1`
2. Haz un push con versión `1.0.0+2` a `stage`
3. GitHub Actions generará el APK y creará el release
4. Abre la app instalada (con +1)
5. Debería aparecer el diálogo de actualización

### Verificar que funciona:

```bash
# Ver versión actual de la app instalada
~/Library/Android/sdk/platform-tools/adb shell dumpsys package com.sporttech.app | grep versionCode

# Ver logs de la verificación de updates
~/Library/Android/sdk/platform-tools/adb logcat | grep -i "update\|github"
```

## 📝 Notas Importantes

1. **Solo funciona en Android** - iOS requiere App Store
2. **Requiere conexión a internet** - La app no crashea si no hay internet
3. **GitHub Releases públicos** - El repositorio debe ser público o el token debe tener permisos
4. **Build numbers** - SIEMPRE incrementa el build number (+1, +2, +3...)
5. **Instalación manual** - Android pedirá confirmación para instalar desde fuentes desconocidas

## 🔧 Troubleshooting

### La app no detecta actualizaciones

1. Verifica que el repositorio esté configurado correctamente en `app_update_service.dart`
2. Verifica que exista un release en GitHub con un APK adjunto
3. Verifica que el build number del release sea mayor que el instalado
4. Revisa los logs: `adb logcat | grep -i update`

### El APK no se instala

1. Verifica que el permiso "Instalar desde fuentes desconocidas" esté habilitado
2. En Android 13+, verifica el permiso específico de la app
3. Revisa los logs: `adb logcat | grep -i install`

### Error al descargar

1. Verifica conexión a internet
2. Verifica que la URL del APK sea accesible
3. Verifica permisos de almacenamiento

## 🚀 Mejoras Futuras

- [ ] Descarga en segundo plano con notificación de progreso
- [ ] Verificar firma del APK para seguridad
- [ ] Opción de "No volver a preguntar por esta versión"
- [ ] Auto-actualización en segundo plano (sin confirmación)
- [ ] Soporte para delta updates (solo diferencias)
