require ${@ 'recipes-bsp/u-boot/u-boot-distro-boot-harden.inc' if 'hws-signed' in d.getVar('OVERRIDES').split(':') else ''}

require ${@ 'recipes-bsp/u-boot/u-boot-distro-boot-optee.inc' if d.getVar('HWS_OPTEE_ENABLE') == '1' else ''}
