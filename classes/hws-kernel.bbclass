# Kernel side of the security features of this layer: dm-verity, dm-crypt
# and Trusted Keys, OP-TEE, HSM-backed FIT image signing. Each part is
# enabled only when the corresponding feature is in use.
#
# The feature classes (hws-signed, hws-signed-dmverity, hws-encrypted,
# hws-optee) add this class to KERNEL_CLASSES, so it is inherited by every
# kernel recipe that inherits kernel.bbclass. Kernel recipes can also inherit
# it directly.
#
# The configuration is added as .cfg fragments in SRC_URI, which requires a
# kernel recipe that merges configuration fragments (e.g. linux-yocto or
# kernel-yocto based recipes).

require recipes-kernel/linux/hws-kernel-features.inc
