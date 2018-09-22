# metomi-vms

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1341042.svg)](https://doi.org/10.5281/zenodo.1341042)

Vagrant virtual machines with [FCM](http://metomi.github.io/fcm/doc/) + [Rose](http://metomi.github.io/rose/) + [Cylc](http://cylc.github.io/cylc/) installed.

Table of contents:
* [Software Requirements](#software-requirements)
* [Setting up the Default Virtual Machine](#setting-up-the-default-virtual-machine)
* [Using the Default Virtual Machine](#using-the-default-virtual-machine)
* [Disabling the Desktop Environment](#disabling-the-desktop-environment)
* [Using other Virtual Machines](#using-other-virtual-machines)
* [Optional Windows Software](#optional-windows-software)
  * [Git BASH](#git-bash)
  * [Cygwin](#cygwin)
* [Troubleshooting](#troubleshooting)
* [Microsoft Azure](#microsoft-azure)

## Software Requirements

In order to use a virtual machine (VM), you must first install:
 * [VirtualBox](https://www.virtualbox.org/), software that enables running of virtual machines (version 5.1.6 or later required).
 * [Vagrant](https://www.vagrantup.com/), software that allows easy configuration of virtual machines (version 1.9.1 or later required).

These applications provide point-and-click installers for Windows and can usually be installed via the package manager on Linux systems.

## Setting up the Default Virtual Machine

After you have installed VirtualBox and Vagrant, download the metomi VM setup files from github:
 * https://github.com/metomi/metomi-vms/archive/master.zip.

Then extract the files which will be put into a directory called `metomi-vms-master`.

The default VM uses Ubuntu 16.04.
If necessary you can customise the VM by editing the file `Vagrantfile.ubuntu-1604` as follows:
* By default the VM will be built with support for accessing the Met Office Science Repository Service.
  If you don't want this (or don't have access) then remove `mosrs` from the `args` in the `config.vm.provision` line.
* As described below, you may prefer not to install the desktop environment.
  To do this remove `desktop` from the `args` in the `config.vm.provision` line and comment out the line `v.gui = true`.
* By default the VM is configured with 1 GB memory and 2 CPUs.
  You may want to increase these if your host machine is powerful enough.

See the [Vagrant documentation](https://docs.vagrantup.com/v2/virtualbox/configuration.html) for more details on configuration options.

Before proceeding you need to be running a terminal with your current directory set to `metomi-vms-master`.
* Windows users can navigate to the directory using Windows File Explorer and then use `Shift-> Right Mouse Click -> Open command window here`.

Now run the command `vagrant up` to build and launch the VM.
This involves downloading a base VM and then installing lots of additional software so it can take a long time (depending on the speed of your internet connection).
Note that, although a login screen will appear in a separate window, you will not be able to login at this stage.
Once the installation is complete the VM will shutdown.

## Using the Default Virtual Machine

Run the command `vagrant up` to launch the VM.
A separate window should open containing a lightweight Linux desktop environment ([LXDE](http://lxde.org/)) with a terminal already opened.

If your VM includes support for the Met Office Science Repository Service then you will be prompted for your password (and also your user name the first time you use the VM).
If you get your username or password wrong and Subversion fails to connect, just run `mosrs-cache-password` to try again.

The VM is configured with a local [Rose suite repository](http://metomi.github.io/rose/doc/html/tutorial/rose/rosie.html) and with the suite log viewer running under apache.
If you want to learn more about Rose and Cylc you can follow the tutorials contained in the [Rose User Guide](http://metomi.github.io/rose/).

To shutdown the VM you can either use the menu item available in the bottom right hand corner of the Linux desktop or you can issue the command `vagrant halt` from the command window where you launched the VM.

Note that the desktop environment is configured to use a UK keyboard.
If you need to change this, take a look at how this is configured in the file `install-desktop.sh`.

## Disabling the Desktop Environment

If you are using the VM on a Mac or Linux system where you already have a X server running then you may find it easier to not install the desktop environment.
In order to do this, edit the file `Vagrantfile.ubuntu-1604` as described above.
Then run the command `vagrant up` to launch the VM in the normal way.
Note that, unlike when installing the desktop environment, it will not shutdown after the initial installation.

Once the VM is running, run the command `vagrant ssh` to connect to it.

To shutdown the VM you can either run the command `sudo shutdown -h now` from within your ssh session or you can exit your ssh session and then issue the command `vagrant halt`.

## Using other Virtual Machines

In addition to the default VM, additional VMs are supported in separate files named `Vagrantfile.<distribution>`, e.g. `Vagrantfile.centos-6`.
These other VMs are provided primarily for the purpose of testing FCM, Rose & Cylc on other Linux distributions and providing a reference install on these platforms.
Note that they are not as well tested as the default VM and may not include a desktop environment.

To use a different VM, modify the file which is loaded in the default `Vagrantfile` before running `vagrant up`.
Alternatively you can set the environment variable `VAGRANT_VAGRANTFILE`, for example:
```
export VAGRANT_VAGRANTFILE=Vagrantfile.ubuntu-1404
```
(use `set` in place of `export` when using the command window on Windows).

## Optional Windows Software

### Git BASH

For an alternative to the normal command window, Windows users can install Git BASH (which comes with [Git for Windows](https://git-for-windows.github.io/)).
As well as providing a nicer interface (more familiar for Linux users) this also means that you can use git to clone the metomi-vms repository (instead of downloading the zip file):
```
git clone https://github.com/metomi/metomi-vms.git
```
It is then easy to track any local changes, pull down updates, etc.

### Cygwin

If you want to run a VM without a desktop environment on Windows then, in order to enable GUI programs to work, you will need to install [Cygwin](https://www.cygwin.com/), making sure to select the `xinit` and `xorg-server` packages from the `X11` section and the `openssh` and `openssl` packages from the `Net` section.

Then, instead of using a normal command window for launching the VM, you should use a Cygwin-X terminal, which you can find in the Start Menu as `Cygwin-X > XWin Server`.
In Cygwin-X terminals, you can use many common Unix commands (e.g. cd, ls).
Firstly run the command  `cd /cygdrive` followed by `ls` and you should see your Windows drives.
Then use the `cd` command to navigate to the directory where you have extracted the setup files (e.g. `c/Users/User/metomi-vms-master`).

## Troubleshooting

### Guest display resolution

When you resize the VirtualBox window (e.g. to mazimise it) the display resolution of your Linux VM should adjust to match.
If this doesn't work it may be due to the Guest Additions installed in your VM not matching the version of VirtualBox you have installed.
The easiest way to fix this is to install the [vagrant-vbguest Vagrant plugin](https://github.com/dotless-de/vagrant-vbguest).
Note that, if the plugin does update your Guest Additions then you will need to shutdown and restart your VM (using `vagrant up`) in order for them to take effect.

## Microsoft Azure

It is possible to run using Vagrant on a Microsoft Azure cloud virtual machine. To do this you will need to install the [`vagrant-azure`](https://github.com/Azure/vagrant-azure) plugin. You should also install the [Azure CLI command line tool](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest), which will allow you to manage your Azure resources.

* To begin you should follow the instructions from https://github.com/Azure/vagrant-azure. First ensure you have the dummy box and have added the plugin:
```
vagrant box add azure https://github.com/azure/vagrant-azure/raw/v2.0/dummy.box --provider azure
vagrant plugin install vagrant-azure
```

* You should login using `az login`

* You will need to run the `az ad sp create-for-rbac` command to create the active directory. This will provide the following information with output similar to this:
```
{
  "appId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
  "displayName": "some-display-name",
  "name": "http://azure-cli-2017-04-03-15-30-52",
  "password": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
  "tenant": "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"
}
```

* You should then run the `az account list --query "[?isDefault].id" -o tsv` command to get your subscription information. This will have output similar to:
```
DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD
```

* You will then need to export these as the following environment variables, as these are used within the Azure Vagrantfile. You should also keep a note of them, as you will need to make sure that they are set each time you access the VM.
```
export AZURE_CLIENT_ID="AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAA"
export AZURE_CLIENT_SECRET="BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBB"
export AZURE_TENANT_ID="CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCC"
export AZURE_SUBSCRIPTION_ID="DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD"
```

* To run the VM you should then run `vagrant up --provider=azure` and once provisioned you can `vagrant ssh` etc. in the usual way.

There are many different [Linux VMs available on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes), for different [price plans](https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/linux/). Currently the VM is set to use the [`Standard_F4s_v2`](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-compute) Azure Linux machine, which is compute optimised with 4 virtual CPUs and 8GB memory. Other options are available dependent on need and cost.
