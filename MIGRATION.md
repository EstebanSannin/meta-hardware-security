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
  - the legacy name stays readable: it becomes an alias of the new one
    (`TDX_X = "${HWS_X}"`), so code reading `d.getVar('TDX_X')` or `${TDX_X}` keeps
    working;
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
