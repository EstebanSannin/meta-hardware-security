require ${@oe.utils.conditional('HWS_IMX_HAB_ENABLE', '1', 'imx-boot-hab.inc', '', d)}
