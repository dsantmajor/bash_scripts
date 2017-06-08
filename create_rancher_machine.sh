#!/bin/bash

# create rancheros using docker-machine

URL="https://releases.rancher.com/os/latest/rancheros.iso"

# function to create new VMs using Virtualbox as the driver and boot2docker
create_machine () {
docker-machine create -d virtualbox --virtualbox-boot2docker-url $URL $1

}


# check OS type
#
# check_os_type () {
#
#   OSTYPE=$(uname)
#   if [$OSTYPE == "Linux"]
# }

OSTYPE=$(uname)

if [ $OSTYPE == Linux ]; then
  check_install_linux_package docker-machine

else
  if [$OSTYPE == Darwin ]; then
    check_install_mac_package docker-machine
  fi
fi


  check_install_mac_package () {
docker_machine_installed=$(which $1)
if [ $? == 0 ]; then
    echo -n $1 is installed
  else
    echo "$1 not installed"
    echo " Installing $1 "
    curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
chmod +x /usr/local/bin/docker-machine
fi

  }
# check package is installed

check_install_linux_package () {
pkgname=$(dpkg -l $1)
if [ $? == 0 ]; then
    echo -n $1 is installed
  else
    echo "$1 not installed"
    echo " Installing $1 "
    curl -L https://github.com/docker/machine/releases/download/v0.10.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine &&
  chmod +x /tmp/docker-machine &&
  sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
fi
}

#check_install_linux_package docker-machine

echo " Now creating rancheros"

create_machine rancheros01

echo " Now creating second rancheros"

create_machine rancheros02

echo "Checking the newly created VMs"

list_vms () {

VBoxManage list runningvms | grep $1
}

list_vms rancheros01

list_vms rancheros02

#docker-machine create -d virtualbox --virtualbox-boot2docker-url https://releases.rancher.com/os/latest/rancheros.iso <MACHINE-NAME>
