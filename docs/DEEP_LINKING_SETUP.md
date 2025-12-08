# Configuración de Deep Linking para Autenticación

Esta guía explica cómo configurar los deep links de Supabase para que los enlaces de invitación y recuperación de contraseña abran la app de Flutter en lugar de localhost:3000.

## ✅ Configuraciones ya implementadas en la app

### Android
- Se agregó un `intent-filter` en `android/app/src/main/AndroidManifest.xml` con el esquema `sporttech://login-callback`

### iOS
- Se configuró `CFBundleURLTypes` en `ios/Runner/Info.plist` con el esquema `sporttech`

### Flutter/Supabase
- La inicialización de Supabase está configurada para detectar automáticamente deep links
- Se creó `AuthCallbackPage` que maneja la autenticación cuando la app se abre desde un deep link
- Se agregó la ruta `/auth-callback` al router de la app

## 🔧 Configuración requerida en Supabase Dashboard

Para que los enlaces de invitación funcionen correctamente, debes configurar la URL de redirección en tu proyecto de Supabase:

### Paso 1: Acceder a la configuración de autenticación

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Navega a **Authentication** → **URL Configuration**

### Paso 2: Configurar Redirect URLs

En la sección de **Redirect URLs**, agrega la siguiente URL:

```
sporttech://login-callback
```

**IMPORTANTE**: Esta URL debe coincidir exactamente con el esquema configurado en AndroidManifest.xml y Info.plist.

### Paso 3: Configurar Site URL (opcional pero recomendado)

Si quieres que los usuarios puedan cambiar su contraseña desde un navegador web también, configura:

```
Site URL: https://tu-dominio.com
```

O para desarrollo local:

```
Site URL: http://localhost:3000
```

### Paso 4: Configurar Email Templates

Por defecto, Supabase usa `{{ .SiteURL }}` en los templates de email. Para forzar que use el deep link:

1. Ve a **Authentication** → **Email Templates**
2. Edita los siguientes templates:
   - **Invite user**
   - **Magic Link**
   - **Change Email**
   - **Reset Password**

3. Reemplaza las URLs en los templates. Por ejemplo, en el template de "Invite user":

**Antes:**
```html
<a href="{{ .ConfirmationURL }}">Accept the invite</a>
```

**Después:**
```html
<a href="{{ .ConfirmationURL }}">Accept the invite</a>
```

Supabase automáticamente usará el deep link `sporttech://login-callback` si está configurado en las Redirect URLs.

## 📱 Flujo de autenticación

### Para invitaciones de jugadores/staff:

1. El admin crea una invitación desde la app
2. Supabase envía un email al usuario con un enlace mágico
3. El usuario hace clic en el enlace desde su móvil
4. El sistema operativo detecta el esquema `sporttech://` y abre la app
5. La app procesa el token de autenticación automáticamente
6. El usuario es redirigido a la página correspondiente (debe cambiar contraseña en el primer login)

### Para recuperación de contraseña:

1. El usuario solicita restablecer su contraseña
2. Supabase envía un email con el enlace de recuperación
3. El usuario hace clic en el enlace
4. La app se abre y procesa el token
5. El usuario es redirigido a cambiar su contraseña

## 🔍 Debugging: Ver qué está pasando

Si el deep link no funciona, activa los logs para ver qué está sucediendo:

1. Ejecuta la app en modo debug:
   ```bash
   flutter run
   ```

2. Abre el enlace de invitación en el dispositivo

3. Revisa los logs en la consola. Deberías ver mensajes como:
   ```
   [log] Supabase initialized. Current session: None
   [log] AuthCallbackPage: Starting auth callback handling
   [log] AuthCallbackPage: Attempt 1 - Session: Not found
   [log] Auth state changed: signedIn
   [log] User signed in: email@example.com
   [log] AuthCallbackPage: User authenticated - email@example.com
   ```

4. Si ves "Session: Not found" en todos los intentos, el problema es que Supabase no está procesando el deep link. Posibles causas:
   - El formato del enlace no es correcto
   - Los parámetros del fragmento hash no están llegando
   - El esquema `sporttech://` no coincide exactamente

### Verificar el formato del deep link

El enlace debe tener este formato cuando Supabase redirige:
```
sporttech://login-callback#access_token=XXX&refresh_token=YYY&expires_in=3600&token_type=bearer&type=recovery
```

**IMPORTANTE**: Los tokens deben estar en el **fragment hash (#)**, NO en query parameters (?).

Si tu enlace tiene `?access_token=...` en lugar de `#access_token=...`, NO funcionará.

## 🧪 Cómo probar

### En desarrollo (Android):

1. Instala la app en un dispositivo físico o emulador:
   ```bash
   flutter run
   ```

2. Usa `adb` para simular un deep link:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW \
     -d "sporttech://login-callback#access_token=TOKEN_AQUI&type=recovery" \
     com.example.sport_tech_app
   ```

3. O envía una invitación real y haz clic en el enlace desde el email en el dispositivo

### En desarrollo (iOS):

1. Instala la app en un simulador o dispositivo:
   ```bash
   flutter run
   ```

2. Usa `xcrun` para simular un deep link:
   ```bash
   xcrun simctl openurl booted "sporttech://login-callback#access_token=TOKEN_AQUI&type=recovery"
   ```

3. O envía una invitación real y haz clic en el enlace desde el email

## 🐛 Solución de problemas

### El enlace sigue abriendo localhost:3000

- Verifica que hayas agregado `sporttech://login-callback` a las Redirect URLs en Supabase
- Asegúrate de guardar los cambios en el dashboard de Supabase
- Puede tomar unos minutos en propagarse

### La app no se abre al hacer clic en el enlace

- **Android**: Verifica que el `intent-filter` esté correctamente configurado en AndroidManifest.xml
- **iOS**: Verifica que `CFBundleURLTypes` esté en Info.plist
- Reinstala la app después de cambiar las configuraciones de manifest/plist

### El enlace abre la app pero muestra error

- Revisa los logs en la consola: `flutter logs`
- Verifica que la ruta `/auth-callback` esté correctamente configurada en el router
- Asegúrate de que Supabase esté inicializado correctamente en main.dart

## 📝 Notas adicionales

- El deep linking solo funciona en dispositivos físicos y emuladores/simuladores, **NO en Flutter Web**
- Para producción, considera usar **Universal Links** (iOS) y **App Links** (Android) con un dominio verificado
- Los tokens en los enlaces expiran después de un tiempo configurado en Supabase (default: 1 hora)

## 🔗 Referencias

- [Supabase Auth Deep Linking](https://supabase.com/docs/guides/auth/auth-deep-linking)
- [Flutter Deep Linking](https://docs.flutter.dev/development/ui/navigation/deep-linking)
- [Android App Links](https://developer.android.com/training/app-links)
- [iOS Universal Links](https://developer.apple.com/ios/universal-links/)
