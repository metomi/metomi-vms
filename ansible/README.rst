========================
UKCA VM Deployment
========================
**Richard Smith 24/03/2017**


This playbook is used to provision a VM on the Jasmin scientific computing cloud.
The playbook deploys a machine and installs x2go server on the VM allowing the user to use applications requiring x windows.
`x2goclient <http://wiki.x2go.org/doku.php/download:start>`_ will need to be installed on the local machine.

Preparing the playbook
----------------------

**_template files**
==================

There are two files which have the postfix _template*. Just copy these files into their current location removing _template.

1. metomi-playbook/inventory_template.ini
2. metomi-playbook/group_vars/all_template.yml

Then setup the files as below.

**group_vars/all.yml**

There are only a couple of variables which can be defined in group_vars/all.yml::

    username: vagrant
    password: vagrant


    # If running on local vagrant vm, set local: true
    local: false

    # Define software versions
    FCM_VERSION: 2017.02.0
    CYLC_VERSION: 7.1.1
    ROSE_VERSION: 2017.02.0

**DUE TO PATHS SETUP IN THE UM INSTALLATION SCRIPTS, ONLY USERNAME OF VAGRANT WILL WORK**

**inventory.ini**

This is where details about the target host/hosts goes e.g.::

    ukca-test ansible_ssh_host=192.134.234.37 ansible_port=22 ansible_user=root

Before running the playbook against a cloud machine
---------------------------------------------------

Using `cloud.jasmin.ac.uk <https://cloud.jasmin.ac.uk>`_ to preapre machine on jasmin for the playbook.

1.  Click **New machine**

2.  Select Ubuntu-18.04 template

3.  Enter **Machine name** and check the networking box

4.  Click **Provision machine**

5.  When machine has been provisioned, start the machine using the play button. Once this has completed stop the machine using     power button.

6.  Click the cog button under actions, select **Hard disks** tab, enter amount for new disk (I used 16GB when running the         test) then click the **+**

7.  Start the machine again with the play button and you are ready to run the playbook.

Running the playbook
--------------------

Running the playbook on unmanaged cloud
=======================================


The playbook is run using the following command from inside the repository::

    ansible-playbook main.yml -i inventory.ini


The playbook creates an ssh key and places it inside a folder called ssh-keys inside a folder labelled by the hostname.
The public key is uploaded and added to the accepted ssh keys on the remote machine but it is up to the user to add the key
to their local environment.

Running against a local vagrant machine
=======================================

1. ``vagrant up`` the machine


On conclusion of the playbook run
----------------------------------

If you have run the playbook using vagrant up::

    Perform 'vagrant reload' to display the GUI.

If you have run the playbook against a cloud machine::

    Install x2goclient http://wiki.x2go.org/doku.php/download:start


Using x2goclient
----------------

1. Fill out details on new session popup::

    Session name
    Host: <ip_address or hostname>
    Login: vagrant
 
    Select the ssh key file from the ssh_keys directory in the Use RSA/DSA key
    
    Check Try auto login (via SSH Agent...)
    
    Session type: LXDE

2. Click on your new session on the right hand side of the x2goclient window.

3. It should automatically login, asking if you wish to allow connection on first run.


Limitations
------------

1. When running playbook against a machine created via the cloud portal, need to make sure that an extra disk has been added ~16GB
2. Due to limitations in the UM installation script only the user `vagrant` will work.
3. Need to use an x-windows client eg. x2go in order to operate the desktop environment.

