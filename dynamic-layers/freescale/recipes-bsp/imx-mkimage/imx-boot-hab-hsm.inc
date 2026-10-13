inherit hws-signed-hsm-env

do_compile:prepend() {
    hws_signed_hsm_vars_export
}
