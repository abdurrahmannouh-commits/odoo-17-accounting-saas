# -*- coding: utf-8 -*-
{
    'name': 'Odoo Enterprise Theme',
    'summary': 'Official Odoo Enterprise Color Palette and Styling for Community',
    'description': """
Odoo Enterprise Styling
=======================
Applies the official Odoo Enterprise Teal Palette (#017e84) and refined styling:
- Enterprise Teal navbar (#017e84)
- Enterprise buttons and accents
- Rounded cards and polished search bar
- Pure SCSS with 100% stability (Zero JS / Zero template overrides)
    """,
    'version': '19.0.1.0.0',
    'category': 'Themes/Backend',
    'license': 'LGPL-3',
    'author': 'Antigravity SaaS Team',
    'depends': ['web'],
    'data': [],
    'assets': {
        'web._assets_primary_variables': [
            'enterprise_theme/static/src/scss/primary_variables.scss',
        ],
        'web.assets_backend': [
            'enterprise_theme/static/src/scss/enterprise_style.scss',
        ],
    },
    'installable': True,
    'application': False,
    'auto_install': False,
}
