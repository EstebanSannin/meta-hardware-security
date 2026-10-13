do_install:append:hws-encrypted() {
    echo ${HWS_ENC_STORAGE_LOCATION} >> ${D}${sysconfdir}/udev/mount.ignorelist
}
