# add the class name in the overrides for conditional assignment
DISTROOVERRIDES .= ":hws-signed-dmverity"

# a ramdisk is required to check the root hash of the verity image
INITRAMFS_IMAGE ?= "tdx-reference-ramdisk-image"
INITRAMFS_IMAGE_BUNDLE ?= "0"

# use the FIT image with the ramdisk
KERNEL_IMAGE_NAME:prepend = "${INITRAMFS_IMAGE_NAME}-"

# rootfs image that will be used to create dm-verity image; it must be set
# to the image recipe being built. It defaults to the Toradex reference
# image only when the Toradex BSP layers are present.
DM_VERITY_IMAGE ?= "${@'tdx-reference-minimal-image' if 'toradex-bsp-common-layer' in (d.getVar('BBFILE_COLLECTIONS') or '').split() else ''}"
DM_VERITY_IMAGE_TYPE ?= "ext4"

# enable creation of dm-verity image
IMAGE_CLASSES += "dm-verity-img"

# the image protected by dm-verity must be known
addhandler validate_dm_verity_image
validate_dm_verity_image[eventmask] = "bb.event.SanityCheck"
python validate_dm_verity_image() {
    if not e.data.getVar('DM_VERITY_IMAGE'):
        bb.fatal("hws-signed-dmverity: set DM_VERITY_IMAGE to the image recipe whose "
                 "root filesystem is protected by dm-verity (e.g. DM_VERITY_IMAGE = \"my-image\").")
}

# we don't need all features from meta-security, so we don't
# include 'security' in DISTROFEATURES. Because of that, a
# warning message is displayed by meta-security. Avoid that by
# setting the variable below.
SKIP_META_SECURITY_SANITY_CHECK ?= "1"

# Tezi configuration
TEZI_ROOT_SUFFIX = "ext4.verity"
TEZI_ROOT_FSTYPE = "raw"

# If different images are built, multiple .verity.env files end up in the
# staging directory, and the ramdisk recipe (tdx-reference-ramdisk-image)
# fails to pick the right one, as its name might be unpredictable (e.g.
# Toradex BSP might append a string to it). To solve this, let's remove
# any previously generated .verity.env file before generating the new one.
verity_setup:prepend() {
    rm -f ${STAGING_VERITY_DIR}/*.verity.env
}

# Easy Installer needs the size of the rootfs image so it can add to image.json
CONVERSION_DEPENDS_verity:append = " bc-native"
verity_setup:append() {
    SIZE_IN_KB=$(echo "${SIZE}/1024" | bc)
    echo ${SIZE_IN_KB} > ${T}/image-size.${TEZI_ROOT_NAME}
}

# fix cyclic dependency when inheriting image_type_tezi.bbclass
require ${@ 'include/signed/tdx-signed-dmverity-tezi.inc' if 'teziimg' in d.getVar('IMAGE_FSTYPES') else ''}
