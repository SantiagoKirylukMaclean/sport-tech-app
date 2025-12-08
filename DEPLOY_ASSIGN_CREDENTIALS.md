# Desplegar Edge Function: assign-player-credentials

## Función
Esta edge function permite asignar credenciales (email y contraseña) directamente a un jugador desde el admin, sin necesidad de invitaciones ni deep links.

## Despliegue

### Opción 1: Usando Supabase CLI (Recomendado)

```bash
# Despliega la función
supabase functions deploy assign-player-credentials

# Verifica que se desplegó correctamente
supabase functions list
```

### Opción 2: Manual desde Supabase Dashboard

1. Ve a tu proyecto en [Supabase Dashboard](https://app.supabase.com)
2. Navega a **Edge Functions**
3. Haz clic en **Create a new function**
4. Nombre: `assign-player-credentials`
5. Copia el contenido de `supabase/functions/assign-player-credentials/index.ts`
6. Pega el código en el editor
7. Asegúrate de que también existe el archivo `supabase/functions/_shared/cors.ts`
8. Haz clic en **Deploy**

## Probar la función

Una vez desplegada:

1. Abre la app Flutter
2. Ve a un equipo con jugadores
3. Busca un jugador que **no tenga cuenta** (no tiene `userId`)
4. Haz clic en el icono de **llave azul** (🔑)
5. Ingresa email y contraseña
6. Haz clic en **Crear Cuenta**

## Resultado esperado

- La edge function crea un usuario en Supabase Auth
- Vincula el usuario al jugador (`user_id`)
- Crea un perfil con rol `player`
- El jugador puede ahora iniciar sesión con esas credenciales

## Verificar

Después de crear la cuenta:

1. Ve a **Authentication** → **Users** en Supabase Dashboard
2. Deberías ver el nuevo usuario con el email asignado
3. En la tabla `players`, el jugador ahora tiene un `user_id`
4. En la tabla `profiles`, existe un perfil con `role = 'player'`

## Beneficios de este enfoque

✅ **Simple**: No necesita deep links ni configuración compleja
✅ **Rápido**: Crea cuentas en segundos desde el admin
✅ **Directo**: No depende de emails ni invitaciones
✅ **Control**: El admin tiene control total sobre las credenciales

## Seguridad

- ✅ Solo usuarios con rol `admin` o `super_admin` pueden usar esta función
- ✅ Valida que el email no esté en uso
- ✅ Valida que el jugador no tenga ya una cuenta
- ✅ Valida formato de email y longitud de contraseña
- ✅ Si falla, hace rollback (elimina el usuario creado)
