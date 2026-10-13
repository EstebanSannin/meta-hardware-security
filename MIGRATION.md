# Migration from meta-toradex-security

This layer is a fork of `meta-toradex-security`. Build-time names are being migrated from
the Toradex namespace (`tdx`, `TDX_`) to the `hws` namespace (`hws`, `HWS_`). This file lists
every rename.

Runtime ABI is **not** renamed: anything installed on a device or read by already-built
binaries keeps its name and value (for example `tdx-enc-key.blob`,
`/var/local/private/.keys`, the `tdxenc` keyring key, `tdx-enc-handler.service`, the
`/chosen/toradex,secure-boot` device-tree node). See `docs/fork-inventory.md`, section 3.

## Compatibility shim (transitional)

Existing configurations can keep using the legacy names while they migrate. The
`hws-tdx-compat` class is **transitional** and will be removed in a future release.

How to enable it:

- It is enabled automatically when a legacy class is inherited (`tdx-signed`,
  `tdxref-signed`, `tdx-encrypted`, ...). These legacy classes are thin wrappers: they
  inherit `hws-tdx-compat` and the new class, and print a deprecation warning.
- When only legacy variables or overrides are used, with the new classes, enable it
  explicitly and list it **before** the hws classes:

  ```
  INHERIT += "hws-tdx-compat hws-signed"
  ```

What it does:

- **Variables.** Only the legacy variables listed in the rename table below are mapped;
  other `TDX_*` variables (for example ones defined by other layers) are not touched. For
  each mapped variable:
  - everything set on the legacy name moves to the new name: plain value, `:append`,
    `:prepend`, `:remove` and override-qualified assignments such as
    `TDX_SECBOOT_REQUIRED_BOOTARGS:tdx-signed = "..."`;
  - a deprecation warning is printed for each legacy variable actually used;
  - if both the legacy and the new name are set in configuration files, the new name wins
    and a warning is printed;
  - the legacy name stays readable: it becomes an alias of the new one, so code
    reading `d.getVar('TDX_X')` or `${TDX_X}` keeps working (when the new variable is
    unset the legacy name reads as an empty string rather than `None`);
  - legacy assignments made in configuration files and in classes inherited before the
    compat class are applied at parse time, so they also drive parse-time conditionals
    (`require ${@...}`). Legacy assignments made in recipes or bbappends are applied
    when the recipe is finalized, so task code sees them but parse-time conditionals
    don't.
- **Overrides.** Legacy overrides (`:tdx-signed`, ...) are added to `DISTROOVERRIDES`
  when the corresponding hws class is inherited. Images that record `OVERRIDES` (for
  example in `/etc/buildinfo`) will therefore list both the hws and the legacy override.

## Rename table

Columns: old name, new name, type (layer, class, override, variable, function, file, recipe),
and whether the compatibility shim covers it.

| Old | New | Type | Compat shim |
| :-- | :-- | :--- | :---------- |
| `meta-toradex-security` | `hardware-security` | layer collection (`BBFILE_COLLECTIONS`, `LAYERSERIES_COMPAT_*`, ...) | no (rename `LAYERDEPENDS`/`LAYERRECOMMENDS` entries; the checkout directory name in `BBLAYERS` is up to the user) |
| `tdx-signed` | `hws-signed` | class | yes (legacy wrapper class) |
| `tdxref-signed` | `hws-signed-verity` | class | yes (legacy wrapper class) |
| `tdx-signed-dmverity` | `hws-signed-dmverity` | class | yes (legacy wrapper class) |
| `tdx-signed-hsm-env` | `hws-signed-hsm-env` | class | yes (legacy wrapper class) |
| `:tdx-signed` | `:hws-signed` | override | yes (added to `DISTROOVERRIDES` when `hws-signed` is inherited) |
| `:tdx-signed-dmverity` | `:hws-signed-dmverity` | override | yes (added to `DISTROOVERRIDES` when `hws-signed-dmverity` is inherited) |
| `TDX_SIGNING_CLASS` value `tdx-signed` / `tdxref-signed` | `hws-signed` / `hws-signed-verity` | variable value | yes (the legacy wrapper classes set the legacy value) |
| `tdx-encrypted` | `hws-encrypted` | class | yes (legacy wrapper class) |
| `:tdx-encrypted` | `:hws-encrypted` | override | yes (added to `DISTROOVERRIDES` when `hws-encrypted` is inherited) |
| `tdx-optee` | `hws-optee` | class | yes (legacy wrapper class) |
| `tdx-secure-debug` | `hws-secure-debug` | class | yes (legacy wrapper class) |
| `:tdx-secure-debug` | `:hws-secure-debug` | override | yes (added to `DISTROOVERRIDES` when `hws-secure-debug` is inherited) |
| `TDX_SIGNED_HSM` | `HWS_SIGNED_HSM` | variable | yes |
| `TDX_SIGNED_HSM_TOKEN_PIN` | `HWS_SIGNED_HSM_TOKEN_PIN` | variable | yes |
| `TDX_SIGNED_HSM_PKCS11_MODULE_PROVIDER` | `HWS_SIGNED_HSM_PKCS11_MODULE_PROVIDER` | variable | yes |
| `TDX_SIGNED_HSM_PKCS11_MODULE_PATH` | `HWS_SIGNED_HSM_PKCS11_MODULE_PATH` | variable | yes |
| `TDX_SIGNED_HSM_PKCS11_SOFTHSM_CONF` | `HWS_SIGNED_HSM_PKCS11_SOFTHSM_CONF` | variable | yes |
| `TDX_SIGNED_HSM_FIT_TOKEN_URL` | `HWS_SIGNED_HSM_FIT_TOKEN_URL` | variable | yes |
| `TDX_SIGNED_HSM_FIT_TOKEN_LABEL` | `HWS_SIGNED_HSM_FIT_TOKEN_LABEL` | variable | yes |
| `TDX_SIGNED_HSM_K3_BINMAN_KEY_URL` | `HWS_SIGNED_HSM_K3_BINMAN_KEY_URL` | variable | yes |
| `TDX_SIGNED_HSM_K3_OPENSSL_CONF` | `HWS_SIGNED_HSM_K3_OPENSSL_CONF` | variable | yes |
| `TDX_SIGNED_HSM_SUPPRESS_WARNINGS` | `HWS_SIGNED_HSM_SUPPRESS_WARNINGS` | variable | yes |
| `TDX_SIGNING_CLASS` | `HWS_SIGNING_CLASS` | variable | partly (the legacy wrapper classes set `TDX_SIGNING_CLASS` to the legacy class name) |
| `TDX_IMX_HAB_ENABLE` | `HWS_IMX_HAB_ENABLE` | variable | yes |
| `TDX_IMX_HAB_CST_DIR` | `HWS_IMX_HAB_CST_DIR` | variable | yes |
| `TDX_IMX_HAB_CST_BIN` | `HWS_IMX_HAB_CST_BIN` | variable | yes |
| `TDX_IMX_HAB_CST_ARGS` | `HWS_IMX_HAB_CST_ARGS` | variable | yes |
| `TDX_IMX_HAB_CST_BUILD_FROM_SOURCE` | `HWS_IMX_HAB_CST_BUILD_FROM_SOURCE` | variable | yes |
| `TDX_IMX_HAB_CST_BUILD_WITH_PKCS11` | `HWS_IMX_HAB_CST_BUILD_WITH_PKCS11` | variable | yes |
| `TDX_IMX_HAB_CST_CRYPTO` | `HWS_IMX_HAB_CST_CRYPTO` | variable | yes |
| `TDX_IMX_HAB_CST_KEY_SIZE` | `HWS_IMX_HAB_CST_KEY_SIZE` | variable | yes |
| `TDX_IMX_HAB_CST_KEY_EXP` | `HWS_IMX_HAB_CST_KEY_EXP` | variable | yes |
| `TDX_IMX_HAB_CST_DIG_ALGO` | `HWS_IMX_HAB_CST_DIG_ALGO` | variable | yes |
| `TDX_IMX_HAB_CST_SRK_CA` | `HWS_IMX_HAB_CST_SRK_CA` | variable | yes |
| `TDX_IMX_HAB_CST_SRK_INDEX` | `HWS_IMX_HAB_CST_SRK_INDEX` | variable | yes |
| `TDX_IMX_HAB_CST_CERTS_DIR` | `HWS_IMX_HAB_CST_CERTS_DIR` | variable | yes |
| `TDX_IMX_HAB_CST_SRK` | `HWS_IMX_HAB_CST_SRK` | variable | yes |
| `TDX_IMX_HAB_CST_SRK_FUSE` | `HWS_IMX_HAB_CST_SRK_FUSE` | variable | yes |
| `TDX_IMX_HAB_CST_SRK_CERT` | `HWS_IMX_HAB_CST_SRK_CERT` | variable | yes |
| `TDX_IMX_HAB_CST_CSF_CERT` | `HWS_IMX_HAB_CST_CSF_CERT` | variable | yes |
| `TDX_IMX_HAB_CST_IMG_CERT` | `HWS_IMX_HAB_CST_IMG_CERT` | variable | yes |
| `TDX_IMX_HAB_CST_SGK_CERT` | `HWS_IMX_HAB_CST_SGK_CERT` | variable | yes |
| `TDX_IMX_HAB_CST_SGK_SUPP` | `HWS_IMX_HAB_CST_SGK_SUPP` | variable | yes |
| `TDX_IMX_HAB_CST_TEMPLATE` | `HWS_IMX_HAB_CST_TEMPLATE` | variable | yes |
| `TDX_IMX_HAB_CST_HSM` | `HWS_IMX_HAB_CST_HSM` | variable | yes |
| `TDX_IMX_HAB_FUSE_SOC` | `HWS_IMX_HAB_FUSE_SOC` | variable | yes |
| `TDX_IMX_HAB_SDP_CONFIGS` | `HWS_IMX_HAB_SDP_CONFIGS` | variable | yes |
| `TDX_IMX_HAB_SDP_CONFIGS_INTERNAL` | `HWS_IMX_HAB_SDP_CONFIGS_INTERNAL` | variable | yes |
| `TDX_IMX6_IMX7_CSF_ARTIFACTS` | `HWS_IMX6_IMX7_CSF_ARTIFACTS` | variable | yes |
| `TDX_IMX8M_CSF_ARTIFACTS` | `HWS_IMX8M_CSF_ARTIFACTS` | variable | yes |
| `TDX_IMX8M_FIT_ARTIFACTS` | `HWS_IMX8M_FIT_ARTIFACTS` | variable | yes |
| `TDX_UBOOT_HAB_PATCHES_DOWNSTREAM` | `HWS_UBOOT_HAB_PATCHES_DOWNSTREAM` | variable | yes |
| `TDX_UBOOT_HAB_STATUS_PATCHES` | `HWS_UBOOT_HAB_STATUS_PATCHES` | variable | yes |
| `TDX_UBOOT_HAB_STATUS_PATCHES_COMMON` | `HWS_UBOOT_HAB_STATUS_PATCHES_COMMON` | variable | yes |
| `TDX_UBOOT_HAB_STATUS_PATCHES_HAB` | `HWS_UBOOT_HAB_STATUS_PATCHES_HAB` | variable | yes |
| `TDX_UBOOT_HAB_STATUS_PATCHES_SECO` | `HWS_UBOOT_HAB_STATUS_PATCHES_SECO` | variable | yes |
| `TDX_UBOOT_HAB_STATUS_PATCHES_ELE` | `HWS_UBOOT_HAB_STATUS_PATCHES_ELE` | variable | yes |
