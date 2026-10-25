# Odoo 17 Full Accounting Multi-Tenant SaaS

A production-ready, lightweight Docker setup for running **Odoo 17 Community** with **Full Accounting** (Enterprise-equivalent) configured for **Multi-Tenant SaaS**.

---

## 🏗️ Architecture Overview

* **Odoo Version**: `17.0 Community`
* **Database**: `PostgreSQL 15`
* **Full Accounting Suite**: Odoo Mates Accounting Kit (`om_account_accountant`, `om_account_asset`, `om_account_budget`, `accounting_pdf_reports`, etc.)
* **Tenancy Model**: Fast PostgreSQL Database Templating (`createdb -T template_db client_name`)
* **GUI Management**: Fully visible & manageable in **Whaler** on Zorin OS / Linux.

---

## 🚀 Quick Start Guide

### 1. Start the Containers
Inside this directory (`/home/abdirahman/.gemini/antigravity-ide/scratch/odoo-saas`), run:

```bash
docker compose up -d
```

*(You will immediately see `odoo_saas_web` and `odoo_saas_db` show up in **Whaler**).*

### 2. Check the Status
```bash
docker compose ps
```

---

## 🎯 Step 1: Create Your "Golden Template" Database

1. Open your browser and navigate to: **`http://localhost:8069`**
2. Fill in the Database Manager form:
   * **Master Password**: `admin_master_secret_2026` (configured in `config/odoo.conf`)
   * **Database Name**: `template_db`
   * **Email (Login)**: `admin`
   * **Password**: choose an admin password
   * **Country / Currency**: Select your primary currency (e.g., USD)
   * **Demo data**: Leave **UNCHECKED** (you want a clean template!)
3. Click **Create database**.
4. Once logged in:
   * Go to **Settings** -> Scroll down -> Click **Activate the developer mode**.
   * Go to **Apps** -> Click **Update Apps List** in the top navigation -> Click **Update**.
   * Remove the default "Apps" search filter, type: `om_account_accountant`.
   * Click **Activate** (Install).

✅ **Result:** You now have the full Enterprise-style Accounting menu (Profit & Loss, Balance Sheet, Assets, Budgets, Ledger, etc.) inside `template_db`.

---

## ⚡ Step 2: Instant 1-Second SaaS Tenant Provisioning

Whenever a new customer signs up or you want to onboard a new company, simply run:

```bash
chmod +x create_tenant.sh
./create_tenant.sh client_company_name
```

**How it works under the hood:**
PostgreSQL clones the entire `template_db` instantly via file copy pointers. In **under 1 second**, the new tenant database is created with full accounting ready to go—no 10-minute module installation required!

---

## 🌐 Production Multi-Tenant Domain Routing (`dbfilter`)

In production with real subdomains (e.g. `client1.yourdomain.com`, `client2.yourdomain.com`):

1. Point a Wildcard DNS A-record to your server IP:
   ```text
   *.yourdomain.com  ->  YOUR_SERVER_IP
   ```

2. In [config/odoo.conf](file:///home/abdirahman/.gemini/antigravity-ide/scratch/odoo-saas/config/odoo.conf):
   ```ini
   list_db = False
   dbfilter = ^%d$
   ```
   * `%d` extracts the subdomain (e.g. `client1`) from `client1.yourdomain.com` and automatically connects to the database `client1`.
   * Tenants will never see the database selector or any other tenant's data.

---

## 🔒 Security & Maintenance

* **Master Password**: Keep `admin_passwd` in [config/odoo.conf](file:///home/abdirahman/.gemini/antigravity-ide/scratch/odoo-saas/config/odoo.conf) secret.
* **Backups**: Run automated nightly database dumps:
  ```bash
  docker exec odoo_saas_db pg_dump -U odoo -d client1 > client1_backup_$(date +%F).sql
  ```
