# override for conditional assignment
DISTROOVERRIDES .= ":hws-encrypted"

# Encryption key backend
# This variable defines how the encryption key is managed
# Available options:
#    cleartext -> key is stored in clear text (for testing purposes only!)
#    caam      -> use CAAM (available only on iMX6/7/8 based SoMs)
#    tpm       -> use TPM (Trusted Platform Module)
#    tee       -> use TEE (Trusted Execution Environment)
HWS_ENC_KEY_BACKEND ?= ""
HWS_ENC_KEY_BACKEND:mx6-generic-bsp ?= "caam"
HWS_ENC_KEY_BACKEND:mx7-generic-bsp ?= "caam"
HWS_ENC_KEY_BACKEND:mx8-generic-bsp ?= "caam"

# Encryption cipher preset
# This variable selects the dm-crypt cipher preset (algorithm, key size and IV mode)
# WARNING: changing this on an already-encrypted device will make data unrecoverable
# Available options:
#    aes-cbc -> AES-CBC with plain IV  (default, kept for backward compatibility)
#    aes-xts -> AES-XTS with plain64 IV (recommended for new deployments)
HWS_ENC_CIPHER ?= "aes-cbc"

# Encryption key blob location
# This variable defines where the encrypted key will be stored
# Available options:
#    filesystem -> encrypted key blob is stored as a file in the filesystem
#    partition  -> encrypted key blob is stored in a block of the disk outside the dm-crypt partition
HWS_ENC_KEY_LOCATION ?= "filesystem"

# directory to store the encryption key blob
# required if the encryption key location is the filesystem
HWS_ENC_KEY_DIR ?= "/var/local/private/.keys"

# encryption key blob file name
HWS_ENC_KEY_FILE ?= "tdx-enc-key.blob"

# Type of encryption
# This variable defines what will be encrypted
# Available options:
#    partition -> encrypt a full partition
HWS_ENC_STORAGE_TYPE ?= "partition"

# Partition to be encrypted (e.g. /dev/sda1)
HWS_ENC_STORAGE_LOCATION ?= ""

# Number of blocks to reserve from the partition to be encrypted
# Useful in case one needs a storage location to save data in raw
# mode, outside the dm-drypt partition
HWS_ENC_STORAGE_RESERVE ?= "0"

# Defines where the encrypted storage will be mounted
HWS_ENC_STORAGE_MOUNTPOINT ?= "/run/encdata"

# Extra arguments passed to "mkfs" when creating the filesystem on top
# of the encrypted storage
HWS_ENC_STORAGE_MKFS_ARGS ?= ""

# Extra arguments passed to "mount" when mounting the encrypted storage
HWS_ENC_STORAGE_MOUNT_ARGS ?= ""

# Enables preservation of existing data on encrypted device
HWS_ENC_PRESERVE_DATA ?= "0"

# Configurable backup RAM use percentage
HWS_ENC_BACKUP_STORAGE_PCT ?= "30"

# tdx-enc-handler provides the scripts to handle encryption
IMAGE_INSTALL:append = " tdx-enc-handler"

# validate encryption parameters
addhandler validate_enc_parameters
validate_enc_parameters[eventmask] = "bb.event.SanityCheck"
python validate_enc_parameters() {
    key_backend = e.data.getVar('HWS_ENC_KEY_BACKEND')
    if key_backend == "":
        bb.fatal("Please set key backend provider via HWS_ENC_KEY_BACKEND.")
    supported_key_backends = ['cleartext','caam','tpm','tee']
    if key_backend not in supported_key_backends:
        bb.fatal("'%s' is invalid. Please set a valid key backend provider via HWS_ENC_KEY_BACKEND." % key_backend)

    storage_location = e.data.getVar('HWS_ENC_STORAGE_LOCATION')
    if storage_location == "":
        bb.fatal("Please set storage to be encrypted via HWS_ENC_STORAGE_LOCATION.")

    cipher = e.data.getVar('HWS_ENC_CIPHER')
    supported_ciphers = ['aes-cbc', 'aes-xts']
    if cipher not in supported_ciphers:
        bb.fatal("'%s' is invalid. Please set a valid cipher algorithm via HWS_ENC_CIPHER. Supported: %s" % (cipher, ', '.join(supported_ciphers)))
}

# settings shared by the feature classes of this layer
inherit hws-common
