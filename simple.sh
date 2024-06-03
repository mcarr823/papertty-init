#!/bin/bash

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 1 ;;  
            [Nn]*) return 0 ;;
        esac
    done
}

installdir=~/.local/share/papertty-init_venv

#Check if the user is root
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root."
  echo "This script should be run as an ordinary user who has sudo privileges."
  exit
fi


echo ""
echo "*********************"
echo "* PaperTTY Init *"
echo "*********************"
echo ""
echo "This script will install PaperTTY inside of a python virtual environment."
echo "It will not run papertty on boot, change any system settings, or download any fonts."
echo ""
echo "It can be run from a Raspberry Pi running Raspberry Pi OS (lite or full)."
echo "Or from any PC running Debian 12 or a derivative (eg. Ubuntu or Linux Mint)."
echo ""
yes_or_no "Do you want to continue?"
shouldContinue=$?

if [ $shouldContinue -eq 0 ]; then
  echo "Aborting installation"
  exit;
fi


# TODO: option to update instead
if [ -d "$installdir" ]; then
  echo ""
  echo ""
  echo ""
  echo "$installdir already exists."
  yes_or_no "Do you want to replace the existing venv?"
  shouldContinue=$?

  if [ $shouldContinue -eq 0 ]; then
    echo "Aborting installation"
    exit;
  fi

  echo "Deleting existing venv..."
  rm -rf $installdir

fi


echo ""
echo ""
echo ""
echo "Creating setup directory"
mkdir -p $installdir

echo ""
echo "Updating apt cache"
sudo apt update

echo ""
echo "Installing dependencies"
sudo apt install -y python3-venv python3-pip libopenjp2-7 libtiff5-dev libjpeg-dev git libfreetype-dev wget unzip

echo ""
echo "Creating python virtual environment"
python3 -m venv $installdir

# Install papertty's dependencies manually, by specifying the versions.
# These versions should be checked and replaced at some point.
# They were copied from the official Papertty's pyproject.toml

echo ""
echo "Installing papertty dependencies - This may take a few minutes"
$installdir/bin/pip3 install --force-reinstall -q "click==7.1.2" #8.1.7 is latest
$installdir/bin/pip3 install --force-reinstall -q "Pillow==7.1.2" #10.3.0 is latest
$installdir/bin/pip3 install --force-reinstall -q "spidev==3.4" #3.6 is latest
$installdir/bin/pip3 install --force-reinstall -q "vncdotool==1.0.0" #1.2.0 is latest

# Needed for running PaperTTY via USB for IT8951 driver boards
$installdir/bin/pip3 install --force-reinstall -q "pyusb==1.2.1"

# gpiozero enables support for non-RPi devices, and will be needed
# for the Pi 5 if/when support for that is figured out.
$installdir/bin/pip3 install --force-reinstall -q "gpiozero==2.0.1"

# lgpio is the default pin library used by gpiozero, and currently
# seems like the only one with Pi 5 support.
$installdir/bin/pip3 install --force-reinstall -q "lgpio==0.2.2.0"

# pigpio enables remote targets.
# ie. You can use pigpio to send data from a desktop PC running PaperTTY
# to a raspberry pi connected to an e-ink screen.
$installdir/bin/pip3 install --force-reinstall -q "pigpio==1.78"

# Download the latest version of papertty from git.
# Note that python* is used since the exact version of python3 might change.
# Also note that it grabs my forked version of PaperTTY rather than
# the official one.

echo ""
echo "Downloading a newer version of papertty"
cd $installdir/lib/python*/site-packages/
git clone https://github.com/mcarr823/PaperTTY papertty_repo
ln -s papertty_repo/papertty papertty

# Create a script to run the app within the venv

cd $installdir/bin/
touch papertty
chmod +x papertty
echo """#!$installdir/bin/python3
# -*- coding: utf-8 -*-
import re
import sys
from papertty.papertty import cli
if __name__ == '__main__':
    sys.argv[0] = re.sub(r'(-script\.pyw|\.exe)?$', '', sys.argv[0])
    sys.exit(cli())""" >> papertty

# TODO dir/bin/papertty file
#$installdir/bin/pip3 install pigpio




echo ""
echo ""
echo ""
echo "Installation has finished."
echo ""
echo "You can now run papertty from $installdir/bin/papertty"