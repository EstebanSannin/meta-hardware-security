# Deprecated: legacy name of the hws-signed-verity class, kept for compatibility with
# meta-toradex-security configurations. Use hws-signed-verity instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-signed-verity
include ${@hws_tdx_compat_deprecated_class(d, 'tdxref-signed', 'hws-signed-verity')}

# keep the legacy signing class name (informational, may be displayed to users)
TDX_SIGNING_CLASS = "tdxref-signed"
