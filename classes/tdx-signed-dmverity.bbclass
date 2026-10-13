# Deprecated: legacy name of the hws-signed-dmverity class, kept for compatibility with
# meta-toradex-security configurations. Use hws-signed-dmverity instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-signed-dmverity
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-signed-dmverity', 'hws-signed-dmverity')}
