# Configuración del Sistema de Envío de Emails para Invitaciones

## Problema Actual

Actualmente, las invitaciones se crean en la base de datos pero **NO se envían emails** a los usuarios invitados. Los usuarios solo pueden activar su invitación cuando crean una cuenta con el email exacto que fue invitado.

La invitación para "fauste" no llegó porque el sistema aún no tiene configurado el envío de emails.

## Solución Implementada

✅ Se ha agregado la funcionalidad de "reenviar invitación" en la UI con un botón azul de envío.

✅ El código ahora usa la Edge Function `invite-user` existente en Supabase.

⚠️ **Importante**: La Edge Function `invite-user` ya existe en tu proyecto de Supabase (desplegada desde el proyecto React original), pero debe estar configurada correctamente para enviar emails.

## Cómo Revisar Errores en Supabase

### 1. Revisar Logs Locales (Docker)

Si estás usando Supabase localmente con Docker:

```bash
# Iniciar Docker si no está corriendo
open -a Docker

# Una vez Docker esté corriendo, verifica el estado
supabase status

# Ver logs en tiempo real
supabase logs --db postgres --follow

# Ver logs de errores específicos
docker logs supabase_db_sport-tech-app 2>&1 | grep ERROR
```

### 2. Revisar Dashboard de Supabase (Producción)

Si estás usando Supabase en la nube:

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto
3. Ve a **Logs** en el menú lateral
4. Filtra por:
   - **Database Logs**: Para errores de base de datos
   - **Functions Logs**: Para errores de Edge Functions
   - **Auth Logs**: Para problemas de autenticación

### 3. Verificar Invitaciones Pendientes

Ejecuta esta query en el SQL Editor de Supabase:

```sql
-- Ver todas las invitaciones pendientes
SELECT
  id,
  email,
  role,
  display_name,
  status,
  created_at,
  player_id
FROM public.pending_invites
WHERE status = 'pending'
ORDER BY created_at DESC;

-- Ver errores del trigger (warnings)
SELECT * FROM pg_stat_statements
WHERE query LIKE '%apply_pending_invite%';
```

## Verificar la Edge Function `invite-user`

### Comprobar que la función existe y está activa

1. Ve al dashboard de Supabase: https://app.supabase.com
2. Selecciona tu proyecto `team-sport-management-stage`
3. Ve a **Edge Functions** en el menú lateral
4. Verifica que `invite-user` esté desplegada y activa

### Probar la función manualmente

Desde el dashboard de Supabase, en la pestaña "Test" de la función `invite-user`, prueba con este payload:

```json
{
  "email": "test@example.com",
  "role": "player",
  "display_name": "Test User",
  "team_ids": [1],
  "player_id": 13,
  "invite_id": 1
}
```

### Ver logs de la función

1. En el dashboard, ve a **Edge Functions** > **invite-user** > **Logs**
2. Filtra por los últimos 15 minutos
3. Busca errores relacionados con el envío de emails

## Si necesitas recrear la Edge Function

### Opción 1: Copiar desde el proyecto React

Si tienes acceso al proyecto React original:

```bash
# Desde el proyecto React, copia la función
cp -r ../react-project/supabase/functions/invite-user ./supabase/functions/

# Despliega la función
supabase functions deploy invite-user
```

### Opción 2: Crear una nueva Edge Function básica

```bash
# Crear el directorio de funciones
mkdir -p supabase/functions/invite-user

# Crear el archivo de la función
cat > supabase/functions/invite-user/index.ts << 'EOF'
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const APP_URL = Deno.env.get('APP_URL') || 'https://tu-app.com'

serve(async (req) => {
  try {
    const { invite_id, email, role, display_name } = await req.json()

    // Enviar email usando Resend (o tu servicio de email preferido)
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'Sport Tech App <invites@tu-dominio.com>',
        to: [email],
        subject: 'Invitación a Sport Tech App',
        html: `
          <h1>¡Has sido invitado a Sport Tech App!</h1>
          <p>Hola ${display_name || email},</p>
          <p>Has sido invitado como <strong>${role}</strong> a Sport Tech App.</p>
          <p>Para aceptar la invitación, crea tu cuenta haciendo clic en el siguiente enlace:</p>
          <a href="${APP_URL}/auth/signup?email=${encodeURIComponent(email)}">Crear mi cuenta</a>
          <p>Este enlace es válido por 7 días.</p>
        `,
      }),
    })

    const data = await res.json()

    return new Response(
      JSON.stringify({ success: true, data }),
      { headers: { "Content-Type": "application/json" } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    )
  }
})
EOF
```

### Paso 2: Configurar Variables de Entorno

```bash
# Configurar secretos en Supabase
supabase secrets set RESEND_API_KEY=tu_api_key_aqui
supabase secrets set APP_URL=https://tu-app.com

# O para desarrollo local, crea .env
echo "RESEND_API_KEY=tu_api_key_aqui" >> supabase/.env.local
echo "APP_URL=http://localhost:3000" >> supabase/.env.local
```

### Paso 3: Desplegar la Edge Function

```bash
# Desplegar a producción
supabase functions deploy send-invitation-email

# Para desarrollo local
supabase functions serve send-invitation-email
```

### Paso 4: Configurar Permisos

En el dashboard de Supabase, ve a **Authentication > Policies** y verifica que las políticas permitan a los super admins crear invitaciones.

## Alternativas para Envío de Email

### Opción 1: Resend (Recomendado)
- Registrarse en https://resend.com
- Obtener API key
- Configurar dominio verificado
- Usa el código de arriba

### Opción 2: SendGrid
```typescript
// En la Edge Function, reemplaza Resend con SendGrid
const res = await fetch('https://api.sendgrid.com/v3/mail/send', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${SENDGRID_API_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    personalizations: [{ to: [{ email }] }],
    from: { email: 'invites@tu-dominio.com' },
    subject: 'Invitación a Sport Tech App',
    content: [{ type: 'text/html', value: htmlContent }],
  }),
})
```

### Opción 3: Supabase Auth (Más Simple)

Si prefieres usar el sistema de auth de Supabase directamente:

```typescript
// Modificar la función para usar Supabase Auth
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(email, {
  data: { role, display_name, invite_id }
})
```

## Verificar que Todo Funciona

1. **Crear una invitación de prueba**
2. **Hacer clic en el botón "Reenviar invitación"** (icono de envío azul)
3. **Revisar los logs** de la Edge Function
4. **Verificar que el email llegó**

## Solución Temporal (Sin Email)

Si aún no quieres configurar emails, puedes:

1. Copiar el link de signup manualmente
2. Compartirlo con el usuario por WhatsApp/Slack
3. Asegurarte de que el usuario se registre con el email exacto de la invitación

Ejemplo de link: `https://tu-app.com/auth/signup?email=fauste@example.com`

## Troubleshooting

### La invitación no se acepta automáticamente

Verifica que:
- El trigger `trg_apply_pending_invite` existe
- El email en la invitación coincide EXACTAMENTE con el email de registro
- El status de la invitación es 'pending'

```sql
-- Verificar el trigger
SELECT * FROM pg_trigger WHERE tgname = 'trg_apply_pending_invite';

-- Forzar la aplicación de una invitación manualmente
SELECT public.apply_pending_invite();
```

### Error: "Function not found"

Esto significa que la Edge Function aún no está desplegada. Opciones:

1. Desplegar la función (ver Paso 3)
2. Comentar temporalmente la llamada a la función en el código Dart

### El email se envía pero no llega

- Verifica la bandeja de spam
- Confirma que el dominio esté verificado en tu servicio de email
- Revisa los logs del servicio de email (Resend/SendGrid dashboard)

## Próximos Pasos

1. ✅ Botón de reenviar agregado en la UI
2. ⏳ Configurar servicio de email (Resend recomendado)
3. ⏳ Crear y desplegar Edge Function
4. ⏳ Probar con una invitación real
