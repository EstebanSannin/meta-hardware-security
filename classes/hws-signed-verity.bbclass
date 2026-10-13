# sign bootloader and kernel artifacts
inherit hws-signed

# boot a signed rootfs via dm-verity
inherit hws-signed-dmverity

# override signing class name (informational, may be displayed to users)
TDX_SIGNING_CLASS = "hws-signed-verity"
