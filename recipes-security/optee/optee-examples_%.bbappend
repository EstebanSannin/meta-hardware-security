require ${@oe.utils.conditional('HWS_OPTEE_ENABLE', '1', 'optee-hws.inc', '', d)}
