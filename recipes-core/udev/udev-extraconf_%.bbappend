do_install:append:hws-encrypted() {
    echo ${TDX_ENC_STORAGE_LOCATION} >> ${D}${sysconfdir}/udev/mount.ignorelist
}
