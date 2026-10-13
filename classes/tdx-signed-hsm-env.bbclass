# Deprecated: legacy name of the hws-signed-hsm-env class, kept for compatibility with
# meta-toradex-security configurations. Use hws-signed-hsm-env instead (see MIGRATION.md).
inherit hws-tdx-compat
inherit hws-signed-hsm-env
include ${@hws_tdx_compat_deprecated_class(d, 'tdx-signed-hsm-env', 'hws-signed-hsm-env')}

# legacy function names
tdx_signed_hsm_vars_export_common() {
    hws_signed_hsm_vars_export_common "$@"
}

tdx_signed_hsm_vars_export() {
    hws_signed_hsm_vars_export "$@"
}

tdx_signed_hsm_vars_export_k3_binman() {
    hws_signed_hsm_vars_export_k3_binman "$@"
}
