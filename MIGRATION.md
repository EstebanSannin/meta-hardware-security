# Migration from meta-toradex-security

This layer is a fork of `meta-toradex-security`. Build-time names are being migrated from
the Toradex namespace (`tdx`, `TDX_`) to the `hws` namespace (`hws`, `HWS_`). This file lists
every rename.

Runtime ABI is **not** renamed: anything installed on a device or read by already-built
binaries keeps its name and value (for example `tdx-enc-key.blob`,
`/var/local/private/.keys`, the `tdxenc` keyring key, `tdx-enc-handler.service`, the
`/chosen/toradex,secure-boot` device-tree node). See `docs/fork-inventory.md`, section 3.

## Compatibility shim (transitional)

Existing configurations can keep using the legacy names while they migrate.
<!-- Filled in by the commit adding classes/hws-tdx-compat.bbclass. -->

## Rename table

Columns: old name, new name, type (layer, class, override, variable, function, file, recipe),
and whether the compatibility shim covers it.

| Old | New | Type | Compat shim |
| :-- | :-- | :--- | :---------- |
