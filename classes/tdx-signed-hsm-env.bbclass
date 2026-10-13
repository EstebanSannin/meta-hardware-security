# Deprecated: legacy name of the hws-signed-hsm-env class, kept for compatibility with
# meta-toradex-security configurations. Use hws-signed-hsm-env instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-signed-hsm-env
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-signed-hsm-env', 'hws-signed-hsm-env')}
