#!/bin/bash

echo "Updating system ..."
sudo apt update
sudo apt upgrade
echo ""

echo "Installing Python 2.7 ..."
sudo apt install python
echo ""

echo "Installing pip ..."
sudo apt install python-pip
sudo pip install --upgrade pip
echo ""

echo "Installing libxp6 ..."
sudo apt install "./dep/libxp6_1.0.2-1ubuntu1_amd64.deb"
echo ""

echo "Installing the Qt5 libraries ..."
sudo apt install qt5-default
sudo apt install python-pyqt5
echo ""

echo "Installing scipy and numpy ..."
sudo pip install scipy
echo ""

echo "Installing pyfftw ..."
sudo apt install libfftw3-dev
sudo pip install pyfftw
echo ""

echo "Installing matplotlib ..."
sudo pip install matplotlib
echo ""

echo "Installing pygamma ..."
sudo pip install pygamma
echo ""

echo "Installing NiBabel ..."
sudo pip install nibabel
echo ""

echo "Installing FSL ..."
echo " | Please select default location for install."
sudo python "./dep/fslinstaller.py"
echo ""

echo " | Installing FSL dependencies ..."
# fsleyes
sudo apt install libgtk3-dev libgtk2.0-dev libasound2 libcaca0
sudo pip install pathlib2
sudo pip install wxPython
echo ""

# fslview
sudo apt install libmng-dev
sudo ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1
sudo apt install libjpeg62 
echo ""

echo " | Setting up FSL ..."
cd /usr/local/fsl/bin/
sudo mv fslview fslview.bak
sudo ln -s fslview_deprecated fslview
echo ""

echo "Please install IDL manually."
echo "Please install Xming manually."