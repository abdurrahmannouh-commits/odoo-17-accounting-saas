# -*- coding: utf-8 -*-
{
    'name': 'Modern SaaS Theme',
    'summary': 'Ultra-modern, sleek dark-slate theme for Odoo Community SaaS',
    'description': """
Modern SaaS Theme
=================
Transforms Odoo Community into a high-end, modern SaaS web application:
- Sleek dark-slate navbar with subtle gradient
- Modern Plus Jakarta Sans typography
- Rounded corners and soft shadows for dashboard cards
- Polished Indigo primary buttons and pill badges
- Clean modern tables and forms
    """,
    'version': '19.0.1.0.0',
    'category': 'Themes/Backend',
    'license': 'LGPL-3',
    'author': 'Antigravity SaaS Team',
    'depends': ['web', 'web_responsive'],
    'data': [],
    'assets': {
        'web.assets_backend': [
            'modern_saas_theme/static/src/scss/modern_theme.scss',
        ],
    },
    'installable': True,
    'application': False,
    'auto_install': False,
}
