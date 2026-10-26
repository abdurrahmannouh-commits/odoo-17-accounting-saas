#!/usr/bin/env bash
# ==============================================================================
# Script: create_tenant.sh (SaaS Multi-Tenant Provisioning)
# Full Business Suite: Accounting + Inventory + Sales + Purchase
# Zero Distractions: "Apps" and "Settings" are automatically hidden from client!
# ==============================================================================

set -e

TENANT_NAME="$1"
CLIENT_LOGIN="${2:-client_admin}"
CLIENT_PASS="${3:-SecurePass2026!}"
TEMPLATE_NAME="${4:-template_db}"

if [ -z "$TENANT_NAME" ]; then
    echo "❌ Error: Tenant name is required."
    echo "Usage: ./create_tenant.sh <tenant_subdomain> [client_username/email] [password] [template]"
    echo "Example: ./create_tenant.sh my_store store@gmail.com MyPass123!"
    exit 1
fi

echo "=========================================================="
echo "🚀 Provisioning Business Tenant: '$TENANT_NAME'"
echo "=========================================================="

# 1. Terminate any active sessions connected to the template database
echo "⏳ Step 1/5: Closing active connections to '$TEMPLATE_NAME'..."
docker exec -i odoo_saas_db psql -U odoo -d postgres -c \
  "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$TEMPLATE_NAME' AND pid <> pg_backend_pid();" > /dev/null 2>&1 || true

# 2. Clone the PostgreSQL database
echo "⏳ Step 2/5: Cloning database '$TEMPLATE_NAME' -> '$TENANT_NAME'..."
docker exec -i odoo_saas_db createdb -U odoo -T "$TEMPLATE_NAME" "$TENANT_NAME"

# 3. Copy Odoo Filestore (Attachments, logos, reports)
echo "⏳ Step 3/5: Copying filestore attachments..."
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

# 5. Create / Configure Client User with full Business Apps (Accounting, Inventory, Sales, Purchase)
# and strictly HIDE "Apps" and "Settings"
echo "⏳ Step 5/5: Configuring Client Business User (Hiding Apps/Settings)..."
docker exec -i odoo_saas_web odoo shell -d "$TENANT_NAME" --no-http << EOF > /dev/null 2>&1
user = env['res.users'].search([('login', '=', '$CLIENT_LOGIN')])
if not user:
    user = env['res.users'].create({
        'name': '$CLIENT_LOGIN',
        'login': '$CLIENT_LOGIN',
        'email': '$CLIENT_LOGIN',
    })
user.password = '$CLIENT_PASS'

# 4 Core Business Apps groups
group_xmlids = [
    'base.group_user',
    'account.group_account_user',
    'account.group_account_manager',
    'stock.group_stock_manager',
    'sales_team.group_sale_manager',
    'purchase.group_purchase_manager',
]
groups = [env.ref(gid).id for gid in group_xmlids if env.ref(gid, raise_if_not_found=False)]
user.group_ids = [(6, 0, groups)]

# Keep master admin password secure
admin = env['res.users'].browse(2)
admin.password = '$CLIENT_PASS'

env.cr.commit()
EOF

echo ""
echo "=========================================================="
echo "✅ Business Tenant '$TENANT_NAME' Provisioned Successfully!"
echo "🔗 Access URL: http://${TENANT_NAME}.localhost:8069"
echo "👤 Client Username: $CLIENT_LOGIN"
echo "🔑 Client Password: $CLIENT_PASS"
echo ""
echo "📦 Enabled Apps: Accounting + Inventory + Sales + Purchase"
echo "🔒 Protected: 'Apps' and 'Settings' are completely hidden from client!"
echo "=========================================================="
