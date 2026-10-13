# secure boot fixups for TI K3 platforms
require ${@oe.utils.conditional('HWS_K3_SECBOOT_ENABLE', '1', 'tezi-run-metadata-secboot-k3.inc', '', d)}
