# Fork inventory: meta-toradex-security → meta-hardware-security

Phase 0 deliverable. **No functional change has been made.** This document maps the
repository, classifies every Toradex-specific occurrence and lists the decisions
needed before Phase 1 (mechanical renames) can start.

## 0. Scope and method

| Item | Value |
| :--- | :---- |
| Fork | `EstebanSannin/meta-hardware-security` (fork of `toradex/meta-toradex-security`) |
| Branch inventoried | **`scarthgap-7.x.y` @ `29f2e45`** (`LAYERSERIES_COMPAT = "scarthgap walnascar"`) |
| Why not `main` | `main` (@ `3057dfd`, `wrynose`) is stale: 7 commits not in scarthgap (only `layer.conf` series compat + 3 bbappend renames), while scarthgap has **280** commits not in `main` (secure debug, HSM signing, i.MX93/95, OP-TEE RPMB/fTPM/TEE key backend, reworked encryption, hardening v2…). An inventory of `main` would miss most of the layer. See decision **D1**. |
| Size | 214 tracked files, ~13.5k lines (≈6k are U-Boot patches) |
| Downstream checked | local `~/code/meta-toradex-torizon` (scarthgap-7.x.y) and `~/code/torizon-os/layers/*` |

Searches used (all reproducible from the repo root):

```sh
git grep -nE 'tdx|TDX|toradex|Toradex|torizon|Torizon'
git grep -niE 'verdin|apalis|colibri|aquila|smarc|lino|osm-imx|tezi|easy installer|otaroot|cfs-'
git grep -ohE '\bTDX_[A-Z0-9_]+' -- ':!*.patch' ':!docs/*' | sort | uniq -c
```

Occurrence totals (lines / files): `TDX_` 1202 / 114 · `tdx-` 193 / 65 · `tdx_` 236 / 28 ·
`tdxref` 10 / 4 · `toradex` 192 / 55 · `Toradex` 99 / 38 · `torizon|Torizon|TorizonCore` 33 / 29.
Most `toradex`/`Torizon` hits are inside U-Boot patches (authors, `Upstream-Status`, code).

Category legend:

- **A**: rename (build-time name of a generic or SoC-vendor feature)
- **B**: runtime ABI (lands on device / read by built binaries); default keep, flag
- **C**: Toradex-only content; proposal: generalize / move to `meta-hardware-security-toradex` / drop
- **D**: policy leak (distro/product default inside the layer); proposal to neutralize
- **E**: keep as is (upstream patch content, copyright, history, legacy-name guards)

---

## 1. Repository map

### 1.1 Layer configuration

| File | Content | Notes |
| :--- | :------ | :---- |
| `conf/layer.conf` | collection `meta-toradex-security`, prio 10, deps `core openembedded-layer security`, recommends `toradex-nxp-layer toradex-ti-layer`, compat `scarthgap walnascar`, `BBFILES_DYNAMIC` for `freescale-layer`, `meta-ti-bsp`, `toradex-ti-layer`, `toradex-nxp-layer`, `toradex-bsp-common-layer`, `meta-toradex-torizon`, `toradex-tezi` | A (collection), C (Toradex recommends/dynamic layers) |

### 1.2 Classes (`classes/`)

| Class | Purpose | Adds override | Notes |
| :---- | :------ | :------------ | :---- |
| `tdx-signed.bbclass` | Entry point for secure boot: FIT, i.MX HAB/AHAB, TI K3, hardening, HSM, per-machine fixups; sets `TDX_SIGNING_CLASS` | `:tdx-signed` | A |
| `tdxref-signed.bbclass` | `tdx-signed` + `tdx-signed-dmverity` | (via the two) | A (name: **D3**) |
| `tdx-signed-dmverity.bbclass` | dm-verity rootfs + initramfs; Tezi glue | `:tdx-signed-dmverity` | A + C (Tezi parts) + D |
| `tdx-signed-hsm-env.bbclass` | PKCS#11/HSM env export helpers for signing tasks | — | A |
| `tdx-encrypted.bbclass` | Data-at-rest encryption config + sanity check | `:tdx-encrypted` | A |
| `tdx-optee.bbclass` | OP-TEE enable, fTPM, PKCS#11 TA, RPMB, machine list check | — | A + C (machine list) |
| `tdx-secure-debug.bbclass` | Secure JTAG (SJC/ELE) fuse generation | `:tdx-secure-debug` | A + C (machine lists) |
| `tdx-tezi-data-partition.bbclass` | Extra data partition in Easy Installer images | `:tdx-tezi-data-partition` | **C** (Tezi only) |
| `imx-hab.bbclass` | NXP CST variables + cert name helpers | — | name kept (no `tdx`), variables A |

### 1.3 Class includes (`classes/include/`)

| File | Required from | Notes |
| :--- | :------------ | :---- |
| `signed/tdx-signed-fit-image.inc` | `tdx-signed` | A; FIT defaults, key sanity check |
| `signed/tdx-signed-imx-hab.inc` | `tdx-signed` if `imx-generic-bsp` | A |
| `signed/tdx-signed-imx-hab-tezi.inc` | above, if `teziimg` | C (adds `prog_secure_boot_fuses` to Tezi U-Boot env) |
| `signed/tdx-signed-k3-secboot.inc` | `tdx-signed` if `k3`/`k3r5` | A; legacy-name guard for `TDX_K3_HSSE_*` (E) |
| `signed/tdx-signed-harden.inc` | `tdx-signed` | A + C (per-machine bootargs) |
| `signed/tdx-signed-hsm.inc`, `-hsm-imx.inc`, `-hsm-k3.inc` | `tdx-signed` if `TDX_SIGNED_HSM=1` | A |
| `signed/tdx-signed-dmverity-tezi.inc` | `tdx-signed-dmverity` if `teziimg` | C |
| `signed/machine/{verdin-am62,verdin-am62p,aquila-am69}.inc` | `tdx-signed` (`include …/${MACHINE}.inc`) | C (Tezi `FIRMWARE_BINARY[<product-id>]`, recovery) |
| `optee/boot-from-fit.inc`, `optee/linux-dt-overlay.inc` | OP-TEE machine includes | A + C (`TEZI_EXTERNAL_KERNEL_DEVICETREE_BOOT`, `MACHINE_PREFIX`) |
| `optee/machine/{apalis-imx6,colibri-imx6,colibri-imx7-emmc}.inc` | `tdx-optee` (`include …/${MACHINE}.inc`) | C (per-machine load addr/size) |
| `secure-debug/tdx-secure-debug-sjc.inc`, `-ele.inc` | `tdx-secure-debug` by SoC family | A + C (supported machine lists) |

### 1.4 Recipes, bbappends and includes

| Path | Kind | Attaches to | Notes |
| :--- | :--- | :---------- | :---- |
| `recipes-bsp/u-boot/u-boot-sec-features.inc` | include | U-Boot recipes (via bbappends, §4) | entry: secure boot if `:tdx-signed`, OP-TEE if `TDX_OPTEE_ENABLE` |
| `recipes-bsp/u-boot/u-boot-secure-boot.inc` | include | ↑ | shared secboot module patches (machine-selected), FIT/HAB/K3/hardening dispatch |
| `recipes-bsp/u-boot/u-boot-fit-signature{,-nxp,-ti,-hsm}.inc` | include | ↑ | FIT pubkey embedding fixes per SoC |
| `recipes-bsp/u-boot/u-boot-hab.inc`, `u-boot-hab-status.inc` | include | ↑ | HABv4 signing (i.MX6/7/8M), fuse cmds, hab_status patches (machine-selected) |
| `recipes-bsp/u-boot/u-boot-k3-secboot{,-hsm,-reproducible}.inc` | include | ↑ | K3 key dir, HSM binman, reproducible certs |
| `recipes-bsp/u-boot/u-boot-harden.inc` | include | ↑ | Toradex hardening patches (machine-selected), whitelist DT amend, bootmeth checks, `CP/FB_PROT_SUPPORTED` per machine |
| `recipes-bsp/u-boot/u-boot-optee.inc` | include | ↑ | per-machine binman tee node patches |
| `recipes-bsp/u-boot/u-boot-distro-boot-{sec-features,harden,optee}.inc` | include | Toradex `u-boot-distro-boot` | C (amends Toradex `boot.cmd`, `FITCONF_FDT_OVERLAYS`, `KERNEL_BOOTCMD`) |
| `recipes-bsp/u-boot/u-boot-tools_%.bbappend` | bbappend | oe-core `u-boot-tools` | pkcs11 backport when HSM |
| `recipes-bsp/imx-code-signing-tool/imx-code-signing-tool-native_4.0.1.bb` (+ `-pkcs11.inc`) | recipe | — | builds NXP CST from **`github.com/toradex/imx-code-signing-tool`** (BSD-3-Clause) — see **D16** |
| `recipes-bsp/imx-fuses/imx-fuses-native_1.0.bb` + `files/` | recipe | — | `create_fuse_cmds.sh` + per-SoC fuse templates (generic NXP data) |
| `recipes-core/tdx-enc-handler/tdx-enc-handler_1.0.bb` + `files/` | recipe | — | `tdx-enc.sh`, `tdx-enc` (sysvinit), `tdx-enc-handler.service`, `99-tpm.rules` — **B** |
| `recipes-core/busybox/busybox_%.bbappend` + `tdx-enc-handler-requirements.cfg` | bbappend | busybox | gated by `:tdx-encrypted` |
| `recipes-core/base-files/base-files_%.bbappend` | bbappend | base-files | fstab entry, gated by `:tdx-tezi-data-partition` (C) |
| `recipes-core/udev/udev-extraconf_%.bbappend` | bbappend | udev-extraconf | gated by `:tdx-encrypted` |
| `recipes-images/images/tdx-reference-ramdisk-image.bb` | image | — | dm-verity initramfs — **C/B** (name lands in FIT/deploy names) |
| `recipes-kernel/linux/linux-sec-features.inc` | include | kernel recipes (via bbappends, §4) | dm-verity / dm-crypt / OP-TEE / HSM dispatch |
| `recipes-kernel/linux/linux-{dm-verity,dm-crypt,optee,optee-fit,signed-hsm}.inc`, `files/*.cfg`, `0001-KEYS-trusted-revert-changes-introduced-by-NXP.patch` | include/fragments | ↑ | dm-crypt adds NXP revert only for `pn-linux-toradex` (§4) |
| `recipes-kernel/linux/add-secboot-kargs-overlay.inc`, `add-optee-overlay.inc`, `files/optee_overlay.dts` | include | Toradex `device-tree-overlays*` | C (Toradex overlay infra) + B (`toradex,secure-boot` DT node) |
| `recipes-security/optee/optee-{os,os-tadevkit,examples,test}_%.bbappend` → `optee-tdx.inc` | bbappend | OP-TEE recipes | requires `include/optee-tdx-${MACHINE}.inc` |
| `recipes-security/optee/include/optee-tdx-<machine>.inc` (14 files) | include | ↑ | **C** (per-machine `OPTEEMACHINE`, UART, RPMB dev id) |
| `recipes-security/optee/optee-client_%.bbappend` + `files/tee-supplicant.rules`, `optee-fs-rpmb.inc` | bbappend | optee-client | **unconditional** (D) |
| `recipes-security/optee/optee-ftpm_%.bbappend` | bbappend | optee-ftpm | **unconditional** `COMPATIBLE_MACHINE` (D) |
| `recipes-security/yubico-piv-tool/yubico-piv-tool_2.7.3.bb` | recipe | — | generic (YKCS11 for HSM signing), E |
| `recipes-support/pkcs11-provider/pkcs11-provider_%.bbappend` | bbappend | meta-oe | `BBCLASSEXTEND native`, E |
| `recipes-test/libfaketime/libfaketime_%.bbappend` | bbappend | meta-oe | `BBCLASSEXTEND native`, E |
| `recipes-tpm2/tpm2-tools/tpm2-tools_%.bbappend` | bbappend | meta-security | **unconditional** dependency change (D) |

### 1.5 Dynamic layers

| Path | Key collection | Content | Notes |
| :--- | :------------- | :------ | :---- |
| `dynamic-layers/freescale/recipes-bsp/imx-mkimage/` (`imx-boot_1.0.bbappend`, `imx-boot-hab{,-hsm}.inc`, `imx-boot-secure-debug.inc`, `files/mx8_sign.sh`, `ahabv{1,2}_template.csf`, `ele-{dc,dat}.yaml.in`) | `freescale-layer` | AHAB signing (i.MX8/8X/9), ELE secure debug | vendor backend, A |
| `dynamic-layers/freescale/recipes-bsp/u-boot/u-boot-imx_%.bbappend` | `freescale-layer` | `require u-boot-sec-features.inc` | hook |
| `dynamic-layers/freescale/recipes-kernel/linux/linux-imx_%.bbappend` | `freescale-layer` | `require linux-sec-features.inc` | hook |
| `dynamic-layers/meta-ti-bsp/recipes-ti/secdev/` | `meta-ti-bsp` | `ti-k3-secdev` key dir | vendor backend, A |
| `dynamic-layers/toradex-bsp-common/` (`u-boot-toradex_%`, `u-boot-distro-boot`, `linux-toradex-upstream_%`, `device-tree-overlays-mainline_%`) | `toradex-bsp-common-layer` | hooks | **C** |
| `dynamic-layers/toradex-nxp/` (`linux-toradex_%`, `device-tree-overlays_%`) | `toradex-nxp-layer` | hooks | **C** |
| `dynamic-layers/toradex-ti/` (`u-boot-toradex-ti_%`, `linux-toradex-ti_%`, `device-tree-overlays-ti_%`) | `toradex-ti-layer` | hooks | **C** |
| `dynamic-layers/meta-toradex-tezi/` (`tezi-run-metadata*`, `u-boot-distro-boot_%`) | `toradex-tezi` | HS-SE tiboot3 in recovery scripts, boot script hook | **C** |
| `dynamic-layers/meta-toradex-torizon/recipes-support/usermount/` | `meta-toradex-torizon` | ignore encrypted partition in usermount | **C** |

### 1.6 Scripts and templates

| File | Interface | Notes |
| :--- | :-------- | :---- |
| `recipes-bsp/u-boot/files/imx6_imx7_create_csf.sh` | env `TDX_IMX_HAB_CST_{SRK,SRK_CERT,CSF_CERT,IMG_CERT,BIN,ARGS}` | A (env names) |
| `recipes-bsp/u-boot/files/imx8m_sign.sh` | env `TDX_IMX_HAB_CST_*`, `TDX_IMX_HAB_CST_HSM` | A; comment "not available in Toradex" (E) |
| `recipes-bsp/u-boot/files/imx8m_copy_signature_node_to_fdts.sh` | arg | example comment `toradex,verdin-imx8mm…` (E) |
| `dynamic-layers/freescale/…/files/mx8_sign.sh` | env `TDX_IMX_HAB_CST_*` incl. `TEMPLATE`, `SGK_SUPP`, `HSM` | A |
| `recipes-bsp/imx-fuses/files/create_fuse_cmds.sh` + `README-template.txt` | env `TDX_IMX_HAB_CST_SRK_FUSE`, `TDX_SECURE_DEBUG_*` | A |
| `*.csf`, `*-template.fuse`, `ele-*.yaml.in` | — | no Toradex identifiers (E) |
| `recipes-core/tdx-enc-handler/files/tdx-enc.sh` | installed to `/usr/sbin`; `@@TDX_ENC_*@@` placeholders | B (file) / A (placeholders), see **D7** |
| `recipes-core/tdx-enc-handler/files/tdx-enc` | installed to `/etc/init.d` | B |

### 1.7 Patches (41)

| Group | Files | Author / Upstream-Status | Category |
| :---- | :---- | :----------------------- | :------- |
| Toradex U-Boot hardening | `0001-toradex-common-add-shared-hardening-modules`, `0002-toradex-dts-add-fragment-file…`, `000[1-8]-toradex-integrate-*-{downstream,upstream,k3}` (command whitelist, bootm, CLI, bootargs, load, cp, fastboot, setexpr) | R. Guerra Borin, *Inappropriate [Torizon OS specific]* | **C** (content E, DT ABI B) |
| Toradex secboot module | `0001-toradex-common-add-shared-secboot-module`, `0001-toradex-integrate-shared-secboot-module-{downstream,upstream}`, `0001-toradex-add-helper-to-detect-closed-device-{ele-downstream,k3}` | R. Guerra Borin / S. Prado, *Inappropriate [Torizon OS specific]* | C |
| Toradex fuse cmd extras | `000{6,8}-toradex-cmd-fuse-add-switch-for-quiet-operation-*`, `000{7,9}-toradex-cmd-fuse-add-readv-command-*` | *Pending* | C (candidate upstream) |
| HAB status | `u-boot-hab-status/0001-toradex-{common-add-hab-utilities-module,adjust-hab_status…,adjust-ahab_status…-{seco,ele}}` | J. Cordoba / S. Prado, *Inappropriate [Toradex specific]* | C |
| Generic U-Boot | `0001-binman-openssl-Make-generated-certificates-reproduci` (*Submitted*), `0001-binman-x509_cert-support-PKCS-11-URI…` (*Submitted*), `0001-lib-rsa-allow-matching-pkcs11-path-by-object-id` (*Backport*), `0001-lmb-prevent-alloc-overlap…-{k3,upst}` (*Pending*), `0001-imx8m{m,p}-binman-add-tee-node` (*Pending*) | | E |
| Downstream-specific | `0001-bootm-don-t-use-HAB-to-authenticate-FIT-image` (*Inappropriate [TorizonCore specific]*, applied to `apalis-imx8`, `colibri-imx8x`) | | C (selection) / E (content) |
| Kernel | `recipes-kernel/linux/files/0001-KEYS-trusted-revert-changes-introduced-by-NXP.patch` (no Upstream-Status) | S. Prado | E (missing `Upstream-Status`: yocto-check-layer will flag) |

Identifiers introduced by the Toradex U-Boot patches (all **inside U-Boot sources**):
`CONFIG_TDX_{SECBOOT_HARDENING[_DBG],CMD_WHITELIST,BOOTM_PROTECTION,CLI_PROTECTION,BOOTARGS_PROTECTION,LOAD_PROTECTION,CP_PROTECTION[_ALLOW_CMD],FB_PROTECTION[_ALLOW_CMD]}`,
files `common/tdx-{harden,secboot,hab-utils}.c`, `include/tdx-*.h`, `arch/arm/dts/tdx-secboot.dtsi`,
functions `tdx_*`, DT node **`/chosen/toradex,secure-boot`** with properties `disabled`,
`enable-cli-when-closed`, `required-bootargs`, `bootloader-commands/{allow,deny}-{open,closed}`, `needed`,
category macro `CMD_CAT_TDX_AUTOSEL_DT`.

### 1.8 Docs

| File | Toradex content |
| :--- | :-------------- |
| `README.md` | Title/body "for Toradex SoMs", toradex.com links, recommends meta-toradex-nxp/ti, "Toradex BSP 6.3.0+", `Copyright (C) 2024 Toradex AG` |
| `docs/README-secure-boot*.md`, `-encryption.md`, `-optee.md`, `-secure-debug*.md`, `-data-partition.md` | SoM support lists (Apalis/Colibri/Verdin/Aquila/SMARC/Lino/OSM), `TDX_*` variable tables, class names, `developer.toradex.com` / `git.toradex.com` links, `deploy/images/verdin-*/…` examples, Torizon OS mentions, Easy Installer |

---

## 2. Category A: renames (build-time names)

### 2.1 Layer collection

| Old | New | Where |
| :-- | :-- | :---- |
| `meta-toradex-security` (`BBFILE_COLLECTIONS`, `BBFILE_PATTERN_*`, `BBFILE_PRIORITY_*`, `LAYERDEPENDS_*`, `LAYERRECOMMENDS_*`, `LAYERSERIES_COMPAT_*`) | `hardware-security` | `conf/layer.conf` |

Downstream (Torizon) references the layer by **path** (`bblayers.conf` template, repo manifests), not
by collection name in `LAYERDEPENDS`, so the collection rename does not break it.

### 2.2 Classes and overrides

| Old class | New class | Old override | New override |
| :-------- | :-------- | :----------- | :----------- |
| `tdx-signed` | `hws-signed` | `:tdx-signed` | `:hws-signed` |
| `tdxref-signed` | see **D3** (`hws-signed-verity` recommended) | — | — |
| `tdx-signed-dmverity` | `hws-signed-dmverity` | `:tdx-signed-dmverity` | `:hws-signed-dmverity` |
| `tdx-signed-hsm-env` | `hws-signed-hsm-env` | — | — |
| `tdx-encrypted` | `hws-encrypted` | `:tdx-encrypted` | `:hws-encrypted` |
| `tdx-optee` | `hws-optee` | — | — |
| `tdx-secure-debug` | `hws-secure-debug` | `:tdx-secure-debug` | `:hws-secure-debug` |
| `tdx-tezi-data-partition` | *(C, see D11)* | `:tdx-tezi-data-partition` | *(C)* |
| `imx-hab` | `imx-hab` (unchanged, no `tdx`) | — | — |

Override consumers inside the layer: `u-boot-sec-features.inc`, `u-boot-distro-boot-sec-features.inc`,
`linux-sec-features.inc`, `tdx-optee.bbclass`, `tdx-tezi-data-partition.bbclass`, `optee-tdx.inc`,
`busybox_%`, `udev-extraconf_%`, `usermount_%`, `base-files_%`, `tezi-run-metadata_%`,
`device-tree-overlays*_%`, `imx-boot-secure-debug.inc`, `u-boot-hab.inc`.
Downstream consumers: `meta-toradex-torizon` uses `:tdx-signed` (7×) and `inherit tdx-signed`.

### 2.3 Variables, by feature group (proposed Phase 1 commit groups)

Rule: `TDX_<X>` → `HWS_<X>` unless noted. Counts are occurrences outside patches/docs.

**G1 Signing / FIT / HSM**

| Old | Notes |
| :-- | :---- |
| `TDX_SIGNED_HSM` | |
| `TDX_SIGNED_HSM_{TOKEN_PIN, PKCS11_MODULE_PROVIDER, PKCS11_MODULE_PATH, PKCS11_SOFTHSM_CONF, FIT_TOKEN_URL, FIT_TOKEN_LABEL, K3_BINMAN_KEY_URL, K3_OPENSSL_CONF, SUPPRESS_WARNINGS}` | |
| `TDX_SIGNING_CLASS` | **B**: written to `/etc/buildinfo` by Torizon (`IMAGE_BUILDINFO_VARS`) → see **D8** |

**G2 NXP i.MX HAB/AHAB** (`imx-hab.bbclass`, U-Boot/imx-boot includes, 3 sign scripts, fuse script)

`TDX_IMX_HAB_ENABLE`, `TDX_IMX_HAB_CST_{DIR, BIN, ARGS, BUILD_FROM_SOURCE, BUILD_WITH_PKCS11, CRYPTO, KEY_SIZE, KEY_EXP, DIG_ALGO, SRK_CA, SRK_INDEX, CERTS_DIR, SRK, SRK_FUSE, SRK_CERT, CSF_CERT, IMG_CERT, SGK_CERT, SGK_SUPP, TEMPLATE, HSM}`,
`TDX_IMX_HAB_{FUSE_SOC, SDP_CONFIGS, SDP_CONFIGS_INTERNAL, GEN_UBOOT_FUSING_CMD}`,
internal lists `TDX_IMX6_IMX7_CSF_ARTIFACTS`, `TDX_IMX8M_CSF_ARTIFACTS`, `TDX_IMX8M_FIT_ARTIFACTS`,
`TDX_UBOOT_HAB_PATCHES_DOWNSTREAM`, `TDX_UBOOT_HAB_STATUS_PATCHES{,_COMMON,_HAB,_SECO,_ELE}`.

- `TDX_IMX_HAB_CST_KEY_INDEX`: **E** (legacy guard: `bb.fatal` if set). Keep the guard on the old name and add one for the `HWS_` name.
- `TDX_IMX_HAB_GEN_UBOOT_FUSING_CMD`: lives in the Tezi include (C); rename only if D12 keeps it in core.
- `TDX_IMX_HAB_CST_HSM`: script-env only (no BitBake variable).

**G3 TI K3**

`TDX_K3_SECBOOT_{ENABLE, TARGET_HSSE_DEVICE, KEY_DIR, REPRODUCIBLE}`, `TDX_K3_SUPPRESS_HSSE_WARNINGS`.
`TDX_K3_HSSE_ENABLE`, `TDX_K3_HSSE_KEY_DIR`: **E** (legacy guard).

**G4 Hardening** (depends on **D4**)

`TDX_UBOOT_HARDENING_{ENABLE, ENABLE_DBG, ENABLE_CP_PROT, ENABLE_FB_PROT}`,
`TDX_SECBOOT_{REQUIRED_BOOTARGS, REQUIRED_BOOTARGS_DEFAULT, KARGS_OVERLAY, DEVICE_TREE_INCLUDES}`,
`TDX_SECBOOT_WL_{ALLOW_OPEN,ALLOW_CLOSED,DENY_OPEN,DENY_CLOSED,NEEDED}_CATEG{,_DEFAULT}`,
`TDX_CHECK_UNSUPP_BOOTMETH`, `TDX_DISABLE_UNSUPP_BOOTMETH`,
internal `TDX_UBOOT_HARDENING_PATCHES{,_COMMON,_DOWNSTREAM,_DOWNSTREAM_K3,_UPSTREAM}`,
`TDX_UBOOT_SECBOOT_PATCHES{,_COMMON,_DOWNSTREAM,_DOWNSTREAM_K3,_UPSTREAM}`.

- `TDX_SECBOOT_DEVICE_TREE_INCLUDES` value `tdx-secboot.dtsi` is a file inside U-Boot sources created by a patch (B/C): rename the variable but keep the value.
- `TDX_AMEND_{BOOT_SCRIPT,CONSOLE_ARGUMENT,ROOT_ARGUMENT}`: **C** (amend the Toradex `boot.cmd`), see D12. Torizon sets `TDX_AMEND_BOOT_SCRIPT:torizon-distro = "0"`.
- `CONFIG_TDX_*` in `u-boot-harden*.cfg`: **B/C** (Kconfig symbols defined by the Toradex patches). Not renamed.

**G5 dm-verity**: no `TDX_*` variables. Rename covers only the class/override (G-classes) and
`DM_VERITY_IMAGE` default (D).

**G6 Encryption**

`TDX_ENC_{KEY_BACKEND, CIPHER, KEY_LOCATION, KEY_DIR, KEY_FILE, STORAGE_TYPE, STORAGE_LOCATION, STORAGE_RESERVE, STORAGE_MOUNTPOINT, STORAGE_MKFS_ARGS, STORAGE_MOUNT_ARGS, PRESERVE_DATA, BACKUP_STORAGE_PCT}`.
**Values stay unchanged** (`/var/local/private/.keys`, `tdx-enc-key.blob`, `/run/encdata`: B).
`@@TDX_ENC_*@@` placeholders in `tdx-enc.sh` / `.service`: see **D7**.
Script-internal shell names (`TDX_ENC_DM_DEVICE`, `TDX_ENC_KEY_KEYRING_NAME`, `tdx_enc_*()`…) are not ABI but are installed on the device; see **D7**.

**G7 OP-TEE**

`TDX_OPTEE_{ENABLE, FTPM, PKCS11, FS_PARENT_PATH, FS_RPMB, FS_RPMB_DEV_ID, FS_RPMB_MODE, DEBUG, INSTALL_TESTS, PACKAGES_TESTS, ADDR_LOAD, ADDR_SIZE, ADD_FIT_NODES, DT_OVERLAY}`.
`@@TDX_OPTEE_ADDR_{LOAD,SIZE}@@` placeholders in `optee_overlay.dts` (build-time only).

**G8 Secure debug** (not in your original list; proposed as its own commit)

`TDX_SECURE_DEBUG_{ENABLE, ENABLE_INTERNAL, MODE, SUPPORTED_MACHINES, FUSE_TEMPLATE, KEY_FILE, TZ_KEY_FILE}`,
`TDX_SECURE_DEBUG_SJC_{HEO, DISABLE, FUSE_TEMPLATE}`,
`TDX_SECURE_DEBUG_ELE_{FUSE_TEMPLATE, SPSDK_FAMILY, OEM_DOMAINS, DC_CC_SOCU, DC_UUID, DCK_KEY, JTAG_DISABLE, AUTH_INTERNAL}`.

**G9 Data partition**: `TDX_TEZI_DATA_PARTITION_*`: **C**, see D11.

### 2.4 Functions

| Old | New | Kind | File |
| :-- | :-- | :--- | :--- |
| `default_tdx_uboot_hardening_enable` | `default_hws_uboot_hardening_enable` | python | `tdx-signed-harden.inc` |
| `tdx_signed_hsm_vars_export`, `_common`, `_k3_binman` | `hws_signed_hsm_vars_export…` | shell | `tdx-signed-hsm-env.bbclass` + 4 callers |
| `tdx_secure_debug_srk_signer` | `hws_secure_debug_srk_signer` | python | `imx-boot-secure-debug.inc` |
| `tdx_secure_debug_check_key_file` | `hws_secure_debug_check_key_file` | python | `tdx-secure-debug-sjc.inc` |
| `show_tdx_signed_warnings` | `show_hws_signed_warnings` | event handler | `tdx-signed-k3-secboot.inc` |
| `tdx_enc_*`, `tdx_run_user_check` | see D7 | shell (on device) | `tdx-enc.sh` |

No downstream caller of these functions was found in Torizon.

### 2.5 Files and recipes

| Old | New | Notes |
| :-- | :-- | :---- |
| `classes/include/signed/tdx-signed-*.inc` | `…/hws-signed-*.inc` | |
| `classes/include/secure-debug/tdx-secure-debug-{sjc,ele}.inc` | `…/hws-secure-debug-*.inc` | |
| `recipes-security/optee/optee-tdx.inc` | `optee-hws.inc` | |
| `recipes-security/optee/include/optee-tdx-<machine>.inc` | (C, see D13) | |
| `recipes-core/busybox/busybox/tdx-enc-handler-requirements.cfg` | `hws-enc-handler-requirements.cfg` | build-only fragment |
| `recipes-core/tdx-enc-handler/` (recipe + package `tdx-enc-handler`) | **B**, see D6 | |
| `recipes-images/images/tdx-reference-ramdisk-image.bb` | **C/B**, see D12 | name appears in deploy/FIT artifact names |

---

## 3. Category B: runtime ABI (default: keep, flagged)

| # | Item | Where defined | Why it is ABI | Proposal |
| :- | :--- | :------------ | :------------ | :------- |
| B1 | Key blob file name `tdx-enc-key.blob` | `TDX_ENC_KEY_FILE` default | read on every boot; on existing devices | keep value |
| B2 | Key dir `/var/local/private/.keys` | `TDX_ENC_KEY_DIR` default | idem | keep |
| B3 | Kernel keyring key name `tdxenc` and session `tdxenc_session` | `tdx-enc.sh` | **also persisted in the on-disk key block** (`keyname=tdxenc`, checked on read → mismatch = new key = data loss) with `TDX_ENC_KEY_LOCATION=partition` | keep, **never rename** |
| B4 | dm-crypt device `encdata` (`/dev/mapper/encdata`), mount point `/run/encdata` | `tdx-enc.sh`, class default | used by fstab/apps | keep |
| B5 | `/usr/sbin/tdx-enc.sh`, `/etc/init.d/tdx-enc`, `/var/run/tdx-enc.pid`, `/var/log/tdx-enc.log` | `tdx-enc-handler` | paths on device, may be referenced by apps/docs | keep |
| B6 | systemd unit `tdx-enc-handler.service` | idem | other layers can order against it | keep |
| B7 | Package name `tdx-enc-handler` | recipe | `IMAGE_INSTALL`, package feeds/OTA diffs | keep (D6) |
| B8 | User hook `/usr/sbin/encryption_allowed` | `tdx-enc.sh` | customer-provided script contract | keep |
| B9 | `/etc/modprobe.d/sa2ul.conf` (K3), `/etc/udev/rules.d/99-tpm.rules`, `tee-supplicant.rules`, `udev mount.ignorelist`, `/etc/usermount/ignorelist` entries | various | on device | keep |
| B10 | DT node `/chosen/toradex,secure-boot` + properties (`required-bootargs`, `disabled`, `enable-cli-when-closed`, `bootloader-commands/*`, `needed`) | `add-secboot-kargs-overlay.inc`, U-Boot patches | read by **already-deployed U-Boot** from the FIT overlay; renaming breaks updates | keep |
| B11 | FIT configuration names `conf-${MACHINE}-secboot-kargs_overlay.dtbo`, `conf-optee_*`; DTBO `${MACHINE_PREFIX}_optee_overlay.dtbo` | harden/OP-TEE includes | selected by boot scripts / overlays.txt | keep (no `tdx`) |
| B12 | `tdx-secboot.dtsi`, `CONFIG_TDX_*` Kconfig symbols | U-Boot patches | defconfig fragments in other layers may set `CONFIG_TDX_*` | keep (patch content) |
| B13 | OP-TEE REE FS root `/data/tee`; RPMB dev id | `TDX_OPTEE_FS_*` defaults | secure objects stored there | keep |
| B14 | Data partition label `DATA`, mountpoint `/data`, fstab line | `tdx-tezi-data-partition` | on device | keep |
| B15 | `/usr/share/misc/dm-verity.env` in initramfs | ramdisk image | read by `initramfs-module-dmverity` | keep (no `tdx`) |
| B16 | `/etc/buildinfo` content: `TDX_SIGNING_CLASS = …`, `OVERRIDES` containing `tdx-signed` | Torizon `IMAGE_BUILDINFO_VARS` | visible on device; may be parsed by tooling | D8, D9 |
| B17 | Deploy artifact names `fitImage-tdx-reference-ramdisk-image-*`, `tdx-reference-ramdisk-image-*`, `fuse-cmds.txt`, `imx-config.fuse`, `secure-debug/{dc,dat}.yaml` | images/classes | consumed by Tezi image.json, TorizonCore Builder, factory scripts | keep names (D12) |
| B18 | U-Boot env var `prog_secure_boot_fuses` (Tezi env) | `tdx-signed-imx-hab-tezi.inc` | factory flow | keep (C) |

---

## 4. Category C: Toradex-only content

| # | Item | Files | Proposal |
| :- | :--- | :---- | :------- |
| C1 | **Easy Installer (Tezi)** glue: `tdx-tezi-data-partition` class + `TDX_TEZI_DATA_PARTITION_*`; `TEZI_ROOT_*`, image-size hook and `wic` removal in dm-verity; `tdx-signed-dmverity-tezi.inc`; `tdx-signed-imx-hab-tezi.inc`; `signed/machine/*.inc` (`FIRMWARE_BINARY[<product id>]`, `TEZI_UBOOT_BINARY_RECOVERY`); `TEZI_EXTERNAL_KERNEL_DEVICETREE_BOOT` in OP-TEE; `dynamic-layers/meta-toradex-tezi/*` | see §1 | **Move to `meta-hardware-security-toradex`**. Until the split: isolate (no behavior change) under `classes/include/toradex/` + `dynamic-layers/toradex-*`, gated by the `toradex-tezi` dynamic layer instead of `teziimg` in `IMAGE_FSTYPES`. A generic data-partition (wic) feature can come later. |
| C2 | **Toradex U-Boot hardening & secboot patches** (§1.7) | `u-boot-harden.inc`, `u-boot-secure-boot.inc`, `u-boot-hab-status.inc`, patches | **Generalize**: keep in core as the layer's U-Boot hardening backend (D4); select patch flavor by U-Boot source, not by machine (D13). Patch content untouched (E). Push the *Pending* fuse/lmb/binman ones upstream. |
| C3 | **Hooks on Toradex recipes**: `u-boot-toradex`, `u-boot-toradex-ti`, `linux-toradex`, `linux-toradex-ti`, `linux-toradex-upstream`, `device-tree-overlays{,-mainline,-ti}`, `u-boot-distro-boot`, `tezi-run-metadata`, `usermount` | dynamic-layers | Move to the toradex sublayer; core gets a generic attachment (§6). |
| C4 | **Toradex boot script amendments** (`TDX_AMEND_*`, `tdxargs`, `rootfsargs_set`, `FITCONF_FDT_OVERLAYS`, `KERNEL_BOOTCMD`, `DTB_PREFIX`) | `u-boot-distro-boot-{harden,optee}.inc` | Move to the toradex sublayer. |
| C5 | **Reference image** `tdx-reference-ramdisk-image` and default `DM_VERITY_IMAGE ?= "tdx-reference-minimal-image"` | recipe, dm-verity class | Generalize: `hws-verity-initramfs` (or keep name, see D12), no default `DM_VERITY_IMAGE` (fatal if unset), or `core-image-minimal`. |
| C6 | **Per-machine values in core**: `TDX_SECBOOT_REQUIRED_BOOTARGS_DEFAULT:<16 machines>`; `CP_PROT_SUPPORTED`/`FB_PROT_SUPPORTED:<8 machines>`; patch selection `:apalis-imx8 :colibri-imx8x :toradex-smarc-imx95 :verdin-imx95 :aquila-imx95 :lino-imx93 :toradex-osm-imx93`; `0001-bootm-don-t-use-HAB…` for `apalis-imx8`, `colibri-imx8x`; `u-boot-optee.inc` (`verdin-imx8mp`, `toradex-smarc-imx8mp`, `verdin-imx8mm`); OP-TEE `optee/machine/*.inc` (3) and `optee-tdx-<machine>.inc` (14); `validate_optee_support` list (14 machines); `TDX_SECURE_DEBUG_SUPPORTED_MACHINES` (12 machines) | various | Move machine data to the toradex sublayer as machine-keyed includes; core keyed on SoC overrides + capability variables (D13). |
| C7 | **NXP CST source** from `github.com/toradex/imx-code-signing-tool` | `imx-code-signing-tool-native_4.0.1.bb` | Fetched, not committed; BSD-3-Clause, so rule 7 is not violated. Classify as Toradex-hosted; see D16. |
| C8 | **README / docs** branding, SoM lists, `developer.toradex.com`/`git.toradex.com` links, Toradex BSP version requirement | `README.md`, `docs/*` | Rewrite generic docs by SoC family; move "validated on" SoM lists and Toradex links to the sublayer README; add fork note to README (rule 4). |
| C9 | **Torizon usermount** ignore list | `dynamic-layers/meta-toradex-torizon/` | Move to the toradex sublayer (or Torizon itself). |
| C10 | On-device branding strings: unit `Description=Encryption handler for Toradex modules`, recipe `SUMMARY`, image `SUMMARY`, script header comment | enc handler, ramdisk image | Generalize text (D19). |

---

## 5. Category D: policy leaks

| # | Leak | Where | Effect | Proposal |
| :- | :--- | :---- | :----- | :------- |
| D-a | `tpm2-tools_%.bbappend` unconditionally drops `tpm2-abrmd` and **replaces** `RDEPENDS` | `recipes-tpm2/` | every build with the layer in `BBLAYERS` changes tpm2-tools (yocto-check-layer signature failure) | gate on `:hws-encrypted` + TPM backend |
| D-b | `optee-client_%.bbappend` unconditionally sets `UNPACKDIR = "${WORKDIR}"`, `COMPATIBLE_MACHINE = "${MACHINE}"`, `CFG_TEE_FS_PARENT_PATH`, udev rule | `recipes-security/optee/` | idem; `UNPACKDIR` override is **wrong on styhead+/wrynose** | gate on OP-TEE enable; drop `UNPACKDIR` hack on ≥ styhead |
| D-c | `optee-ftpm_%.bbappend` unconditional `COMPATIBLE_MACHINE = "${MACHINE}"` | idem | idem | gate |
| D-d | `DM_VERITY_IMAGE ?= "tdx-reference-minimal-image"` | dm-verity class | Toradex image as default | see C5 |
| D-e | `SKIP_META_SECURITY_SANITY_CHECK = "1"` hard assignment | dm-verity class | silences meta-security globally | `?=` + document |
| D-f | `KERNEL_IMAGETYPE:forcevariable = "fitImage"` | FIT include | users cannot override except with forcevariable | keep (FIT is the contract), document; revisit in UKI work |
| D-g | `UBOOT_SIGN_ENABLE:k3r5 = "0"`, `:k3` stronger assignments to beat meta-ti | FIT include | SoC policy in generic include | move to K3 capability include (no behavior change) |
| D-h | `do_install:append:k3` blacklists `sa2ul` in the enc handler | enc recipe | SoC quirk inside generic recipe | move to K3 capability include |
| D-i | `SRC_URI:append:pn-linux-toradex` for the NXP trusted-keys revert | `linux-dm-crypt.inc` | keyed on Toradex recipe name; `linux-imx` (same NXP downstream code) not covered | key on "NXP downstream kernel" capability (behavior change for linux-imx users, flag) |
| D-j | Main-branch-only leaks (`root=LABEL=otaroot`, `cfs-support`, `torizon` override checks) | `main` only | **already removed on scarthgap** | nothing to do if D1 = scarthgap |
| D-k | Unprefixed layer-private variables (`CP_PROT_SUPPORTED`, `FB_PROT_SUPPORTED`, `CONSOLE_BAUDRATE_MISSING`, `UART_BASE_ADDR`, `OPTEE_BIN_EXT`, `OPTEE_OS_EXTRA_MACHINE_ARGS`, `OPTEE_OS_DEBUG_OPTS`, `OPTEE_OS_ENCRYPTION_OPTS`, `OPTEE_CLIENT_RPMB_*`, `SRC_URI_TPM`, `RDEPENDS_TPM`, `PKCS11_PATCH`, `KERNEL_BOOTCMD_OPTEE`, `DTB_PREFIX_OPTEE`) | various | namespace pollution | out of scope for Phase 1 (no `tdx`), D18 |

---

## 6. Hook coupling and proposed generic attachment

| Generic logic | Today attached only to | Missing for | Proposal |
| :------------ | :--------------------- | :---------- | :------- |
| `linux-sec-features.inc` (dm-verity, dm-crypt, OP-TEE, HSM FIT signing) | `linux-toradex`, `linux-toradex-ti`, `linux-toradex-upstream` (Toradex dyn. layers), `linux-imx` (freescale) | `linux-yocto` (qemu), `linux-ti-staging`, any custom kernel | **`hws-kernel` class appended to `KERNEL_CLASSES`** by the feature classes (the layer already uses `KERNEL_CLASSES:append = " kernel-fitimage"`). This reaches every recipe that inherits `kernel`. Keep `.cfg` fragments for kernels with fragment support; sanity-warn otherwise. Opt-out var `HWS_KERNEL_HOOK = "0"`. |
| `u-boot-sec-features.inc` (FIT pubkey, HAB, K3, hardening, OP-TEE) | `u-boot-toradex`, `u-boot-toradex-ti`, `u-boot-imx` (on `main`: also oe-core `u-boot`; **dropped on scarthgap**) | oe-core `u-boot` (qemuarm64 test), `u-boot-ti-staging`, custom U-Boot | **`hws-uboot` class** holding the logic; thin bbappends `inherit hws-uboot` per known provider in the matching dynamic layer (`core` → `u-boot`, `freescale-layer` → `u-boot-imx`, `meta-ti-bsp` → `u-boot-ti-staging`, toradex sublayer → `u-boot-toradex*`); a SanityCheck that **fails** when a signing class is active and `PREFERRED_PROVIDER_virtual/bootloader` didn't inherit `hws-uboot` (marker var). Custom recipes: `inherit hws-uboot`. |
| Kernel-cmdline overlay (`add-secboot-kargs-overlay.inc`) and OP-TEE DT overlay | Toradex `device-tree-overlays*` + `toradex-devicetree.bbclass` naming | everyone else | Core: small `hws-secboot-overlay` recipe that builds the DTBO and adds it to the FIT through oe-core `KERNEL_DEVICETREE`/FIT overlay support; Toradex sublayer keeps current overlay-recipe integration. |
| Boot script integration (`u-boot-distro-boot-*`) | Toradex `u-boot-distro-boot` | — | stays Toradex (C4); core documents the contract (FIT conf name + required bootargs). |
| U-Boot patch flavor (upstream / NXP downstream / TI downstream) | machine overrides | any non-Toradex machine on NXP/TI downstream U-Boot | `HWS_UBOOT_FLAVOR ?= "upstream"`, set to `nxp-downstream` / `ti-downstream` from the provider (`u-boot-imx`, `u-boot-ti-staging`, `:k3`) or by machine conf. |
| OP-TEE per-machine includes (`optee-tdx-${MACHINE}.inc`, `include/optee/machine/${MACHINE}.inc`) | `include` by `${MACHINE}` | any non-Toradex machine (fatal) | SoC-family defaults in core + machine conf/sublayer sets `HWS_OPTEE_UART_BASE`, `HWS_OPTEE_PLATFORM`, `HWS_OPTEE_FS_RPMB_DEV_ID`, load addr/size. |
| Supported-machine checks (OP-TEE, secure debug, CP/FB protection) | hardcoded Toradex machine lists | everyone else (fatal) | capability vars `HWS_OPTEE_VALIDATED`, `HWS_SECURE_DEBUG_VALIDATED`, `HWS_UBOOT_CP_PROT_SUPPORTED`… set by sublayer; unvalidated = warning (D13). |

---

## 7. Category E: keep as is

- Content of all patches (authors, `Signed-off-by`, `Upstream-Status`, code identifiers `tdx_*`, `CONFIG_TDX_*`, `toradex,…` compatibles).
- `COPYING.MIT`, `Copyright (C) 2024 Toradex AG` in README, `Copyright 2025 Toradex` in `optee_overlay.dts`, git history.
- Legacy-name guards: `TDX_IMX_HAB_CST_KEY_INDEX`, `TDX_K3_HSSE_ENABLE`, `TDX_K3_HSSE_KEY_DIR` (fatal-if-set checks); add equivalent guards for the new names.
- Comments with example compatibles (`imx8m_copy_signature_node_to_fdts.sh`), the downstream remark in `imx8m_sign.sh`.
- `imx-hab` class name, fuse templates, CSF templates, ELE yaml templates, `yubico-piv-tool`, `pkcs11-provider`/`libfaketime` native extends.

---

## 8. Downstream compatibility findings (input for `hws-tdx-compat`)

Found in `meta-toradex-torizon` / `torizon-os`:

| Usage | Example | Implication for compat |
| :---- | :------ | :--------------------- |
| inherit legacy class | `torizon-signed.bbclass: inherit tdx-signed` | wrapper `tdx-signed.bbclass` = `inherit hws-signed hws-tdx-compat` + warning |
| legacy override in conditions | `FUSE_SUPPORT_SIGNED_BUILD:tdx-signed`, `RESIZE_HELPER:tdx-signed`, `IMAGE_FSTYPES:append:tdx-signed` | compat re-adds `:tdx-signed` to `DISTROOVERRIDES` when `hws-signed` active |
| **override-qualified assignment of legacy var** | `TDX_SECBOOT_REQUIRED_BOOTARGS:tdx-signed = "${TOS_…}"`, `TDX_AMEND_BOOT_SCRIPT:torizon-distro = "0"` | mapping must work on the *expanded* legacy value, after overrides |
| **reads of legacy vars** | `d.getVar('TDX_IMX_HAB_ENABLE')`, `${TDX_IMX_HAB_ENABLE}` in shell, `TDX_SIGNING_CLASS` into buildinfo | compat must also expose legacy names *from* new ones (reverse alias) |
| Torizon-owned `TDX_*` vars | `TDX_UBOOT_FUSE_PATCHES*` (defined in Torizon) | compat must use an **explicit** mapping list, never a `TDX_*` prefix wildcard |
| Layer referenced by path | `bblayers.conf` template, repo manifests (`torizon/*.xml`, `tdxsec/*.xml`) | collection rename safe; directory name is the consumer's choice |

---

## 9. Proposed rename map (summary, Phase 1 commit order)

| # | Commit (one logical group each) | Scope |
| :- | :------------------------------ | :---- |
| 0 | `docs: add fork inventory` + README fork note | this file, README header note (rule 4) |
| 1 | `rename: layer collection meta-toradex-security -> hardware-security` | `conf/layer.conf` |
| 2 | `rename: tdx-signed* classes and overrides -> hws-signed*` | classes, includes, `:tdx-signed[-dmverity]` users, docs |
| 3 | `rename: tdx-encrypted class and override -> hws-encrypted` | |
| 4 | `rename: tdx-optee class -> hws-optee` | |
| 5 | `rename: tdx-secure-debug class and override -> hws-secure-debug` | |
| 6 | `rename: TDX_SIGNED_HSM_* -> HWS_SIGNED_HSM_*` (+ `TDX_SIGNING_CLASS` per D8) | G1 |
| 7 | `rename: TDX_IMX_HAB_* -> HWS_IMX_HAB_*` | G2 incl. script env and internal lists |
| 8 | `rename: TDX_K3_* -> HWS_K3_*` | G3 |
| 9 | `rename: TDX_UBOOT_HARDENING_*/TDX_SECBOOT_* -> HWS_*` | G4 (if D4 = core) |
| 10 | `rename: TDX_ENC_* -> HWS_ENC_*` | G6 (values unchanged) |
| 11 | `rename: TDX_OPTEE_* -> HWS_OPTEE_*` | G7 |
| 12 | `rename: TDX_SECURE_DEBUG_* -> HWS_SECURE_DEBUG_*` | G8 |
| 13 | `rename: tdx_* functions -> hws_*` | §2.4 |
| 14 | `rename: tdx-* file names -> hws-*` | §2.5 (minus B items) |
| 15 | `compat: add hws-tdx-compat class and legacy wrapper classes` | compat + `tdx-signed`, `tdxref-signed`, `tdx-signed-dmverity`, `tdx-encrypted`, `tdx-optee`, `tdx-secure-debug`, `tdx-signed-hsm-env` wrappers |
| 16 | `audit: list remaining tdx/toradex occurrences` | appendix to this file / `MIGRATION.md` |

Wrappers and compat land in the same commit as each class rename if you prefer that every commit
stays buildable for Torizon (see D10).

---

## 10. Decisions

**Update (2026-10-13): no separate Toradex sublayer for now.** Toradex-only content
(categories C1–C10) stays in this layer; where this document says "move to the
`meta-hardware-security-toradex` sublayer", read "keep in this layer, grouped and clearly
marked as Toradex-specific". Whether to split it out is decided later.

**Update (2026-10-13): Toradex-specific content stays where it is.** It is moved only
when a move brings a clear advantage, decided case by case. The Toradex BSP team keeps
adding features upstream, so keeping upstream's file layout makes comparing with
upstream and picking changes easier. Tooling to sync with upstream is deferred.

**Follow-up (2026-10-13): make the generic features usable beyond NXP i.MX and TI K3.**
Targets are x86-64 (UEFI Secure Boot + UKI), QEMU (`qemuarm64`, `qemux86-64`) and NVIDIA,
then other SoC families. Known gaps are listed in `docs/hardware-support.md` (kernel and
U-Boot integration only for i.MX/Toradex recipes, machine allowlists, Toradex defaults);
they overlap with D13/D14/D-d and are addressed starting in Phase 2.

**Status (2026-10-13): all recommendations below were accepted.** Work happens on branch
`hws/scarthgap`, created from `scarthgap-7.x.y` @ `29f2e45`. For D13 (c), unvalidated
machines stay fatal for now.

1. **D1. Base branch.** `main` (wrynose, stale) or `scarthgap-7.x.y` (current, your stable build)?
   *Recommendation:* work on `scarthgap-7.x.y` in a branch `hws/scarthgap` and do all phases there. Forward-port `main`'s 7 wrynose-compat commits later. Keep `LAYERSERIES_COMPAT = "scarthgap walnascar"` for now. CLAUDE.md should be updated to say "branch scarthgap-7.x.y".
2. **D2. Commit this inventory?** Phase 0 said "no changes", so the file is currently **untracked**.
   *Recommendation:* commit it as commit 0 of Phase 1 together with the README fork note.
3. **D3. Name for `tdxref-signed`.** Options: (a) `hwsref-signed` (mechanical), (b) `hws-signed-verity` (descriptive: signed boot + dm-verity rootfs).
   *Recommendation:* (b). "ref" refers to Toradex reference images, and choosing the final name now avoids renaming twice. The `tdxref-signed` wrapper keeps old configs working.
4. **D4. U-Boot hardening: core or Toradex?** The build variables (`TDX_UBOOT_HARDENING_*`, `TDX_SECBOOT_*`) drive Toradex-written U-Boot patches.
   *Recommendation:* keep it in core as a generic hardening backend and rename the variables to `HWS_*`. Patch content stays (E). The DT node `toradex,secure-boot`, `CONFIG_TDX_*` and `tdx-secboot.dtsi` stay (B). The `TDX_AMEND_*` boot-script parts go to the toradex sublayer (C4).
5. **D5. Confirm the B list (§3)** is frozen: values of `TDX_ENC_KEY_FILE`/`TDX_ENC_KEY_DIR`, keyring name `tdxenc`, unit/script names, the DT node, `/etc/buildinfo` content.
   *Recommendation:* freeze all of them. B3 (`tdxenc`) is data-loss critical.
6. **D6. `tdx-enc-handler` recipe/package name.** Options: (a) keep, (b) rename to `hws-enc-handler` with `RPROVIDES/RREPLACES/RCONFLICTS = "tdx-enc-handler"` and keep the on-device file names.
   *Recommendation:* (a) for now. Revisit when the handler is generalized.
7. **D7. `tdx-enc.sh` internals.** Options: (a) rename only the `@@TDX_ENC_*@@` build placeholders, so the **installed script is byte-identical**, (b) also rename internal shell names (`TDX_ENC_*`, `tdx_enc_*`). (b) changes the installed file but not its behavior.
   *Recommendation:* (a) in Phase 1, which keeps the golden comparison clean. (b) later, as an explicit cleanup.
8. **D8. `TDX_SIGNING_CLASS`.** It lands in Torizon's `/etc/buildinfo`.
   *Recommendation:* new `HWS_SIGNING_CLASS` (values `hws-signed` / `hws-signed-verity`). The compat class sets `TDX_SIGNING_CLASS` to the legacy value (`tdx-signed` / `tdxref-signed`). Torizon overrides it to `torizon-signed` anyway.
9. **D9. `OVERRIDES` in `/etc/buildinfo`.** With compat active, it will contain both `hws-signed` and `tdx-signed`, which changes on-device text.
   *Recommendation:* accept it and document it in `MIGRATION.md` (informational only).
10. **D10. Compat class design.** It needs: (a) an explicit old→new table, never a prefix wildcard (Torizon owns `TDX_UBOOT_FUSE_PATCHES*`); (b) forward mapping of user-set legacy values, including override-qualified ones like `TDX_SECBOOT_REQUIRED_BOOTARGS:tdx-signed`; (c) reverse exposure so legacy reads keep working (`TDX_IMX_HAB_ENABLE`); (d) one deprecation warning per legacy variable actually used; (e) re-adding legacy overrides. The legacy wrappers inherit compat automatically.
    *Recommendation:* approve this design. Also decide whether every rename commit must stay buildable for Torizon (wrappers + compat added incrementally) or compat lands once at the end. I recommend **incremental**, because it allows bisecting.
11. **D11. `tdx-tezi-data-partition`.**
    *Recommendation:* C. Leave it untouched (name and variables) in Phase 1, move it to the toradex sublayer later, and add a generic wic-based data partition feature as separate future work.
12. **D12. Tezi/Toradex glue in core** (C1, C3, C4, C9) and the `tdx-reference-ramdisk-image` name (B17).
    *Recommendation:* Phase 2 isolates them under `dynamic-layers/toradex-*` and `classes/include/toradex/`, without deleting anything and without changing behavior, ready to move out. Keep the ramdisk image name for now (deploy artifact names) and add a generic alias later.
13. **D13. Per-machine values and "supported machines" lists** (C6).
    *Recommendation:* (a) introduce `HWS_UBOOT_FLAVOR` to select the patch set; (b) move machine data to the sublayer; (c) replace fatal machine lists with capability variables. Note that (c) is a **behavior change** for unvalidated machines (fatal → warning): keep it fatal, or switch to a warning?
14. **D14. Generic hook mechanism (§6).**
    *Recommendation:* use `KERNEL_CLASSES` for the kernel, and a `hws-uboot` class plus per-provider bbappends and a sanity check for U-Boot, in Phase 2. Also re-add an oe-core `u-boot` hook so `qemuarm64` FIT tests work. That is a behavior change for non-Toradex builds only.
15. **D15. Unconditional bbappends (D-a, D-b, D-c).** Gating them changes builds that **don't** use the features, so it is a behavior change for those builds only.
    *Recommendation:* gate them in Phase 2, one commit each.
16. **D16. NXP CST recipe** fetches from `github.com/toradex/imx-code-signing-tool`.
    *Recommendation:* keep it (BSD-3, fetched, not committed). Check whether an NXP-hosted source exists to point `SRC_URI` at, otherwise move it to the sublayer.
17. **D17. Layer directory and collection names.**
    *Recommendation:* collection `hardware-security`, directory `meta-hardware-security`, and no alias collection: no downstream `LAYERDEPENDS` on `meta-toradex-security` was found.
18. **D18. Unprefixed private variables (D-k).**
    *Recommendation:* leave them out of Phase 1 and decide later whether to namespace them as `HWS_*`.
19. **D19. On-device text** (unit `Description=`, `SUMMARY`).
    *Recommendation:* generalize the text in Phase 2. The unit file content changes, but its name and behavior don't.
20. **D20. Missing `Upstream-Status`** on the kernel patch (yocto-check-layer error).
    *Recommendation:* add `Upstream-Status: Inappropriate [NXP downstream specific]` in Phase 2. That is a metadata-only change.
