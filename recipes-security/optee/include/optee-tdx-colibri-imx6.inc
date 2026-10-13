# compatible machine in OP-TEE source code
OPTEEMACHINE = "imx-mx6dlsabresd"

# required by NXP OP-TEE recipe
PLATFORM_FLAVOR = "mx6dlsabresd"

# uart base address (to print debug messages)
UART_BASE_ADDR = "0x02020000"

# extra arguments to build OP-TEE OS
OPTEE_OS_EXTRA_MACHINE_ARGS = "\
    CFG_TZDRAM_START=${HWS_OPTEE_ADDR_LOAD} \
    CFG_TZDRAM_SIZE=${HWS_OPTEE_ADDR_SIZE} \
    CFG_NS_ENTRY_ADDR=${UBOOT_ENTRYPOINT} \
    CFG_DT=n \
"
