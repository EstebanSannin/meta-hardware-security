FILESEXTRAPATHS:prepend := "${THISDIR}/files/u-boot-hab-status:"

HWS_UBOOT_HAB_STATUS_PATCHES_COMMON = " \
    file://0001-toradex-common-add-hab-utilities-module.patch \
"

HWS_UBOOT_HAB_STATUS_PATCHES_HAB = " \
    ${HWS_UBOOT_HAB_STATUS_PATCHES_COMMON} \
    file://0001-toradex-adjust-hab_status-exit-code-behavior.patch \
"

HWS_UBOOT_HAB_STATUS_PATCHES_SECO = " \
    ${HWS_UBOOT_HAB_STATUS_PATCHES_COMMON} \
    file://0001-toradex-adjust-ahab_status-exit-code-behavior-seco.patch \
"

HWS_UBOOT_HAB_STATUS_PATCHES_ELE = " \
    ${HWS_UBOOT_HAB_STATUS_PATCHES_COMMON} \
    file://0001-toradex-adjust-ahab_status-exit-code-behavior-ele.patch \
"

HWS_UBOOT_HAB_STATUS_PATCHES = "${HWS_UBOOT_HAB_STATUS_PATCHES_HAB}"
HWS_UBOOT_HAB_STATUS_PATCHES:apalis-imx8 = "${HWS_UBOOT_HAB_STATUS_PATCHES_SECO}"
HWS_UBOOT_HAB_STATUS_PATCHES:colibri-imx8x = "${HWS_UBOOT_HAB_STATUS_PATCHES_SECO}"
HWS_UBOOT_HAB_STATUS_PATCHES:mx9-generic-bsp = "${HWS_UBOOT_HAB_STATUS_PATCHES_ELE}"

SRC_URI:append = " \
    ${HWS_UBOOT_HAB_STATUS_PATCHES} \
"
