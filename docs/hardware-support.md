# Hardware support

This layer aims to provide its security features on any embedded Linux device. Each
feature is split into a generic part and SoC-vendor backends: how a key is stored, how
the boot ROM verifies the first bootloader, or how debug access is gated is SoC-specific
and lives in a backend selected from the machine configuration.

This page describes what works **today**, what is **planned**, and the gaps that still
prevent the generic parts from being used on other hardware.

## Current support by SoC family

| Feature | NXP i.MX6 / i.MX7 / i.MX8M | NXP i.MX8 / i.MX8X | NXP i.MX9x | TI K3 (AM62x, AM62Px, AM69) | Other hardware |
| :------ | :------------------------- | :----------------- | :--------- | :-------------------------- | :------------- |
| Bootloader signature checking | HAB | AHAB (SECO) | AHAB (ELE) | HS-SE / HS-FS | not yet |
| FIT image signature checking | yes | yes | yes | yes | generic, needs kernel/U-Boot integration (see gaps) |
| U-Boot hardening | yes | yes | yes | yes (A53 U-Boot only) | not yet |
| Rootfs verification (dm-verity) | yes | yes | yes | yes | generic, needs kernel integration (see gaps) |
| Data-at-rest encryption | CAAM, TPM, TEE (not CAAM on i.MX6ULL) | CAAM, TPM, TEE | TPM, TEE | TPM, TEE | TPM/TEE backends are generic, need kernel integration (see gaps) |
| OP-TEE | yes | — | yes | yes | not yet (machine allowlist) |
| Secure debug | SJC (not authenticated mode on i.MX8MP) | SJC | ELE (i.MX95) | not yet | not yet |
| HSM-backed signing (PKCS#11) | yes | yes | yes | yes | follows the features above |

"yes" means the feature is implemented and was validated on at least one device of that
family (see [Validated devices](#validated-devices)). Feature-specific limitations are
described in each feature's document.

## Target platforms (planned, not supported yet)

The goal is to support, among others:

- **x86-64**, with UEFI Secure Boot and a Unified Kernel Image (UKI) as the second stage
  instead of a signed FIT image, TPM 2.0 for key storage.
- **QEMU** (`qemuarm64`, `qemux86-64`), as reference and CI targets for the generic parts
  (FIT signing, dm-verity, TPM-backed encryption with a software TPM).
- **NVIDIA** Jetson platforms.
- Other SoC families (e.g. Rockchip, MediaTek, Qualcomm) through additional backends.

None of these is supported yet. Contributions follow the same model: a backend for the
first boot stage and SoC capability settings, reusing the generic parts.

## Known gaps for other hardware

These are the main reasons the generic parts don't work out of the box on other
hardware yet; they are tracked as follow-up work:

- **Kernel integration** (addressed): the kernel side of the features (configuration
  fragments for dm-verity, dm-crypt, Trusted Keys and OP-TEE, HSM-backed FIT signing)
  is in the `hws-kernel` class, which the feature classes add to `KERNEL_CLASSES`, so it
  reaches every kernel recipe that inherits `kernel.bbclass`. The fragments need a
  kernel recipe that merges `.cfg` fragments from `SRC_URI` (e.g. `linux-yocto`); this
  is not yet validated on a non-NXP kernel. Some fragments are SoC-specific (e.g. the
  `caam` key backend) and only make sense on the matching SoC.
- **U-Boot integration** (partly addressed): the U-Boot side of the layer is attached to
  `u-boot-toradex`, `u-boot-toradex-ti` and `u-boot-imx` with the Toradex U-Boot patch
  set (`HWS_UBOOT_FLAVOR = "toradex"`), and to the OpenEmbedded Core `u-boot` and TI
  `u-boot-ti-staging` recipes with the generic parts only (`HWS_UBOOT_FLAVOR =
  "generic"`: FIT signature enforcement, key embedding and SoC bootloader signing, no
  U-Boot hardening). The generic flavor is not yet validated on hardware. Other U-Boot
  recipes need a one-line bbappend (a build warning explains it).
- **Machine allowlists**: OP-TEE and secure debug check the machine name against a list
  of validated machines (`HWS_OPTEE_SUPPORTED_MACHINES`,
  `HWS_SECURE_DEBUG_SUPPORTED_MACHINES`) and stop the build otherwise. A new machine can
  be added to the list from a configuration file, after providing its settings.
- **Toradex defaults**: some defaults assume Toradex BSP images (e.g. the default
  `DM_VERITY_IMAGE`, the boot script amendments of the U-Boot hardening, the data
  partition support which requires Toradex Easy Installer images).

## Validated devices

The features were developed and validated in
[meta-toradex-security](https://github.com/toradex/meta-toradex-security), the layer this
one is based on, on the following Toradex System on Modules (SoMs). For these devices the
layer is used together with the Toradex BSP layers (Toradex Embedded Linux BSP 6.3.0 and
newer).

| Toradex SoM | SoC | Secure boot | Encryption | OP-TEE | Secure debug |
| :---------- | :-- | :---------: | :--------: | :----: | :----------: |
| Apalis iMX6 | i.MX6Q/D | yes | yes | yes | yes |
| Apalis iMX8 | i.MX8QM/QP | yes | yes | | yes |
| Aquila AM69 | AM69 | yes | yes | yes | |
| Aquila iMX95 | i.MX95 | yes | yes | yes | yes |
| Colibri iMX6 / iMX6DL | i.MX6DL/S | yes | yes | yes | yes |
| Colibri iMX6ULL (1GB eMMC variant only) | i.MX6ULL | yes | yes | | yes |
| Colibri iMX7D (1GB eMMC variant only) | i.MX7D | yes | yes | yes | yes |
| Colibri iMX8X | i.MX8QXP/DX | yes | yes | | yes |
| Lino iMX93 | i.MX93 | yes | yes | yes | |
| OSM iMX93 | i.MX93 | yes | yes | yes | |
| SMARC iMX8MP | i.MX8MP | yes | yes | yes | yes |
| SMARC iMX95 | i.MX95 | yes | yes | yes | yes |
| Verdin AM62 | AM62x | yes | yes (TPM or TEE) | yes | |
| Verdin AM62P | AM62Px | yes | yes (TPM or TEE) | yes | |
| Verdin iMX8MM | i.MX8MM | yes | yes | yes | yes |
| Verdin iMX8MP | i.MX8MP | yes | yes | yes | yes |
| Verdin iMX95 | i.MX95 | yes | yes | yes | yes |

More information on the Toradex SoMs: https://www.toradex.com/computer-on-modules
