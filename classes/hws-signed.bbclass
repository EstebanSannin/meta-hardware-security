# globally enable signed images
DISTROOVERRIDES .= ":hws-signed"

# FIT image configuration
require include/signed/hws-signed-fit-image.inc

# NXP i.MX HAB configuration
MACHINEOVERRIDES_EXTENDER ?= ""
require ${@ 'include/signed/hws-signed-imx-hab.inc' if 'imx-generic-bsp' in d.getVar('MACHINEOVERRIDES_EXTENDER').split(':') else ''}

# TI K3 secure boot configuration
require ${@ 'include/signed/hws-signed-k3-secboot.inc' if 'k3r5' in d.getVar('OVERRIDES').split(':') else ''}
require ${@ 'include/signed/hws-signed-k3-secboot.inc' if 'k3' in d.getVar('OVERRIDES').split(':') else ''}

# hardening configuration
require include/signed/hws-signed-harden.inc

# HSM configuration
HWS_SIGNED_HSM ?= "0"
require ${@oe.utils.conditional('HWS_SIGNED_HSM', '1', 'include/signed/hws-signed-hsm.inc', '', d)}

# machine-specific fixups for the signed image
include include/signed/machine/${MACHINE}.inc

# U-Boot recipes the U-Boot side of this layer is attached to (with a
# bbappend requiring recipes-bsp/u-boot/u-boot-sec-features.inc). If the
# machine uses another U-Boot recipe, add such a bbappend for it and append
# the recipe to this list.
HWS_UBOOT_HOOKED_RECIPES ?= "u-boot u-boot-imx u-boot-ti-staging u-boot-toradex u-boot-toradex-ti"

addhandler validate_uboot_hooked
validate_uboot_hooked[eventmask] = "bb.event.SanityCheck"
python validate_uboot_hooked() {
    provider = e.data.getVar('PREFERRED_PROVIDER_virtual/bootloader') or ''
    if provider.startswith('u-boot') and \
            provider not in (e.data.getVar('HWS_UBOOT_HOOKED_RECIPES') or '').split():
        bb.warn("hws-signed: the bootloader recipe '%s' is not covered by this layer, so FIT "
                "signature enforcement and bootloader signing are not configured in it. Add a "
                "bbappend for it containing 'require recipes-bsp/u-boot/u-boot-sec-features.inc' "
                "and append '%s' to HWS_UBOOT_HOOKED_RECIPES." % (provider, provider))
}

# signing class name (informational, may be displayed to users);
# derived classes should override this
HWS_SIGNING_CLASS = "hws-signed"

# settings shared by the feature classes of this layer
inherit hws-common
