inherit hws-signed-hsm-env

do_assemble_fitimage_initramfs:prepend() {
    hws_signed_hsm_vars_export
}

do_assemble_fitimage:prepend() {
    hws_signed_hsm_vars_export
}
