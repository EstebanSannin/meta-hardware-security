# Deprecated: legacy name of the hws-optee class, kept for compatibility with
# meta-toradex-security configurations. Use hws-optee instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-optee
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-optee', 'hws-optee')}
