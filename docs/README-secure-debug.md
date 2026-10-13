# Secure Debug

Modern SoCs usually expose a JTAG/debug interface that is enabled by default. If left open in production, this interface may allow an attacker with physical access to halt the CPU, inspect memory, extract secrets, or inject code.

This is especially important for devices that use features such as secure boot and data-at-rest encryption. An open debug interface can become a practical way to bypass those protections.

To mitigate this risk, this layer provides a feature called **Secure Debug**.

Secure Debug is currently supported on NXP i.MX6, i.MX7, i.MX8M, i.MX8, i.MX8X and i.MX95 SoCs. See [hardware-support.md](hardware-support.md) for the list of validated devices.

Support for additional SoC families is planned. Since each SoC family may use a different hardware mechanism to restrict debug access, new platforms may introduce additional variables or different provisioning requirements.

## Overview

Supporting secure debug requires three things from the SoC: a hardware block able to gate the debug port, a persistent place to record the desired policy (e.g. OTP e-fuses), and an authentication mechanism that can reopen debug access to whoever holds the right secret. Vendors implement all three differently. For example, NXP uses a symmetric challenge/response on its older families and a signed, credential-based exchange on the newer ones.

The layer therefore exposes a small, policy-oriented interface that stays the same across SoC families, and delegates the hardware specifics to a per-family backend selected automatically from the machine. The user chooses *what* the device should allow, and the backend decides *how* that is achieved on the target.

When secure debug is enabled, provisioning data is generated at build time. For example, on iMX8-based SoCs the layer generates the required fuse commands and appends them to the `fuse-cmds.txt` and `imx-config.fuse` files already produced by the HAB/AHAB flow. Nothing is programmed by the build itself. The commands are executed later, by the user, on the device.

Devices based on NXP i.MX6, i.MX7, i.MX8M, i.MX8 and i.MX8X SoCs use the System JTAG Controller (SJC) backend. For details on the SJC backend, including its configuration variables, key management and provisioning, see the [README-secure-debug-sjc.md](README-secure-debug-sjc.md) file.

Devices based on NXP i.MX9 SoCs use the EdgeLock Secure Enclave (ELE) backend. For details on the ELE backend, including its configuration variables, debug credentials and provisioning, see the [README-secure-debug-ele.md](README-secure-debug-ele.md) file.

## Enabling Secure Debug

To enable Secure Debug, inherit the `hws-secure-debug` class in your distro configuration or `local.conf`:

```bash
INHERIT += "hws-secure-debug"
```

Secure Debug requires secure boot to be enabled. The build fails if Secure Debug is enabled without secure boot.

If Secure Debug is enabled on unsupported machines, the build fails at sanity-check time with an explicit error, so an unsupported target cannot silently produce an image without the expected provisioning data.

## Configuration variables

The following generic variables are available:

| Variable | Description | Default value |
| :------- | :---------- | :------------ |
| `HWS_SECURE_DEBUG_ENABLE` | Enable or disable the Secure Debug feature. Allowed values: `0` or `1`. | `1` |
| `HWS_SECURE_DEBUG_MODE` | Debug policy. Allowed values: `authenticated` or `no-debug`. | `authenticated` |

Each backend adds its own variables. For SJC-based SoCs, see [Configuration variables](README-secure-debug-sjc.md#configuration-variables) in the SJC documentation. For ELE-based SoCs, see [Configuration variables](README-secure-debug-ele.md#configuration-variables) in the ELE documentation.

To disable security-sensitive debug access instead of using authenticated JTAG:

```bash
INHERIT += "hws-secure-debug"

HWS_SECURE_DEBUG_MODE = "no-debug"
```

## Board-level prerequisites

Authenticated debug also depends on the carrier board exposing the debug interface, which is outside the control of this layer. Check this before concluding that a fused device is faulty.

## Verifying authenticated debug

Debug probe support for the authentication flow differs between SoCs even within the same vendor tooling, and is the most common obstacle to verifying this feature. Confirm that your probe implements the mechanism for your SoC **before** programming any fuse, ideally on a device you can afford to lose debug access to.

## Limitations

- Only the SJC and ELE backends are implemented, covering iMX6, iMX7, iMX8M, iMX8, iMX8X and iMX95. The iMX93 and TI K3 are not supported yet.
