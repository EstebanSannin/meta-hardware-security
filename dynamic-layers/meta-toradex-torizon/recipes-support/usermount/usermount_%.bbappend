do_install:append:hws-encrypted() {
    install -d ${D}${sysconfdir}/usermount
    echo ${HWS_ENC_STORAGE_LOCATION} >> ${D}${sysconfdir}/usermount/ignorelist
}
