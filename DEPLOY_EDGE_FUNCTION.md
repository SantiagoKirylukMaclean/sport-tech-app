# Desplegar Edge Function `invite-user`

## Cambios Realizados

He actualizado la Edge Function para usar `inviteUserByEmail()` que:
- ✅ **Envía el email automáticamente** a través de Supabase
- ✅ **Usa la configuración por defecto** de Supabase para el redirect
- ✅ El usuario recibirá un email con un enlace para establecer su contraseña

## Cómo Desplegar

### Opción 1: Desde el CLI de Supabase (Recomendado)

```bash
# 1. Login a Supabase (si no lo has hecho)
supabase login

# 2. Link al proyecto
supabase link --project-ref wuinfsedukvxlkfvlpna

# 3. Desplegar la función
supabase functions deploy invite-user

# 4. Verificar que se desplegó
supabase functions list
```

### Opción 2: Desde el Dashboard de Supabase

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto `team-sport-management-stage`
3. Ve a **Edge Functions** > **invite-user**
4. Haz clic en **"Edit"** o **"Deploy"**
5. Copia y pega el contenido de `supabase/functions/invite-user/index.ts`
6. Guarda y despliega

## Configurar Email Templates (Importante)

Para personalizar el email que reciben los usuarios:

1. Ve al dashboard de Supabase
2. **Authentication** > **Email Templates**
3. Selecciona **"Invite user"**
4. Personaliza el template en español:

```html
<h2>Has sido invitado a Sport Tech App</h2>
<p>Hola,</p>
<p>Has sido invitado a unirte a Sport Tech App.</p>
<p>Haz clic en el siguiente enlace para establecer tu contraseña y comenzar:</p>
<p><a href="{{ .ConfirmationURL }}">Aceptar invitación</a></p>
<p>Este enlace expira en 24 horas.</p>
```

## Configurar URL de Redirección

### Para Desarrollo (Ahora)

Mientras desarrollas localmente, puedes usar la URL hospedada por Supabase:

1. **Authentication** > **URL Configuration**
2. Agrega a **"Redirect URLs"**:
   - `http://localhost:5173/**` (para desarrollo web)
   - `com.sporttech.app://**` (para desarrollo móvil)

### Para Producción (Futuro)

Cuando despliegues tu app:

1. **Web**: Despliega en Vercel/Netlify/Firebase Hosting
2. Agrega la URL de producción a "Redirect URLs":
   - `https://tu-app.com/**`

## Probar la Función

### Desde la App Flutter

1. Ejecuta la app
2. Ve a **Gestión de Invitaciones**
3. Haz clic en **"Reenviar invitación"**
4. **Ahora el email se enviará automáticamente** 📧

### Desde el Dashboard (Manual)

1. **Edge Functions** > **invite-user** > **Test**
2. Usa este payload:

```json
{
  "email": "test@example.com",
  "role": "player",
  "displayName": "Test User",
  "teamIds": [1],
  "playerId": 13
}
```

3. El usuario recibirá un email de Supabase

## Verificar que Funcionó

### 1. Revisar Logs

**Edge Functions** > **invite-user** > **Logs**

Deberías ver:
```
✅ 200 OK - Email sent successfully
```

### 2. Revisar Email

El usuario invitado debería recibir un email de `noreply@mail.app.supabase.io` con:
- Asunto: "You have been invited"
- Botón: "Accept invite"

### 3. Flujo Completo

1. Usuario recibe email
2. Hace clic en el enlace
3. Es redirigido a una página de Supabase para establecer contraseña
4. Después de establecer contraseña, se crea su cuenta
5. El trigger automático aplica la invitación pendiente

## Troubleshooting

### Error: "Failed to send invitation"

**Solución**: Verifica que:
- El proyecto de Supabase tiene email habilitado
- El email template "Invite user" existe
- La dirección de email es válida

### Email no llega

**Solución**:
1. Revisa spam/basura
2. Verifica en **Authentication** > **Users** que el usuario fue creado
3. En desarrollo, Supabase usa un servicio de email gratuito que puede ser lento
4. Para producción, configura un proveedor SMTP personalizado

### "Invalid redirect URL"

**Solución**:
1. Ve a **Authentication** > **URL Configuration**
2. Agrega la URL a "Redirect URLs"
3. Usa `*` para permitir cualquier subdirectorio: `https://tu-app.com/**`

## Alternativa: Usar App Flutter Desplegada

Si prefieres que los usuarios aterricen en tu app Flutter:

### 1. Despliega la app como web

```bash
# Construir para web
flutter build web

# Desplegar a Firebase Hosting (ejemplo)
firebase deploy --only hosting
```

### 2. Actualiza la función

Cambia esta línea en `index.ts`:

```typescript
const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
  body.email,
  {
    redirectTo: 'https://tu-app.com/auth/set-password', // Tu URL aquí
    data: {
      // ...
    }
  }
)
```

### 3. Crea la página `/auth/set-password` en Flutter

Esta página:
1. Captura el token de la URL
2. Muestra un formulario para establecer contraseña
3. Llama a `supabase.auth.updateUser()` con la nueva contraseña

## Resumen

✅ **Solución Simple (Ahora)**: Despliega la función y deja que Supabase maneje todo
- Email automático ✅
- Página de password hospedada por Supabase ✅
- No necesitas desplegar nada más ✅

🚀 **Solución Avanzada (Futuro)**: Despliega tu app Flutter como web
- Email personalizado con tu dominio
- Página de password personalizada en tu app
- Experiencia completamente branded
