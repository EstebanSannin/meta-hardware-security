require ${@oe.utils.conditional('HWS_K3_SECBOOT_ENABLE', '1', 'ti-k3-secdev-secboot.inc', '', d)}
