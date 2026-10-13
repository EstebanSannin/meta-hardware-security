FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:hws-encrypted = "\
    file://tdx-enc-handler-requirements.cfg \
"
