# Deprecated: legacy name of the hws-secure-debug class, kept for compatibility with
# meta-toradex-security configurations. Use hws-secure-debug instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-secure-debug
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-secure-debug', 'hws-secure-debug')}
