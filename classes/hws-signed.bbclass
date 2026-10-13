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

# signing class name (informational, may be displayed to users);
# derived classes should override this
HWS_SIGNING_CLASS = "hws-signed"
