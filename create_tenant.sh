#!/usr/bin/env bash
# ==============================================================================
# Script: create_tenant.sh
# Purpose: Instantly provision a new tenant database from template_db
# Usage: ./create_tenant.sh <tenant_subdomain>
# Example: ./create_tenant.sh company_abc
# ==============================================================================

set -e

TENANT_NAME="$1"
TEMPLATE_NAME="${2:-template_db}"

if [ -z "$TENANT_NAME" ]; then
    echo "❌ Error: Tenant name is required."
    echo "Usage: ./create_tenant.sh <tenant_name>"
    echo "Example: ./create_tenant.sh client1"
    exit 1
fi

echo "🚀 Provisioning new tenant: '${TENANT_NAME}' from template: '${TEMPLATE_NAME}'..."

# Run PostgreSQL createdb inside the running container
docker exec -i odoo_saas_db createdb -U odoo -T "$TEMPLATE_NAME" "$TENANT_NAME"

echo "✅ Success! Tenant database '${TENANT_NAME}' created in 1 second."
echo "🔗 Access URL (via subdomain/filter): http://${TENANT_NAME}.localhost:8069"
