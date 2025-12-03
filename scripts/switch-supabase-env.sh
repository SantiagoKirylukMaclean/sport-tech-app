#!/bin/bash
# Script para cambiar el ambiente de Supabase CLI entre local, staging y producción
# Uso: ./scripts/switch-supabase-env.sh [local|staging|prod]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project refs
PROD_PROJECT_REF="fkjbvwbnbxslornufhlp"
STAGING_PROJECT_REF="wuinfsedukvxlkfvlpna"

# Función para mostrar uso
show_usage() {
    echo -e "${BLUE}Uso:${NC}"
    echo "  ./scripts/switch-supabase-env.sh [ambiente]"
    echo ""
    echo -e "${BLUE}Ambientes disponibles:${NC}"
    echo "  local   - Base de datos local (Docker)"
    echo "  staging - Ambiente de staging"
    echo "  prod    - Ambiente de producción"
    echo ""
    echo -e "${BLUE}Ejemplos:${NC}"
    echo "  ./scripts/switch-supabase-env.sh local"
    echo "  ./scripts/switch-supabase-env.sh staging"
    echo "  ./scripts/switch-supabase-env.sh prod"
    echo ""
}

# Función para obtener el ambiente actual
get_current_env() {
    PROJECT_REF_FILE="supabase/.temp/project-ref"

    if [ -f "$PROJECT_REF_FILE" ]; then
        PROJECT_REF=$(cat "$PROJECT_REF_FILE")
        if [ "$PROJECT_REF" = "$PROD_PROJECT_REF" ]; then
            echo "prod"
        elif [ "$PROJECT_REF" = "$STAGING_PROJECT_REF" ]; then
            echo "staging"
        else
            echo "unknown"
        fi
    else
        echo "local"
    fi
}

# Función para mostrar el ambiente actual
show_current_env() {
    CURRENT_ENV=$(get_current_env)

    echo -e "${BLUE}📍 Ambiente actual de Supabase CLI:${NC}"
    echo ""

    case $CURRENT_ENV in
        local)
            echo -e "${GREEN}✅ LOCAL${NC}"
            echo "   URL: http://127.0.0.1:54321"
            echo "   Database: postgresql://postgres:postgres@127.0.0.1:54322/postgres"
            echo "   Studio: http://127.0.0.1:54323"
            ;;
        staging)
            echo -e "${YELLOW}📦 STAGING${NC}"
            echo "   Project Ref: $STAGING_PROJECT_REF"
            echo "   URL: https://wuinfsedukvxlkfvlpna.supabase.co"
            ;;
        prod)
            echo -e "${RED}🚀 PRODUCCIÓN${NC}"
            echo "   Project Ref: $PROD_PROJECT_REF"
            echo "   URL: https://fkjbvwbnbxslornufhlp.supabase.co"
            ;;
        unknown)
            echo -e "${RED}❓ DESCONOCIDO${NC}"
            PROJECT_REF=$(cat supabase/.temp/project-ref)
            echo "   Project Ref: $PROJECT_REF"
            ;;
    esac
    echo ""
}

# Función para cambiar a local
switch_to_local() {
    echo -e "${BLUE}🔄 Cambiando a ambiente LOCAL...${NC}"
    echo ""

    # Si ya está en local, no hacer nada
    CURRENT_ENV=$(get_current_env)
    if [ "$CURRENT_ENV" = "local" ]; then
        echo -e "${GREEN}✅ Ya estás en ambiente LOCAL${NC}"
        return 0
    fi

    # Desconectar del proyecto remoto
    echo -e "${YELLOW}Desconectando del proyecto remoto...${NC}"
    npx supabase unlink

    echo ""
    echo -e "${GREEN}✅ Cambiado a ambiente LOCAL${NC}"
    echo ""
    echo -e "${YELLOW}💡 Asegúrate de que Supabase local esté corriendo:${NC}"
    echo "   npx supabase start"
    echo ""
}

# Función para cambiar a staging
switch_to_staging() {
    echo -e "${BLUE}🔄 Cambiando a ambiente STAGING...${NC}"
    echo ""

    # Si ya está en staging, no hacer nada
    CURRENT_ENV=$(get_current_env)
    if [ "$CURRENT_ENV" = "staging" ]; then
        echo -e "${GREEN}✅ Ya estás en ambiente STAGING${NC}"
        return 0
    fi

    # Si está conectado a otro proyecto, desconectar primero
    if [ "$CURRENT_ENV" != "local" ]; then
        echo -e "${YELLOW}Desconectando del proyecto actual...${NC}"
        npx supabase unlink
        echo ""
    fi

    # Conectar a staging
    echo -e "${YELLOW}Conectando a STAGING...${NC}"
    echo ""
    echo "Se te pedirá:"
    echo "  1. Tu contraseña de base de datos de staging"
    echo "  2. Confirmar la conexión"
    echo ""

    npx supabase link --project-ref $STAGING_PROJECT_REF

    echo ""
    echo -e "${GREEN}✅ Cambiado a ambiente STAGING${NC}"
    echo ""
}

# Función para cambiar a producción
switch_to_prod() {
    echo -e "${BLUE}🔄 Cambiando a ambiente PRODUCCIÓN...${NC}"
    echo ""
    echo -e "${RED}⚠️  ADVERTENCIA: Vas a conectarte a PRODUCCIÓN${NC}"
    echo -e "${RED}   Cualquier comando que ejecutes afectará datos reales${NC}"
    echo ""

    read -p "¿Estás seguro de que quieres continuar? (escribe 'PRODUCCION' para confirmar): " CONFIRM

    if [ "$CONFIRM" != "PRODUCCION" ]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        exit 0
    fi

    # Si ya está en prod, no hacer nada
    CURRENT_ENV=$(get_current_env)
    if [ "$CURRENT_ENV" = "prod" ]; then
        echo -e "${GREEN}✅ Ya estás en ambiente PRODUCCIÓN${NC}"
        return 0
    fi

    # Si está conectado a otro proyecto, desconectar primero
    if [ "$CURRENT_ENV" != "local" ]; then
        echo -e "${YELLOW}Desconectando del proyecto actual...${NC}"
        npx supabase unlink
        echo ""
    fi

    # Conectar a producción
    echo -e "${YELLOW}Conectando a PRODUCCIÓN...${NC}"
    echo ""
    echo "Se te pedirá:"
    echo "  1. Tu contraseña de base de datos de producción"
    echo "  2. Confirmar la conexión"
    echo ""

    npx supabase link --project-ref $PROD_PROJECT_REF

    echo ""
    echo -e "${GREEN}✅ Cambiado a ambiente PRODUCCIÓN${NC}"
    echo -e "${RED}⚠️  RECUERDA: Estás en PRODUCCIÓN - ten mucho cuidado${NC}"
    echo ""
}

# Main script
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}  Supabase Environment Switcher${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# Si no se proporciona argumento, mostrar ambiente actual y uso
if [ $# -eq 0 ]; then
    show_current_env
    show_usage
    exit 0
fi

# Procesar argumento
case $1 in
    local|l)
        switch_to_local
        ;;
    staging|stage|s)
        switch_to_staging
        ;;
    prod|production|p)
        switch_to_prod
        ;;
    status|current)
        show_current_env
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}❌ Ambiente desconocido: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

# Mostrar ambiente actual después del cambio
echo ""
show_current_env
