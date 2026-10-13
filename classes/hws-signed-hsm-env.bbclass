DEPENDS:append = "\
    openssl-native \
    libp11-native \
    pkcs11-provider-native \
    ${HWS_SIGNED_HSM_PKCS11_MODULE_PROVIDER} \
"

hws_signed_hsm_vars_export_common() {
    # HSM token PIN
    if [ -z "${HWS_SIGNED_HSM_TOKEN_PIN}" ]; then
        bbfatal "Missing PIN to access the HSM. Please configure it via HWS_SIGNED_HSM_TOKEN_PIN variable."
    fi

    # SoftHSM configuration
    if echo ${HWS_SIGNED_HSM_PKCS11_MODULE_PATH} | grep -q 'libsofthsm2.so'; then
        [ -r "${HWS_SIGNED_HSM_PKCS11_SOFTHSM_CONF}" ] || bbfatal "Cannot access SoftHSM configuration file: ${HWS_SIGNED_HSM_PKCS11_SOFTHSM_CONF}"
        export SOFTHSM2_CONF="${HWS_SIGNED_HSM_PKCS11_SOFTHSM_CONF}"
    fi
}

hws_signed_hsm_vars_export() {
    # common configuration
    hws_signed_hsm_vars_export_common

    # OpenSSL engines directory
    for d in \
        "${RECIPE_SYSROOT_NATIVE}${libdir}/engines-3" \
        "${RECIPE_SYSROOT_NATIVE}${libdir}/engines-1.1"
    do
        if [ -d "$d" ]; then
            export OPENSSL_ENGINES="$d"
            break
        fi
    done
    [ -d "${OPENSSL_ENGINES}" ] || bbfatal "OpenSSL engines directory not found in native sysroot."

    # HSM token PIN
    export MKIMAGE_SIGN_PIN="${HWS_SIGNED_HSM_TOKEN_PIN}"

    # PKCS#11 module
    export PKCS11_MODULE_PATH="${RECIPE_SYSROOT_NATIVE}/${HWS_SIGNED_HSM_PKCS11_MODULE_PATH}"
    [ -r "${PKCS11_MODULE_PATH}" ] || bbfatal "PKCS#11 module missing or not readable: ${PKCS11_MODULE_PATH}"
}

# Set up the environment so binman can sign TI K3 boot containers via a key stored in an HSM
hws_signed_hsm_vars_export_k3_binman() {
    # common configuration
    hws_signed_hsm_vars_export_common

    # binman x509_cert key URI
    if [ -z "${HWS_SIGNED_HSM_K3_BINMAN_KEY_URL}" ]; then
        bbfatal "Missing PKCS#11 URI for K3 binman signing. Please configure it via HWS_SIGNED_HSM_K3_BINMAN_KEY_URL variable."
    fi

    # OpenSSL configuration: use user-supplied file if available, otherwise generate one
    if [ -n "${HWS_SIGNED_HSM_K3_OPENSSL_CONF}" ]; then
        [ -r "${HWS_SIGNED_HSM_K3_OPENSSL_CONF}" ] || bbfatal "Cannot read OpenSSL configuration file: ${HWS_SIGNED_HSM_K3_OPENSSL_CONF}"
        export OPENSSL_CONF="${HWS_SIGNED_HSM_K3_OPENSSL_CONF}"
    else
        pkcs11_module="${RECIPE_SYSROOT_NATIVE}/${HWS_SIGNED_HSM_PKCS11_MODULE_PATH}"
        [ -r "${pkcs11_module}" ] || bbfatal "PKCS#11 module missing or not readable: ${pkcs11_module}"
        cat > "${WORKDIR}/openssl-pkcs11.cnf" <<EOF
openssl_conf = openssl_init

[openssl_init]
providers = provider_sect

[provider_sect]
default = default_sect
pkcs11 = pkcs11_sect

[default_sect]
activate = 1

[pkcs11_sect]
pkcs11-module-path = ${pkcs11_module}
pkcs11-module-quirks = no-deinit
activate = 1
EOF
        export OPENSSL_CONF="${WORKDIR}/openssl-pkcs11.cnf"
    fi

    # binman x509_cert key URI and PIN
    export BINMAN_X509_KEY_URI="${HWS_SIGNED_HSM_K3_BINMAN_KEY_URL}"
    export PKCS11_PIN="${HWS_SIGNED_HSM_TOKEN_PIN}"
}
