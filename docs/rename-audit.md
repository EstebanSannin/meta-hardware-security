# Phase 1 rename audit

Every remaining occurrence of `tdx`, `TDX`, `toradex`, `Toradex` or `Torizon` in
the layer after the Phase 1 renames (`MIGRATION.md` and `docs/fork-inventory.md` are
excluded because they list old names on purpose). Each occurrence is classified by rule
against the decisions in `docs/fork-inventory.md`; the audit fails if any occurrence is
not explained by a rule.

Result at the end of Phase 1: **0 unclassified occurrences.**

Categories: **B** runtime ABI kept on purpose, **C** Toradex-only content handled in
Phase 2, **E** keep as is, **COMPAT** the transitional compatibility class and legacy
wrapper classes, which carry the legacy names by design. No **D** (policy leak) items
carry a `tdx` name except the `tdx-reference-minimal-image` default, counted under C5.

| Category | Rule | Occurrences | Files | Tokens |
| :------- | :--- | ----------: | ----: | :----- |
| B | on-device encryption handler (script, unit, init script, names, keyring) | 301 | 7 | `/init.d/tdx-enc`, `/tdx-enc`, `/tdx-enc-handler.service`, `/tdx-enc.XXXXXXXXXX`, `/tdx-enc.sh`, `/tmp/tdx-enc.XXXXXXXXXX`, `/usr/sbin/tdx-enc.sh`, `/var/log/tdx-enc.log`, `/var/run/tdx-enc.pid`, `TDX_ENC_BACKUP_FILE`, `TDX_ENC_BACKUP_STORAGE_PCT`, `TDX_ENC_CIPHER` (+63 more) |
| B | runtime ABI value or name | 20 | 11 | `/var/local/private/.keys/tdx-enc-key.blob`, `CONFIG_TDX_CP_PROTECTION`, `CONFIG_TDX_CP_PROTECTION_ALLOW_CMD`, `CONFIG_TDX_FB_PROTECTION`, `CONFIG_TDX_FB_PROTECTION_ALLOW_CMD`, `CONFIG_TDX_SECBOOT_HARDENING`, `CONFIG_TDX_SECBOOT_HARDENING_DBG`, `recipes-images/images/tdx-reference-ramdisk-image.bb`, `tdx-enc-handler`, `tdx-enc-handler.service`, `tdx-enc-key.blob`, `tdx-reference-ramdisk-image` (+2 more) |
| C | Easy Installer data partition (D11) | 46 | 7 | `TDX_TEZI_DATA_PARTITION_AUTOMOUNT`, `TDX_TEZI_DATA_PARTITION_AUTOMOUNT_DEFAULT`, `TDX_TEZI_DATA_PARTITION_AUTOMOUNT_DEFAULT:hws-encrypted`, `TDX_TEZI_DATA_PARTITION_LABEL`, `TDX_TEZI_DATA_PARTITION_MOUNTPOINT`, `TDX_TEZI_DATA_PARTITION_MOUNT_FLAGS`, `TDX_TEZI_DATA_PARTITION_SIZE_NOMINAL`, `TDX_TEZI_DATA_PARTITION_TYPE`, `TDX_TEZI_DATA_PARTITION_WANT_MAXIMIZED`, `append:tdx-tezi-data-partition`, `classes/tdx-tezi-data-partition.bbclass`, `do_install:append:tdx-tezi-data-partition` (+1 more) |
| C | Easy Installer includes / fusing helper (C1, D12) | 7 | 5 | `TDX_IMX_HAB_GEN_UBOOT_FUSING_CMD`, `classes/include/signed/tdx-signed-dmverity-tezi.inc`, `classes/include/signed/tdx-signed-imx-hab-tezi.inc`, `include/signed/tdx-signed-dmverity-tezi.inc`, `tdx-signed-imx-hab-tezi.inc` |
| C | NXP CST built from the Toradex-hosted fork (C7, D16) | 1 | 1 | `git://github.com/toradex/imx-code-signing-tool.git` |
| C | Toradex BSP layers / dynamic layers / overlay infra (C3) | 34 | 20 | `/dynamic-layers/meta-toradex-tezi/`, `/dynamic-layers/meta-toradex-torizon/`, `/dynamic-layers/toradex-bsp-common/`, `/dynamic-layers/toradex-nxp/`, `/dynamic-layers/toradex-ti/`, `SRC_URI:append:pn-linux-toradex`, `dynamic-layers/meta-toradex-tezi/recipes-bsp/tezi-run-metadata/tezi-run-metadata-secboot-k3.inc`, `dynamic-layers/meta-toradex-tezi/recipes-bsp/tezi-run-metadata/tezi-run-metadata-secboot.inc`, `dynamic-layers/meta-toradex-tezi/recipes-bsp/tezi-run-metadata/tezi-run-metadata_`, `dynamic-layers/meta-toradex-tezi/recipes-core/u-boot-distro-boot/u-boot-distro-boot_`, `dynamic-layers/meta-toradex-torizon/recipes-support/usermount/usermount_`, `dynamic-layers/toradex-bsp-common/recipes-bsp/u-boot/u-boot-distro-boot.bbappend` (+18 more) |
| C | Toradex boot-script amendments (C4) | 16 | 2 | `TDX_AMEND_BOOT_SCRIPT`, `TDX_AMEND_CONSOLE_ARGUMENT`, `TDX_AMEND_ROOT_ARGUMENT`, `tdxargs` |
| C | Toradex links (docs/README, C8) | 2 | 2 | `https://developer.toradex.com/linux-bsp/os-development/security/secure-boot-with-hsm-backed-keys`, `https://www.toradex.com/computer-on-modules` |
| C | Toradex machine names, also as override suffix (C6, D13) | 16 | 8 | `HWS_SECBOOT_REQUIRED_BOOTARGS_DEFAULT:toradex-osm-imx93`, `HWS_SECBOOT_REQUIRED_BOOTARGS_DEFAULT:toradex-smarc-imx8mp`, `HWS_SECBOOT_REQUIRED_BOOTARGS_DEFAULT:toradex-smarc-imx95`, `HWS_UBOOT_HARDENING_PATCHES:toradex-osm-imx93`, `HWS_UBOOT_HARDENING_PATCHES:toradex-smarc-imx95`, `HWS_UBOOT_SECBOOT_PATCHES:toradex-osm-imx93`, `HWS_UBOOT_SECBOOT_PATCHES:toradex-smarc-imx95`, `SRC_URI:append:toradex-smarc-imx8mp`, `toradex,verdin-imx8mm`, `toradex,verdin-imx8mm-wifi`, `toradex,verdin-imx8mm-wifi-dev`, `toradex-osm-imx93` (+2 more) |
| C | Toradex reference image default (C5 / D-d) | 2 | 2 | `tdx-reference-minimal-image` |
| C | Torizon references (downstream distro) | 4 | 3 | `Torizon`, `https://developer.toradex.com/torizon/security/secure-boot-on-am62/`, `https://developer.toradex.com/torizon/security/u-boot-hardening-for-secure-boot/` |
| C | per-machine OP-TEE includes (C6, D13) | 15 | 15 | `include/optee-tdx-`, `recipes-security/optee/include/optee-tdx-apalis-imx6.inc`, `recipes-security/optee/include/optee-tdx-aquila-am69.inc`, `recipes-security/optee/include/optee-tdx-aquila-imx95.inc`, `recipes-security/optee/include/optee-tdx-colibri-imx6.inc`, `recipes-security/optee/include/optee-tdx-colibri-imx7-emmc.inc`, `recipes-security/optee/include/optee-tdx-lino-imx93.inc`, `recipes-security/optee/include/optee-tdx-toradex-osm-imx93.inc`, `recipes-security/optee/include/optee-tdx-toradex-smarc-imx8mp.inc`, `recipes-security/optee/include/optee-tdx-toradex-smarc-imx95.inc`, `recipes-security/optee/include/optee-tdx-verdin-am62.inc`, `recipes-security/optee/include/optee-tdx-verdin-am62p.inc` (+3 more) |
| C | references to the Toradex U-Boot patches (C2) | 40 | 4 | `/recipes-bsp/u-boot/files/0001-toradex-common-add-command-whitelisting-modules.patch`, `/recipes-bsp/u-boot/files/0002-toradex-dts-add-fragment-file-to-configure-secure-bo.patch`, `file://0001-toradex-add-helper-to-detect-closed-device-ele-downstream.patch`, `file://0001-toradex-add-helper-to-detect-closed-device-k3.patch`, `file://0001-toradex-adjust-ahab_status-exit-code-behavior-ele.patch`, `file://0001-toradex-adjust-ahab_status-exit-code-behavior-seco.patch`, `file://0001-toradex-adjust-hab_status-exit-code-behavior.patch`, `file://0001-toradex-common-add-hab-utilities-module.patch`, `file://0001-toradex-common-add-shared-hardening-modules.patch`, `file://0001-toradex-common-add-shared-secboot-module.patch`, `file://0001-toradex-integrate-command-whitelisting-downstream.patch`, `file://0001-toradex-integrate-command-whitelisting-k3.patch` (+22 more) |
| E | Toradex prose (company/product name in comments and docs, C8 for docs) | 29 | 13 | `Toradex`, `Toradex-` |
| E | U-Boot/kernel patch content (authors, code, Upstream-Status) | 596 | 36 | `/chosen/toradex,secure-boot`, `/chosen/toradex,secure-boot/bootloader-commands`, `CMD_CAT_TDX_AUTOSEL_DT`, `CONFIG_TDX_BOOTARGS_PROTECTION`, `CONFIG_TDX_CLI_PROTECTION`, `CONFIG_TDX_CMD_WHITELIST`, `CONFIG_TDX_CP_PROTECTION`, `CONFIG_TDX_CP_PROTECTION_ALLOW_CMD`, `CONFIG_TDX_FB_PROTECTION`, `CONFIG_TDX_FB_PROTECTION_ALLOW_CMD`, `CONFIG_TDX_LOAD_PROTECTION`, `CONFIG_TDX_SECBOOT_HARDENING` (+104 more) |
| E | fork notice / attribution / upstream name | 2 | 1 | `https://github.com/toradex/meta-toradex-security`, `toradex/meta-toradex-security` |
| E | fork notice describing the tdx -> hws migration | 2 | 1 | `TDX_`, `tdx` |
| E | legacy-name guard (fails the build if the old name is used) | 8 | 3 | `TDX_IMX_HAB_CST_KEY_INDEX`, `TDX_K3_HSSE_ENABLE`, `TDX_K3_HSSE_KEY_DIR` |
| COMPAT | legacy wrapper class | 42 | 7 | `@hws_tdx_compat_deprecated_class`, `TDX_SIGNING_CLASS`, `classes/tdx-encrypted.bbclass`, `classes/tdx-optee.bbclass`, `classes/tdx-secure-debug.bbclass`, `classes/tdx-signed-dmverity.bbclass`, `classes/tdx-signed-hsm-env.bbclass`, `classes/tdx-signed.bbclass`, `classes/tdxref-signed.bbclass`, `hws-tdx-compat`, `meta-toradex-security`, `tdx-encrypted` (+9 more) |
| COMPAT | transitional compat class (legacy names by design) | 181 | 1 | `@hws_tdx_compat_overrides`, `@hws_tdx_compat_parse`, `HWS_TDX_COMPAT_OVERRIDES`, `HWS_TDX_COMPAT_VARS`, `TDX_`, `TDX_CHECK_UNSUPP_BOOTMETH:HWS_CHECK_UNSUPP_BOOTMETH`, `TDX_DISABLE_UNSUPP_BOOTMETH:HWS_DISABLE_UNSUPP_BOOTMETH`, `TDX_ENC_BACKUP_STORAGE_PCT:HWS_ENC_BACKUP_STORAGE_PCT`, `TDX_ENC_CIPHER:HWS_ENC_CIPHER`, `TDX_ENC_KEY_BACKEND:HWS_ENC_KEY_BACKEND`, `TDX_ENC_KEY_DIR:HWS_ENC_KEY_DIR`, `TDX_ENC_KEY_FILE:HWS_ENC_KEY_FILE` (+137 more) |

## Not renamed in Phase 1, by decision

| Item | Category | Decision |
| :--- | :------- | :------- |
| `tdx-enc-handler` recipe/package, `tdx-enc.sh`, `tdx-enc`, `tdx-enc-handler.service`, `tdx-enc-key.blob`, `/var/local/private/.keys`, keyring name `tdxenc`, script internals | B | D5, D6, D7 |
| `/chosen/toradex,secure-boot` DT node, `tdx-secboot.dtsi`, `CONFIG_TDX_*` | B | D4, D5 |
| `tdx-reference-ramdisk-image` (deploy and FIT artifact names) | B/C | D12 |
| `tdx-tezi-data-partition` class and `TDX_TEZI_DATA_PARTITION_*` | C | D11 |
| `tdx-signed-*-tezi.inc`, `TDX_IMX_HAB_GEN_UBOOT_FUSING_CMD`, Tezi dynamic layers | C | D12 |
| `TDX_AMEND_*` (Toradex boot script amendments) | C | D4, D12 |
| `optee-tdx-<machine>.inc`, per-machine values and machine lists | C | D13 |
| `TDX_IMX_HAB_CST_KEY_INDEX`, `TDX_K3_HSSE_ENABLE`, `TDX_K3_HSSE_KEY_DIR` (legacy-name guards) | E | — |
| U-Boot / kernel patch contents | E | — |

## How the renames were verified

- **Parse-level golden comparison.** BitBake 2.8.1 (scarthgap) parses the classes and
  the recipe hooks of the baseline tree (`29f2e45`) and of every rename commit for
  7 configurations: i.MX8M Plus (signed + dm-verity + encryption + OP-TEE + secure
  debug), i.MX8X AHAB, i.MX95 ELE, i.MX6 OP-TEE, AM62 K3 + TPM encryption, a
  Torizon-like i.MX8M Mini configuration through the legacy wrapper, and qemuarm64 with
  HSM signing. Every variable and varflag of the configuration datastore and of 3–7
  recipe datastores per configuration is dumped and compared. The baseline is
  normalized only through the exact old → new tokens listed in `MIGRATION.md`, so
  renamed *values* (runtime ABI) would show up as differences. Two modes: new names
  without compat, and unchanged legacy configuration through the compat class. Result:
  no unexplained difference after any commit. A mutation test (renaming the
  `tdx-enc-key.blob` default) is detected.
- **Compat self-test.** 12 scenarios on the BitBake 2.8.1 datastore: override-qualified
  legacy assignment, `:forcevariable`, append-only usage, both names set, parse-time
  conditionals, recipe-level assignment/append, late inheritance, unrelated `TDX_*`
  variables untouched, unset-variable aliases.
- **Encryption handler.** Emulating `do_install` on both trees gives a byte-identical
  installed `tdx-enc.sh`.
- **Build-host scripts.** All helper scripts pass `bash -n`; every variable the recipes
  export to them is read by the script.

These checks don't replace real builds. The `bitbake -e` golden comparison and the
builds are described in Phase 3. The tools are added under `scripts/verify/` in
Phase 3.
