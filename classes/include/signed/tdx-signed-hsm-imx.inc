# HSM-backed HAB signing requires a CST binary with PKCS#11 support.
# Since the externally provided CST may not include that support, force
# the use of a source-built CST and enable its PKCS#11 integration when
# HAB signing is active.
HWS_IMX_HAB_CST_BUILD_FROM_SOURCE = "${HWS_IMX_HAB_ENABLE}"
HWS_IMX_HAB_CST_BUILD_WITH_PKCS11 = "${HWS_IMX_HAB_CST_BUILD_FROM_SOURCE}"
