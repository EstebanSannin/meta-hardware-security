# Settings shared by the feature classes of this layer (hws-signed,
# hws-signed-dmverity, hws-encrypted, hws-optee); inherited by each of them.

# Kernel side of the features, for every kernel recipe (see hws-kernel.bbclass)
KERNEL_CLASSES:append = " hws-kernel"
