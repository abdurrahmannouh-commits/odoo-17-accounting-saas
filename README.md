# Odoo 19 Full Accounting Multi-Tenant SaaS (Production-Grade)

An industrial, multi-tenant architecture running **Odoo 19.0 Community** with **Full Accounting** (Odoo Mates suite), **Caddy Reverse Proxy** (Automated Let's Encrypt Wildcard SSL), and **Filestore-Aware Database Provisioning**.

---

## 🏗️ Architecture & Stack

```
[ Customer Subdomains: *.yourdomain.com ]
                     │ (HTTPS / Auto SSL)
                     ▼
           [ Caddy Reverse Proxy ]
                     │ (Port 8069)
                     ▼
        [ Odoo 19 Community Service ]
         ├── config: proxy_mode = True
         └── filter: dbfilter = ^%d$
                     │
       ┌─────────────┴─────────────┐
       ▼                           ▼
[ PostgreSQL 15/16 ]         [ Docker Filestore Volume ]
├── template_db (Master)     └── /var/lib/odoo/filestore/
├── acme_corp                ├── template_db/
└── beta_llc                 ├── acme_corp/ (Logos, PDFs)
                             └── beta_llc/ (Logos, PDFs)
```

---

## 🚀 Quick Start Guide

### 1. Launch with Docker Compose
```bash
docker compose up -d
```
*(Containers will be visible and manageable inside **Whaler** on Zorin OS).*

### 2. Create the "Golden Template" Database (`template_db`)
1. Open your browser at **`http://localhost:8069`** (or through Caddy at **`http://localhost`**).
2. Create your master template:
   * **Master Password**: `admin_master_secret_2026`
   * **Database Name**: `template_db`
   * **Email / Password**: Set your administrative credentials.
   * **Demo Data**: Leave **unchecked**.
3. Inside Odoo:
   * Enable **Developer Mode** in Settings.
   * Go to **Apps** -> **Update Apps List**.
   * Search for `om_account_accountant` and click **Activate**.
   * Set your chart of accounts, currency, and base configuration.

---

## ⚡ Safe 1-Second Tenant Provisioning (`./create_tenant.sh`)

When onboarding a new client, run:
```bash
./create_tenant.sh <tenant_subdomain> [admin_password] [template_name]
```
Example:
```bash
./create_tenant.sh acme_corp SecurePass2026!
```

### What `create_tenant.sh` does safely under the hood:
1. **Closes Active Connections:** Terminates existing PostgreSQL connections to `template_db` to avoid PostgreSQL cloning locks.
2. **Clones Database:** Uses PostgreSQL template cloning for sub-second database duplication.
3. **Copies Odoo Filestore:** Copies all attachments, logos, and report assets from `/var/lib/odoo/filestore/template_db` to `/var/lib/odoo/filestore/<tenant_name>` with proper file ownership.
4. **Regenerates Database UUID:** Assigns a unique `database.uuid` so telemetry, mail servers, and webhooks never collide across tenants.
