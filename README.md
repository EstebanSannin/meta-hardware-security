# meta-hardware-security

OpenEmbedded/Yocto layer providing security features for embedded Linux devices:
secure boot, verified root filesystem, data-at-rest encryption, Trusted Execution
Environment and secure debug.

The goal is a **hardware-agnostic** layer: the features are generic, and what depends on
the SoC (how the boot ROM verifies the first bootloader, where keys are stored, how debug
access is gated) is provided by SoC-vendor backends selected from the machine
configuration.

## Origin

This layer is based on the work done in
[toradex/meta-toradex-security](https://github.com/toradex/meta-toradex-security)
(branch `scarthgap-7.x.y`), developed by Toradex for its System on Modules. The original
copyright notices and the MIT license ([COPYING.MIT](COPYING.MIT)) are kept.

Build-time names were migrated from the Toradex namespace (`tdx`, `TDX_`) to `hws` /
`HWS_`. Existing configurations keep working through a transitional compatibility class;
see [MIGRATION.md](MIGRATION.md). Names that end up on devices (key blob files, systemd
units, device-tree nodes read by U-Boot, ...) were deliberately not renamed, so already
deployed devices can be updated.

## Hardware support

Today the features are implemented for **NXP i.MX** (i.MX6, i.MX7, i.MX8M, i.MX8, i.MX8X,
i.MX9x) and **TI K3** (AM62x, AM62Px, AM69) SoCs, and validated on Toradex SoMs.

Support for other hardware, such as **x86-64** (UEFI Secure Boot), **QEMU** machines and
**NVIDIA** platforms, is planned but **not available yet**.

See [docs/hardware-support.md](docs/hardware-support.md) for the support matrix by SoC
family, the list of validated devices and the known gaps for other hardware.

## Features

- Secure boot
  - Bootloader signature checking (SoC-specific: NXP HAB/AHAB, TI K3 HS).
  - U-Boot hardening.
  - FIT image signature checking (kernel, DTBs and ramdisk).
  - Root filesystem verification via `dm-verity`.
  - Signing with keys stored in an HSM (PKCS#11).
- Data-at-rest encryption
  - Encryption key management via the Linux Trusted Keys subsystem (CAAM, TPM or TEE
    as trust source).
  - Block device encryption with `dm-crypt`.
- TEE (Trusted Execution Environment)
  - OP-TEE, including fTPM, PKCS#11 and RPMB secure storage.
- Secure debug
  - Generation of the artifacts required to restrict or authenticate JTAG debug access,
    using the mechanism provided by the SoC.

## Documentation

| Documentation | Description |
| :------------ | :---------- |
| [docs/hardware-support.md](docs/hardware-support.md) | Support by SoC family, validated devices, planned platforms and known gaps |
| [docs/README-secure-boot.md](docs/README-secure-boot.md) | Secure boot: overview, U-Boot hardening, FIT and rootfs signing |
| [docs/README-secure-boot-imx.md](docs/README-secure-boot-imx.md) | Bootloader signing on NXP i.MX SoCs (HAB/AHAB) |
| [docs/README-secure-boot-k3.md](docs/README-secure-boot-k3.md) | Bootloader signing on TI K3 SoCs (e.g. AM62x, AM69) |
| [docs/README-secure-boot-hsm.md](docs/README-secure-boot-hsm.md) | Signing with keys stored in an HSM (PKCS#11) |
| [docs/README-encryption.md](docs/README-encryption.md) | Data-at-rest encryption |
| [docs/README-optee.md](docs/README-optee.md) | Running OP-TEE together with the Linux kernel |
| [docs/README-secure-debug.md](docs/README-secure-debug.md) | Secure debug: overview |
| [docs/README-secure-debug-sjc.md](docs/README-secure-debug-sjc.md) | Secure debug on NXP i.MX6, i.MX7, i.MX8M, i.MX8 and i.MX8X (SJC) |
| [docs/README-secure-debug-ele.md](docs/README-secure-debug-ele.md) | Secure debug on NXP i.MX9x (ELE) |
| [docs/README-data-partition.md](docs/README-data-partition.md) | Additional data partition (Toradex Easy Installer images only) |
| [MIGRATION.md](MIGRATION.md) | Renames from meta-toradex-security and the compatibility class |

## Layer dependencies

This layer depends on:

```
URI: git://git.openembedded.org/openembedded-core
layers: meta
branch: scarthgap
revision: HEAD

URI: git://git.openembedded.org/meta-openembedded
layers: meta-oe
branch: scarthgap
revision: HEAD

URI: git://git.yoctoproject.org/meta-security
branch: scarthgap
revision: HEAD
```

SoC-specific parts are enabled automatically when the corresponding vendor layer is
present: `meta-freescale` (NXP i.MX) and `meta-ti-bsp` (TI K3).

For Toradex SoMs, the layer is used together with the Toradex BSP layers (Toradex
Embedded Linux BSP 6.3.0 and newer), which it recommends:

```
URI: git://git.toradex.com/meta-toradex-nxp.git
branch: scarthgap
revision: HEAD

URI: git://git.toradex.com/meta-toradex-ti.git
branch: scarthgap
revision: HEAD
```

## License

All metadata is MIT licensed unless otherwise stated. Source code and binaries included in
tree for individual recipes are under the LICENSE stated in each recipe (.bb file) unless
otherwise stated.

The original README document is Copyright (C) 2024 Toradex AG.
