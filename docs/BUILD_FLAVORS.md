# Build Flavors

Esta aplicación está configurada con múltiples flavors (variantes) de build para poder instalar versiones de stage y producción en el mismo dispositivo.

## Flavors Disponibles

### Stage
- **Package ID:** `com.sporttech.app.stage`
- **Nombre visible:** SportTech (Stage)
- **Icono:** Versión con tinte naranja para distinguirlo visualmente
- **Uso:** Para testing en el ambiente de staging

### Prod
- **Package ID:** `com.sporttech.app`
- **Nombre visible:** SportTech
- **Icono:** Icono original sin modificaciones
- **Uso:** Para la versión de producción

## Compilación Local

### Compilar Stage
```bash
flutter build apk --release --flavor stage \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
```

### Compilar Prod
```bash
flutter build apk --release --flavor prod \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
```

### Correr en modo debug
```bash
# Stage
flutter run --flavor stage \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"

# Prod
flutter run --flavor prod \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}"
```

## Ubicación de los APKs

Después de compilar, los APKs se generan en:
- **Stage:** `build/app/outputs/flutter-apk/app-stage-release.apk`
- **Prod:** `build/app/outputs/flutter-apk/app-prod-release.apk`

## GitHub Actions

El workflow de GitHub Actions automáticamente:
1. Detecta la rama (main = prod, stage = stage)
2. Compila el flavor correspondiente
3. Nombra el APK según el ambiente
4. Genera releases en GitHub con los APKs

## Regenerar Iconos

Si necesitas regenerar los iconos con diferentes colores:

```bash
./scripts/generate_flavor_icons.sh
```

Este script:
- Copia los iconos originales a la carpeta de prod
- Crea versiones con tinte naranja para stage

## Estructura de Archivos

```
android/app/src/
├── main/           # Recursos compartidos
│   ├── AndroidManifest.xml
│   └── res/
│       └── mipmap-*/
│           └── ic_launcher.png
├── stage/          # Recursos específicos de stage
│   └── res/
│       └── mipmap-*/
│           └── ic_launcher.png (con tinte naranja)
└── prod/           # Recursos específicos de prod
    └── res/
        └── mipmap-*/
            └── ic_launcher.png (original)
```

## Beneficios

✅ Ambas apps pueden coexistir en el mismo dispositivo
✅ Fácil distinguir visualmente cuál es stage vs prod
✅ Diferentes package IDs previenen confusión
✅ Builds automáticos en CI/CD
