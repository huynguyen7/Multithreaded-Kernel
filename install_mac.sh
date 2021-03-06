#!bin/sh

mkdir -r bin
mkdir -r build

# Install brew if missing.
if ! command -v brew > /dev/null ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew upgrade && brew update
brew install nasm
brew install qemu
brew install i686-elf-gcc

# Install docker
#if ! command -v docker > /dev/null ; then
#    cd ~/Downloads
#
#    if  [ "$arch" == "x86_64" ]
#    then
#        wget https://desktop.docker.com/mac/stable/amd64/Docker.dmg
#    else
#        wget https://desktop.docker.com/mac/stable/arm64/Docker.dmg
#    fi
#    
#    sudo hdiutil attach Docker.dmg
#    sudo cp -r /Volumes/Docker/Docker.app /Applications
#    sudo hdiutil detach /Volumes/Docker -force
#    sudo rm Docker.dmg
#    exec $SHELL
#    sudo docker login
#fi
