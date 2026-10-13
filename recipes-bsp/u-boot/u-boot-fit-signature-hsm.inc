inherit hws-signed-hsm-env

do_uboot_assemble_fitimage:prepend() {
    hws_signed_hsm_vars_export
}
