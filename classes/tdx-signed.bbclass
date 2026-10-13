# Deprecated: legacy name of the hws-signed class, kept for compatibility with
# meta-toradex-security configurations. Use hws-signed instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-signed
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-signed', 'hws-signed')}

# keep the legacy signing class name (informational, may be displayed to users)
TDX_SIGNING_CLASS = "tdx-signed"
