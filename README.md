# metomi-vms

Vagrant virtual machines with [FCM](http://metomi.github.io/fcm/doc/) + [Rose](http://metomi.github.io/rose/doc/rose.html) + [Cylc](http://cylc.github.io/cylc/) installed.

Table of contents:
* [Software Requirements](#software-requirements)
* [Setting up the Default Virtual Machine](#setting-up-the-default-virtual-machine)
* [Using the Default Virtual Machine](#using-the-default-virtual-machine)
* [Disabling the Desktop Environment](#disabling-the-desktop-environment)
* [Using other Virtual Machines](#using-other-virtual-machines)
* [Optional Windows Software](#optional-windows-software)
  * [Git BASH](#git-bash)
  * [Cygwin](#cygwin)

## Software Requirements

In order to use a virtual machine (VM), you must first install [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/).

These applications provide point-and-click installers for Windows, and can usually be installed via the package manager on Linux systems (although make sure to check that the Vagrant version is at least 1.5 using `vagrant --version`).

## Setting up the Default Virtual Machine

Download the setup files from github: https://github.com/metomi/metomi-vms/archive/master.zip.
Then extract the files and change directory to `metomi-vms-master`.
* Windows users can navigate to the directory using Windows Explorer and then use `Shift-> Right Mouse Click -> Open command window here`.

The default VM uses Ubuntu 14.04.
If necessary you can customise the VM by editing the file `Vagrantfile` as follows:
* By default the VM will be built with support for accessing the Met Office Science Repository Service.
  If you don't want this (or don't have access) then remove `mosrs` from the `args` in the `config.vm.provision` line.
* As described below, you may prefer not to install the desktop environment.
  To do this remove `desktop` from the `args` in the `config.vm.provision` line and comment out the line `v.gui = true`.
* By default the VM is configured with 1 GB memory and 2 CPUs.
  You may want to increase these if your host machine is powerful enough.

See the [Vagrant documentation](https://docs.vagrantup.com/v2/virtualbox/configuration.html) for more details on configuration options.

Now run the command `vagrant up` to build and launch the VM.
This involves downloading a base VM and then installing lots of additional software so it can take a long time (depending on the speed of your internet connection).
Note that, although a login screen will appear in a separate window, you will not be able to login.
Once the installation is complete the VM will shutdown.

## Using the Default Virtual Machine

Run the command `vagrant up` to launch the VM.
A separate window should open containing a lightweight Linux desktop environment ([LXDE](http://lxde.org/)) with a terminal already opened.

If your VM includes support for the Met Office Science Repository Service then you will be prompted for your password (and also your user name the first time you use the VM).
If you get your username or password wrong and Subversion fails to connect, just run `mosrs-cache-password` to try again.

The VM is configured with a local [Rose suite repository](http://metomi.github.io/rose/doc/rose-rug-introduction.html#suite-storage) and with the suite log viewer running under apache.
To try this out, you can follow the [Rose Brief Tour](http://metomi.github.io/rose/doc/rose-rug-brief-tour.html).
You can also try out all the other tutorials in the [Rose User Guide](http://metomi.github.io/rose/doc/rose.html).

To shutdown the VM you can either use the menu item available in the top right hand corner of the Linux desktop or you can issue the command `vagrant halt` from the command window where you launched the VM.

Note that the desktop environment is configured to use a UK keyboard.
If you need to change this, take a look at how this is configured in the file `install-desktop.sh`.

## Disabling the Desktop Environment

If you are using the VM on a Mac or Linux system where you already have a X server running then you may find it easier to not install the desktop environment.
In order to do this, edit the file `Vagrantfile` as described above.
Then run the command `vagrant up` to launch the VM in the normal way.
Note that, unlike when installing the desktop environment, it will not shutdown after the initial installation.

Once the VM is running, run the command `vagrant ssh` to connect to it.

To shutdown the VM you can either run the command `sudo shutdown -h now` from within your ssh session or you can exit your ssh session and then issue the command `vagrant halt`.

## Using other Virtual Machines

In addition to the default VM, additional VMs are supported in separate files named `Vagrantfile.<distribution>`, e.g. `Vagrantfile.centos-6`.
These other VMs are provided primarily for the purpose of testing FCM, Rose & Cylc on other Linux distributions and providing a reference install on these platforms.
Note that they are not as well tested as the default VM and may not include a desktop environment.

To use a different VM, replace the default `Vagrantfile` with the appropriate file (`cp Vagrantfile.<distribution> Vagrantfile`) before running `vagrant up`.
Alternatively you can set the environment variable `VAGRANT_VAGRANTFILE`, for example:
```
export VAGRANT_VAGRANTFILE=Vagrantfile.ubuntu-1510
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
