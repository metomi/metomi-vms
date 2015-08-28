# metomi-vms

Vagrant virtual machines with [FCM](http://metomi.github.io/fcm/doc/) + [Rose](http://metomi.github.io/rose/doc/rose.html) + [Cylc](http://cylc.github.io/cylc/) installed.

## Using the Ubuntu 14.04 Virtual Machine

### Installing VirtualBox and Vagrant

In order to use this virtual machine (VM), you must first install [​VirtualBox](https://www.virtualbox.org/) and ​[Vagrant](https://www.vagrantup.com/).

These applications provide point-and-click installers for Windows, and can usually be installed via the package manager on Linux systems (although make sure to check that the Vagrant version is at least 1.5 using `vagrant --version`).

### Setting up the Virtual Machine

Download the setup files from github: https://github.com/metomi/metomi-vms/archive/master.zip.
Then extract the files and change directory to `metomi-vms-master`.
* Windows users can navigate to the directory using Windows Explorer and then use `Shift-> Right Mouse Click -> Open command window here`.

By default the VM will be built with support for accessing the Met Office Science Repository Service.
If you don't want this (or don't have access) then edit the file `Vagrantfile` and remove `mosrs` from the `args` in the `config.vm.provision` line.

Now run the command `vagrant up` to build and launch the VM.
This involves downloading a base VM and then installing lots of additional software so it can take a long time (depending on the speed of your internet connection).
Note that, although a login screen will appear in a separate window, you will not be able to login.
Once the installation is complete the VM will shutdown.

### Using the Virtual Machine

Run the command `vagrant up` to launch the VM.
A separate window open should open containing a lightweight Linux desktop environment ([LXDE](http://lxde.org/)) with a terminal already opened.

If your VM includes support for the Met Office Science Repository Service then you will be prompted for your password (and also your user name the first time you use the VM).
If you get your username or password wrong and Subversion fails to connect, just run `mosrs-cache-password` to try again.

The VM is configured with a local [Rose suite repository](http://metomi.github.io/rose/doc/rose-rug-introduction.html#suite-storage) and with the suite log viewer running under apache.
To try this out, you can follow the [Rose Brief Tour](http://metomi.github.io/rose/doc/rose-rug-brief-tour.html) and it should all *just work* (as should all the other tutorials in the [Rose User Guide](http://metomi.github.io/rose/doc/rose.html)).

To shutdown the VM your can either use the menu item available in the top right hand corner of the Linux desktop or you can issue the command `vagrant halt` from the command window where you launched the VM.

Note that the desktop environment is configured to use a UK keyboard.
If you need to change this, take a look at how this is configured in the file `install-desktop.sh`.

### Using the Virtual Machine without a desktop environment

If you are using the VM on a Mac or Linux system where you already have a X server running then you may find it easier to not install the desktop environment.
In order to do this, replace the file `Vagrantfile` with `Vagrantfile.nodesktop`.
Then run the command `vagrant up` to launch the VM in the normal way.
Note that, unlike when installing the desktop environment, it will not shutdown after the initial installation.

Once the VM is running, run the command `vagrant ssh` to connect to it.

To shutdown the VM you can either run the command `sudo shutdown -h now` from within your ssh session or you can exit your ssh session and then issue the command `vagrant halt`.

## Using other Virtual Machines

Any other VMs provided are primarily for the purpose of testing FCM, Rose & Cylc on other Linux distributions and providing a reference install on these platforms.
Note that they do not include a desktop environment.

### Installing Cygwin (Windows only)

In order to enable GUI programs running on the VM to display correctly when not using the desktop environment, Windows users will also need to install [Cygwin](https://www.cygwin.com/), making sure to select the `xinit` and `xorg-server` packages from the `X11` section and the `openssh` and `openssl` packages from the `Net` section.

Then, instead of using a Windows command window for launching the VM, you should use a Cygwin-X terminal, which you can find in the Start Menu as `Cygwin-X > XWin Server`.
In Cygwin-X terminals, you can use many common Unix commands (e.g. cd, ls).
Firstly run the command  `cd /cygdrive` followed by `ls` and you should see your Windows drives.
Then use the `cd` command to navigate to the directory where you have extracted the setup files (e.g. `c/Users/User/metomi-vms-master/centos-6`).

## Changing the resources available to the Virtual Machines

The resources available to the VM (e.g. memory) can be configured using the `Vagrantfile`. See ​the [Vagrant documentation](https://docs.vagrantup.com/v2/virtualbox/configuration.html) for more details. 

By default the VMs are configured with 1GB memory and 2 CPUs.
