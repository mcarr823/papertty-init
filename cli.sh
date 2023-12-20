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

fontdir=~/.local/share/fonts/papertty-init
bindir=~/.local/bin/papertty-init
installdir=~/.local/share/papertty-init_venv

#Check if the user is root
if [ "$EUID" -eq 0 ]; then
  echo "Do not run this script as root."
  echo "This script should be run as an ordinary user who has sudo privileges."
  echo "eg. The default 'pi' user."
  exit
fi


echo ""
echo "*********************"
echo "* PaperTTY CLI Init *"
echo "*********************"
echo ""
echo "This script will set up a raspberry pi to automatically run papertty on boot."
echo "It is intended to be used in a text-only environment. eg. Raspberry Pi OS Lite"
echo ""
echo "You can use it with a GUI if you want, but it will not start automatically."
echo "If you want a GUI, you should look at using the gui.sh script instead."
echo ""
echo "Note that this script should ONLY be run from a raspberry pi."
echo "It assumes that you are using a fresh installation of Raspberry Pi OS Lite."
echo "Other devices and operating systems are unlikely to work."
echo ""
echo "Also note that this script has only been tested on the latest version of Raspberry Pi OS Lite (based on Debian 12 Bookworm)."
echo "Older versions of Raspberry Pi OS should theoretically still work, but have not been tested."
echo ""
yes_or_no "Do you want to continue?"
shouldContinue=$?

if [ $shouldContinue -eq 0 ]; then
  echo "Aborting installation"
  exit;
fi

echo ""
echo ""
echo "You will now be asked a few questions about your desired setup."

#First, let's try to determine which raspberry pi model is being used.
#The pi model should be a string like "Raspberry Pi 4 Model B Rev 1.5"
#The part we want is the first number (4, in the example above).
#"cut" starts at 1, not 0. So we want char 14.
pimodel=$(cat /proc/device-tree/model | cut -c14)

#If the number is 5 or higher, set a flag to let the rest of the program know
#that we're targeting a new model.
#This is important because of changes to the GPIO pin memory mapping as of the rpi5.
if [ $pimodel -gt 4 ]; then
  pi5=1
else
  pi5=0
fi

echo ""
echo ""
echo ""
echo "#1 PaperTTY version"
if [ $pi5 -eq 1 ]; then
    echo "Skipping this question, as the official repository does not support the raspberry pi 5 yet."
    read -p "Press Enter to continue"
    usefork=1
else
    echo "There are two places this script can download PaperTTY from."
    echo "The first is the official git repository: https://github.com/joukos/PaperTTY"
    echo "The second is my fork of PaperTTY: https://github.com/mcarr823/PaperTTY"
    echo ""
    echo "All of the changes in my fork have been submitted as pull requests to the official repository."
    echo "However, not all of them have been merged."
    echo "At this point in time, the main difference between the two repositories is that my forked version supports the Raspberry Pi 5, and implements an overhauled terminal mode."
    echo "If you want to use papertty on a rpi5, you will currently need the forked version."
    echo ""
    yes_or_no "Use forked version?"
    usefork=$?
fi

echo ""
echo ""
echo ""
echo "#2 GPIO library"
if [ $pi5 -eq 1 ]; then
    echo "Skipping this question, as the official repository doesn't support the raspberry pi 5 yet."
    read -p "Press Enter to continue"
    gpiozero=1
elif [ $usefork -eq 0 ]; then
    echo "Skipping this question, as the official repository doesn't support gpiozero yet."
    read -p "Press Enter to continue"
    gpiozero=0
else
    echo "Which GPIO library do you want to use?"
    echo "There are 2 options: gpiozero and RPi.GPIO"
    echo ""
    echo "RPi.GPIO has been used with PaperTTY for longer, and it is well-tested."
    echo "However, it is no longer updated, and it does not work with the raspberry pi 5 or newer devices."
    echo ""
    echo "gpiozero hasn't been used with PaperTTY for as long, or as intensively."
    echo "But it is regularly updated and it is supported by newer devices."
    echo ""
    echo "There should not be any major performance differences between the two."
    echo ""
    yes_or_no "Use gpiozero?"
    gpiozero=$?
fi

echo ""
echo ""
echo ""
echo "#3 Panel driver"
echo "Which waveshare panel are you going to be using?"
echo "If you are using a HD panel, then you probably want the IT8951 driver."
echo "All of the supported models and drivers will be listed in the next step."
read -p "Press Enter to continue"

echo "Supported panels/drivers are:"

panels=(
    EPD1in54
    EPD1in54b
    EPD1in54c
    EPD2in7
    EPD2in7b
    EPD2in9
    EPD2in9b
    EPD2in13
    EPD2in13b
    EPD2in13d
    EPD2in13v2
    EPD3in7
    EPD4in2
    EPD4in2b
    EPD5in65f
    EPD5in83
    EPD5in83b
    EPD7in5
    EPD7in5b_V2
    EPD7in5v2
    EPD7in5b
    IT8951
)
while true; do
    for i in "${panels[@]}"; do
        echo "$i"
    done
    read -p "Enter one of the choices above: " panel
    found=0
    for i in "${panels[@]}"; do
        if [ "$panel" == "$i" ]; then
            found=1
            break
        fi
    done
    if [ $found -eq 1 ]; then
        break
    else
        echo "No match found."
    fi
done

echo ""
echo ""
echo "Your settings are as follows:"
if [ $usefork -eq 1 ]; then
    echo "PaperTTY version: forked"
else
    echo "PaperTTY version: official"
fi
if [ $gpiozero -eq 1 ]; then
    echo "Library: gpiozero"
else
    echo "Library: RPi.GPIO"
fi
echo "Panel/driver: $panel"
echo ""
echo "Is this all correct?"
echo "Installation will start immediately if you say yes."
echo "It will also take a while to install, especially on a slow internet connection."
yes_or_no "Proceed?"
allCorrect=$?
if [ $allCorrect -eq 0 ]; then
  echo "Aborting installation"
  exit
fi




#Newer versions of Debian require libtiff5-dev instead of libtiff5
if grep -q 'VERSION="12 (bookworm)"' /etc/os-release; then
  tiffdep="libtiff5-dev"
else
  tiffdep="libtiff5"
fi

echo ""
echo ""
echo ""
echo "Creating setup directories"
mkdir -p $fontdir $bindir $autodir

echo "Updating apt cache"
sudo apt update

echo "Installing dependencies"
sudo apt install -y python3-venv python3-pip libopenjp2-7 $tiffdep libjpeg-dev

echo "Creating python virtual environment - This might take a minute"
python3 -m venv $installdir

echo "Installing papertty"
$installdir/bin/pip3 install papertty

if [ $gpiozero -eq 1 ]; then
    echo "Installing gpiozero"
    $installdir/bin/pip3 install gpiozero
fi


#Download a newer version of papertty from git, since the version
#in pip is probably old.
#Note that python* is used since the exact version of python3 might change

echo "Downloading a newer version of papertty"
cd $installdir/lib/python*/site-packages/
rm -rf papertty
git clone https://github.com/joukos/PaperTTY tmp_papertty
mv tmp_papertty/papertty papertty
rm -rf tmp_papertty


#Download and install the Ubuntu fonts.
#There are other options available which might be a good choice.
#Anything Mono should be fine.

echo "Downloading and installing fonts"
cd /tmp/
wget https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip
unzip 0cef8205-ubuntu-font-family-0.83.zip
mv ubuntu-font-family-0.83/*.ttf $fontdir
rm 0cef8205-ubuntu-font-family-0.83.zip
rm -rf ubuntu-font-family-0.83


echo "Creating init scripts"


#Startup script for papertty itself.
#Currently uses some sane(?) default values and leave it up to the user to
#modify the values later.
#Adding some choices to the installer might be nice, but realistically the
#user won't know what the appropriate values are until they try actually running
#papertty and seeing what works for their panel.

echo "Creating papertty startup script: $bindir/startpapertty.sh"

cat <<EOF > $bindir/startpapertty.sh
#!/bin/bash
sudo $installdir/bin/papertty --driver $panel terminal --autofit --portrait --size 30 --font $fontdir/UbuntuMono-R.ttf
EOF
chmod +x $bindir/startpapertty.sh


echo "Checking crontab"

crontab -l > ~/old-crontab.txt
if [ -s ~/old-crontab.txt ]; then
    echo "Backing up crontab to: ~/old-crontab.txt"
    cat ~/old-crontab.txt > ~/new-crontab.txt
else
    rm ~/old-crontab.txt
    echo "Old crontab was empty - Not backing up"
    echo "" > ~/new-crontab.txt

echo "Adding new crontab entry to run papertty startup script"

echo "@reboot $bindir/startpapertty.sh" >~/new-crontab.txt
crontab ~/new-crontab.txt
rm ~/new-crontab.txt


#Create a backup of the boot config
echo "Backing up boot config to: /boot/config.txt.bak"
sudo cp /boot/config.txt /boot/config.txt.bak

#Comment out the existing SPI setting and add a new line to turn it on
echo "Enabling SPI"
sudo sed -i 's/^dtparam=spi/dtparam=spi=on\n#dtparam=spi/g' /boot/config.txt



echo ""
echo ""
echo ""
echo "Installation has finished."
echo "You will need to reboot before the changes take effect."
echo ""
echo "Note that you may still need to edit the papertty startup script to suit your preferences."
echo "eg. To change the font, font size, screen orientation, etc."
echo "The startup script can be found at: $bindir/startpapertty.sh"