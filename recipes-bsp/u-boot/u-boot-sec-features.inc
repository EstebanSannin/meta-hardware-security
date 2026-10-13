# U-Boot patches of this layer applied to this recipe:
#   toradex - the Toradex U-Boot patch set (shared secure boot module, hab_status
#             exit codes, hardening), selected per machine; for the U-Boot
#             recipes it was written for
#   generic - none of these patches: only the generic parts (FIT signature
#             enforcement and key embedding, SoC bootloader signing); U-Boot
#             hardening is not available
HWS_UBOOT_TORADEX_RECIPES ?= "u-boot-toradex u-boot-toradex-ti u-boot-imx"
HWS_UBOOT_FLAVOR ?= "${@'toradex' if d.getVar('PN') in (d.getVar('HWS_UBOOT_TORADEX_RECIPES') or '').split() else 'generic'}"

require ${@ 'u-boot-secure-boot.inc' if 'hws-signed' in d.getVar('OVERRIDES').split(':') else ''}

require ${@oe.utils.conditional('HWS_OPTEE_ENABLE', '1', 'u-boot-optee.inc', '', d)}
