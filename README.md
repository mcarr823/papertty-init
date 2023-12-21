# papertty-init

papertty-init automates the process of installing PaperTTY.

It performs all of the necessary setup, including enabling SPI, installing PaperTTY's dependencies, and making it run automatically on startup.

Just install Raspberry Pi OS, run this script, and PaperTTY will be running and ready to use.


## GUI or CLI

This script can be run either from a desktop (Raspberry Pi OS) or a command-line environment (Raspberry Pi OS Lite).

Both versions do the following
- enable SPI
- download and install papertty's dependencies
- setup a python virtual environment for papertty
- install papertty and update it to the latest version from git
- offer to download either the official version of papertty or my forked version
- optionally installs gpiozero (needed for Raspberry Pi 5 support)
- enables or prompts to enable automatic login
- asks which waveshare panel you're using and sets up a script to run it
- downloads Ubuntu fonts and uses the Mono font for papertty

The desktop version does the following
- replaces the default desktop environment with XFCE
- automatically switches to tty1 OR sets up tmux, so keyboard input is shown on the e-ink panel by default
- disables power management, screen locking, and screen blanking as much as possible


## Install

If you're using Raspberry Pi OS with a desktop environment, open a terminal and paste this command:

```bash
bash -c "$(curl https://sh.mcarr.dev/gui)"
```

If you're using Raspberry Pi OS Lite in a text-only environment, type in:

```bash
bash -c "$(curl https://sh.mcarr.dev/cli)"
```

## After installation

You will likely want to change PaperTTY's startup script to suit your panel.

For example, you might need to switch between landscape and portrait, or change the font size.

You can find the script which runs papertty on startup in /home/pi/.local/bin/papertty-init/startpapertty.sh

You can find a complete list of different options in the official PaperTTY repository: https://github.com/joukos/PaperTTY
