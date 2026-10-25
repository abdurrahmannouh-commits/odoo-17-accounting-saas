#!/usr/bin/env bash
# ==============================================================================
# Script: create_tenant.sh (Production-Grade SaaS Provisioning)
# ==============================================================================
# Features:
# 1. Terminates open connections to template_db so Postgres never errors.
# 2. Clones the PostgreSQL database safely.
# 3. Copies the Odoo Filestore (attachments, logos, report templates).
# 4. Regenerates a new unique database.uuid to avoid cross-tenant telemetry collisions.
# 5. Optionally sets a fresh admin password for the tenant.
# ==============================================================================

set -e

TENANT_NAME="$1"
TENANT_ADMIN_PASS="${2:-AdminPass123!}"
TEMPLATE_NAME="${3:-template_db}"

if [ -z "$TENANT_NAME" ]; then
    echo "❌ Error: Tenant name is required."
    echo "Usage: ./create_tenant.sh <tenant_subdomain> [admin_password] [template_name]"
    echo "Example: ./create_tenant.sh acme_corp SecurePass2026! template_db"
    exit 1
fi

echo "=========================================================="
echo "🚀 Starting Tenant Provisioning: '$TENANT_NAME'"
echo "=========================================================="

# 1. Terminate any active sessions connected to the template database
echo "⏳ Step 1/4: Closing active connections to '$TEMPLATE_NAME'..."
docker exec -i odoo_saas_db psql -U odoo -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TEMPLATE_NAME' AND pid <> pg_backend_pid();" > /dev/null 2>&1 || true

# 2. Clone the PostgreSQL database
echo "⏳ Step 2/4: Cloning database '$TEMPLATE_NAME' -> '$TENANT_NAME'..."
docker exec -i odoo_saas_db createdb -U odoo -T "$TEMPLATE_NAME" "$TENANT_NAME"

# 3. Copy Odoo Filestore (Attachments, logos, reports)
echo "⏳ Step 3/4: Copying filestore attachments..."
docker exec -i odoo_saas_web bash -c "
  if [ -d /var/lib/odoo/filestore/$TEMPLATE_NAME ]; then
    cp -r /var/lib/odoo/filestore/$TEMPLATE_NAME /var/lib/odoo/filestore/$TENANT_NAME
    chown -R odoo:odoo /var/lib/odoo/filestore/$TENANT_NAME
  else
    mkdir -p /var/lib/odoo/filestore/$TENANT_NAME
    chown -R odoo:odoo /var/lib/odoo/filestore/$TENANT_NAME
  fi
"

# 4. Generate new database.uuid
NEW_UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c 'import uuid; print(uuid.uuid4())')
echo "⏳ Step 4/5: Setting fresh database.uuid ($NEW_UUID)..."
docker exec -i odoo_saas_db psql -U odoo -d "$TENANT_NAME" -c \
  "UPDATE ir_config_parameter SET value = '$NEW_UUID' WHERE key = 'database.uuid';" > /dev/null 2>&1 || true

# 5. Set tenant admin password
echo "⏳ Step 5/5: Setting tenant admin credentials..."
docker exec -i odoo_saas_web odoo shell -d "$TENANT_NAME" --no-http << EOF > /dev/null 2>&1
admin = env['res.users'].browse(2)
admin.password = '$TENANT_ADMIN_PASS'
env.cr.commit()
EOF

echo ""
echo "=========================================================="
echo "✅ Tenant '$TENANT_NAME' provisioned successfully!"
echo "🔗 Access URL: http://${TENANT_NAME}.localhost (or port 8069)"
echo "👤 Username: admin"
echo "🔑 Password: $TENANT_ADMIN_PASS"
echo "=========================================================="

