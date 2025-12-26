#!/bin/bash

# Script para debug de la app en Android
# Uso: ./scripts/debug-android.sh

ADB="$HOME/Library/Android/sdk/platform-tools/adb"

echo "🔍 Verificando conexión de dispositivos..."
DEVICES=$($ADB devices | grep -v "List" | grep "device" | wc -l)

if [ "$DEVICES" -eq 0 ]; then
    echo "❌ No hay dispositivos conectados"
    echo ""
    echo "Por favor:"
    echo "1. Conecta tu dispositivo por USB"
    echo "2. Habilita 'Depuración USB' en Opciones de Desarrollador"
    echo "3. Autoriza la conexión cuando pregunte"
    echo ""
    exit 1
fi

echo "✅ Dispositivo conectado"
echo ""

# Mostrar dispositivos conectados
echo "📱 Dispositivos disponibles:"
$ADB devices
echo ""

# Preguntar qué hacer
echo "¿Qué quieres hacer?"
echo "1) Instalar APK"
echo "2) Ver logs en tiempo real"
echo "3) Ver logs de crash (últimos)"
echo "4) Instalar APK y ver logs"
echo "5) Desinstalar app"
read -p "Opción (1-5): " option

case $option in
    1)
        echo "📦 Instalando APK..."
        $ADB install -r build/app/outputs/flutter-apk/app-release.apk
        echo ""
        echo "✅ APK instalado. Ahora abre la app manualmente en el dispositivo."
        ;;
    2)
        echo "📋 Mostrando logs en tiempo real (Ctrl+C para salir)..."
        echo "   Ahora abre la app en tu dispositivo..."
        echo ""
        $ADB logcat -c
        $ADB logcat | grep -E "flutter|sporttech|SportTech|FATAL|AndroidRuntime|DEBUG"
        ;;
    3)
        echo "📋 Últimos logs de crash:"
        echo ""
        $ADB logcat -d | grep -A 50 "FATAL\|AndroidRuntime" | tail -100
        ;;
    4)
        echo "📦 Instalando APK..."
        $ADB install -r build/app/outputs/flutter-apk/app-release.apk
        echo ""
        echo "✅ APK instalado"
        echo ""
        echo "📋 Mostrando logs en tiempo real (Ctrl+C para salir)..."
        echo "   Ahora abre la app en tu dispositivo..."
        echo ""
        sleep 2
        $ADB logcat -c
        $ADB logcat | grep -E "flutter|sporttech|SportTech|FATAL|AndroidRuntime|DEBUG"
        ;;
    5)
        echo "🗑️  Desinstalando app..."
        $ADB uninstall com.sporttech.app
        echo "✅ App desinstalada"
        ;;
    *)
        echo "❌ Opción inválida"
        exit 1
        ;;
esac
