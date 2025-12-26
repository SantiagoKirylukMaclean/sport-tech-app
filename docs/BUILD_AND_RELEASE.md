# Build y Release de Android APK

## 🚀 Generación Automática de APKs

Este proyecto está configurado con GitHub Actions para generar APKs automáticamente cuando haces push.

### Cómo Funciona

El workflow se activa automáticamente en:
- **Push a `main`** → Genera APK de **Producción**
- **Push a `stage`** → Genera APK de **Stage**
- **Push a `claude/**`** → Genera APK de **Desarrollo**

### Nombres de los APKs Generados

Los APKs se generan con el siguiente formato:
```
{AppName}-v{version}-{timestamp}.apk
```

**Ejemplos:**
- `SportTechApp-Prod-v1.0.0+1-20251226-143022.apk` (producción)
- `SportTechApp-Stage-v1.0.0+1-stage-20251226-143022.apk` (stage)
- `SportTechApp-Dev-v1.0.0+1-dev-20251226-143022.apk` (desarrollo)

### Dónde Descargar los APKs

#### Opción 1: GitHub Releases (Stage y Prod)
Los APKs de `main` y `stage` se publican automáticamente en **Releases**:
1. Ve a: `https://github.com/TU_USUARIO/TU_REPO/releases`
2. Busca el release correspondiente
3. Descarga el APK desde "Assets"

**Releases automáticos:**
- `prod-v1.0.0-123` → Release de producción
- `stage-v1.0.0-123` → Pre-release de stage

#### Opción 2: GitHub Actions Artifacts (Todos)
Todos los APKs (incluyendo dev) están disponibles en los artifacts:
1. Ve a: `https://github.com/TU_USUARIO/TU_REPO/actions`
2. Haz clic en el workflow run
3. Baja hasta "Artifacts"
4. Descarga el ZIP con el APK

**Nota:** Los artifacts se retienen por 30 días.

### Disparar Build Manualmente

Puedes generar un APK manualmente desde GitHub:
1. Ve a `Actions` → `Build Android APK`
2. Haz clic en "Run workflow"
3. Selecciona la rama (main, stage, etc.)
4. Haz clic en "Run workflow"

## 🔧 Configuración Local

### Generar APK Localmente

```bash
# APK de release
flutter build apk --release

# APK estará en:
# build/app/outputs/flutter-apk/app-release.apk
```

### Cambiar Versión

Edita el archivo `pubspec.yaml`:
```yaml
version: 1.0.0+1
         # ^     ^
         # |     └─ Build number (versionCode)
         # └─ Version name (versionName)
```

**Importante:**
- Incrementa el build number (+1, +2, etc.) en cada release
- Incrementa la versión (1.0.0, 1.0.1, 1.1.0) según semver

## 📱 Instalación del APK

### En Dispositivos Android

1. Descarga el APK
2. Abre el archivo en el dispositivo
3. Si aparece "Instalar desde fuentes desconocidas":
   - Ve a Configuración → Seguridad
   - Habilita "Fuentes desconocidas" o "Instalar apps desconocidas"
4. Instala la aplicación

### Distribución a Usuarios

**Opción Recomendada:** Comparte el enlace directo al release:
```
https://github.com/TU_USUARIO/TU_REPO/releases/latest/download/SportTechApp-Prod-v1.0.0-stage-20251226-143022.apk
```

**Alternativa:** Usa un servicio de acortamiento de URLs para hacerlo más fácil.

## 🔐 Firma de APK (Futuro)

Actualmente, los APKs se firman con las claves de debug. Para producción, deberías:

1. Generar una keystore
2. Configurar signing en `android/app/build.gradle.kts`
3. Agregar los secrets a GitHub Actions

## 📝 Notas

- **Application ID:** `com.sporttech.app`
- **Min SDK:** Determinado por Flutter y Supabase
- **Target SDK:** Última versión estable de Android
- **Retention de Artifacts:** 30 días
