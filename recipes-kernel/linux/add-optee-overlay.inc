FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://optee_overlay.dts \
"

gen_optee_dt_overlay() {
    if [ "${HWS_OPTEE_ENABLE}" != "1" ]; then
        bbfatal "Will not generate DT overlay since OP-TEE is not enabled!"
    fi

    if [ -z "${HWS_OPTEE_ADDR_LOAD}" ]; then
        bbfatal "Missing HWS_OPTEE_ADDR_LOAD to setup DT overlay!"
    fi

    if [ -z "${HWS_OPTEE_ADDR_SIZE}" ]; then
        bbfatal "Missing HWS_OPTEE_ADDR_SIZE to setup DT overlay!"
    fi

    sed -i 's|@@HWS_OPTEE_ADDR_LOAD@@|${HWS_OPTEE_ADDR_LOAD}|g' ${WORKDIR}/optee_overlay.dts
    sed -i 's|@@HWS_OPTEE_ADDR_SIZE@@|${HWS_OPTEE_ADDR_SIZE}|g' ${WORKDIR}/optee_overlay.dts

    cp ${WORKDIR}/optee_overlay.dts ${S}/${MACHINE_PREFIX}_optee_overlay.dts
}

do_patch[postfuncs] += "gen_optee_dt_overlay"
