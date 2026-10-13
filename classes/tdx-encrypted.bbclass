# Deprecated: legacy name of the hws-encrypted class, kept for compatibility with
# meta-toradex-security configurations. Use hws-encrypted instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-encrypted
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-encrypted', 'hws-encrypted')}
