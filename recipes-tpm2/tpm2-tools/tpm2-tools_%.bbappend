# Only change tpm2-tools when this layer uses it: TPM-backed encryption or
# OP-TEE with the firmware TPM.
require ${@ 'tpm2-tools-hws.inc' if ('hws-encrypted' in d.getVar('OVERRIDES').split(':') and d.getVar('HWS_ENC_KEY_BACKEND') == 'tpm') or d.getVar('HWS_OPTEE_FTPM') == '1' else ''}
