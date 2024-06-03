# papertty-init

papertty-init automates the process of installing PaperTTY.

You can use the minimal installer (not specific to the Raspberry Pi), which will only install PaperTTY and its dependencies.

Or you can use the full installer (Raspberry Pi only), which will perform all of the necessary setup for a Raspberry Pi, such as enabling SPI, enabling automatic login, and making PaperTTY run automatically on startup.


## Minimal install - Raspberry Pi or Desktop PC

You can perform a minimal installation of PaperTTY by running

```bash
bash -c "$(curl https://sh.mcarr.dev/simple)"
```

This installer doesn't perform any operations specific to the Rpi, or create any startup scripts, or change your system settings.

It simply installs PaperTTY and its dependencies on your system.

This script can be run from Raspberry Pi OS (lite or full), or from a desktop computer running Debian 12 (or a derivative, such as Ubuntu or Linux Mint).

In theory this should also work from WSL on Windows, as long as the environment is based on a supported Linux flavor. However, this has not actually been verified.


## Full install (GUI or CLI) - Raspberry Pi only

The full installation scripts can be run either from a desktop (Raspberry Pi OS) or a command-line environment (Raspberry Pi OS Lite).

Both versions do the following
- enable SPI
- download and install papertty's dependencies
- setup a python virtual environment for papertty
- install papertty and update it to the latest version from git
- offer to download either the official version of papertty or my forked version
- optionally installs gpiozero
- enables or prompts to enable automatic login
- asks which waveshare panel you're using and sets up a script to run it
- downloads Ubuntu fonts and uses the Mono font for papertty

The desktop version does the following
- replaces the default desktop environment with XFCE
- automatically switches to tty1 OR sets up tmux, so keyboard input is shown on the e-ink panel by default
- disables power management, screen locking, and screen blanking as much as possible



If you're using Raspberry Pi OS with a desktop environment, open a terminal and paste this command:

```bash
bash -c "$(curl https://sh.mcarr.dev/gui)"
```

If you're using Raspberry Pi OS Lite in a text-only environment, type in:

```bash
bash -c "$(curl https://sh.mcarr.dev/cli)"
```

## Full installer - After installation

You will likely want to change PaperTTY's startup script to suit your panel.

For example, you might need to switch between landscape and portrait, or change the font size.

You can find the script which runs papertty on startup in /home/pi/.local/bin/papertty-init/startpapertty.sh

You can find a complete list of different options in the official PaperTTY repository: https://github.com/joukos/PaperTTY
