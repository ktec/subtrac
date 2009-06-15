# subtrac

Simple and opinionated helper for creating and managing subversion and trac projects.

# Installing on VirtualBox 2.2

Start with a Fresh VM Image 
Install jeos (hardy)

## install the guest additions 
	# mount guest additions (select Devices>Install Guest Additions from menu) 
	sudo mount /media/cdrom0/ -o unhide
	# install gcc and make
	sudo aptitude install build-essential linux-headers-`uname -r`
	sudo /cdrom/VBoxLinuxAdditions-x86.run all

## install openssh-server?
	sudo apt-get install openssh-server

## some other pre-requisites
	sudo aptitude install ruby1.8-dev ruby1.8 ri1.8 rdoc1.8 sqlite3

## install apache2, python and some modules
	sudo apt-get install apache2 libapache2-mod-python libapache2-mod-python-doc \
		libapache2-svn python-setuptools subversion python-subversion \
    graphviz htmldoc enscript
	# enable mod_rewrite
	sudo a2enmod rewrite

## install Trac
	sudo easy_install -U setuptools
	sudo easy_install Trac

## some cool plugins
	sudo easy_install http://svn.edgewall.org/repos/genshi/trunk/
	sudo easy_install http://trac-hacks.org/svn/accountmanagerplugin/trunk  
	sudo easy_install http://trac-hacks.org/svn/customfieldadminplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/eclipsetracplugin/tracrpcext/0.10
	sudo easy_install http://trac-hacks.org/svn/iniadminplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/masterticketsplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/pagetopdfplugin/0.10
	sudo easy_install http://trac-hacks.org/svn/progressmetermacro/0.11
	sudo easy_install http://trac-hacks.org/svn/ticketdeleteplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/tracwysiwygplugin/0.11
	sudo easy_install http://wikinotification.ufsoft.org/svn/trunk
	sudo easy_install http://trac-hacks.org/svn/advancedticketworkflowplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/clientsplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/emailtotracscript/trunk
	sudo easy_install http://trac-hacks.org/svn/finegrainedpageauthzeditorplugin/0.11
	sudo easy_install http://trac-hacks.org/svn/themeengineplugin/0.11 
	sudo easy_install http://trac-hacks.org/svn/crystalxtheme/0.11
	sudo easy_install http://trac-hacks.org/svn/tagsplugin/tags/0.6

## install gems and update
	sudo apt-get install rubygems
	sudo gem update --system

Which may not work, if not try this:

 sudo gem install rubygems-update

Which introduced this error:
	/usr/bin/gem:23: uninitialized constant Gem::GemRunner(NameError)
Simply add the line to the file /usr/bin/gem (may be different on a mac)
	require 'rubygems/gem_runner'
after
	require 'rubygems'
OR

	sudo mv /usr/bin/gem /usr/bin/gem.old; sudo ln -s /usr/bin/gem1.8 /usr/bin/gem

	# edit bash.bashrc so all users can run the gem binaries
	sudo vi /etc/bash.bashrc ? not sure we need this any more...
	# add github to the gem sources list
	sudo gem sources -a http://gems.github.com
	# install subtrac gem package
	sudo gem install ktec-subtrac
	
Note: since gems and ubuntu don't entirely play nicely, its necessary to add the gem path to .bashrc file.
	For all users, you can add it here:
		sudo vi /etc/bash.bashrc

		...
		export PATH=$PATH:/var/lib/gems/1.8/bin
	

## install subtrac server
	sudo subtrac install [--clean]


# Other things to setup

## Mount a shared host folder from the VM Guest

### manually
	sudo mkdir /mnt/subtrac
	sudo mount.vboxsf pkg /mnt/subtrac/
	
### automatically
	sudo vi /etc/fstab
	
	add the following line:
	
	Shared /mnt/Shared vboxsf defaults,rw,uid=1000,gid=1000 0 0
	
	
	This way i can install all the repos and trac on a mounted volume, which means all the data is separated from the appliance and can be part of my back up process.

## Setting up VM to use an internal loop back interface

### Configure the interface

	sudo ifconfig vboxnet0 192.168.56.1 up

### Configure the VM

	VBoxManage modifyvm dev.subtrac.com -hostifdev2 'vboxnet0: ethernet'

Boot it, and give it a static address on the same subnet, mine looks like this:

### Assign a static ip to interface2

sudo vi /etc/networking/interfaces

	# The primary network interface
	auto eth0
	iface eth0 inet dhcp

	# The secondary network interface
	auto eth1
	iface eth1 inet static
		address 192.168.56.2
		netmask 255.255.255.0

For linux users there's an even cooler way to set this up...
http://muffinresearch.co.uk/archives/2009/04/08/virtualbox-access-guests-via-a-virtual-interface/

### OSX Map your new domain to the ip

	sudo mate /private/etc/hosts 

	192.168.56.2 dev.subtrac.com

### OSX Auto start the VM on bootup

	sudo mate /Library/LaunchDaemons/com.subtrac.dev.plist

And make it look something like this:

	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" \
	"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
		<dict>
			<key>Label</key>
			<string>Bring up interface</string>
			<key>ProgramArguments</key>
			<array>
				<string>ifconfig</string>
				<string>vboxnet0</string>
				<string>192.168.56.1</string>
				<string>up</string>
			</array>
			<key>RunAtLoad</key>
			<true/>
			<key>UserName</key>
			<string>root</string>
		</dict>
	    <dict>
	    	<key>Label</key>
	    	<string>Subtrac Development Server</string>
	        <key>ServiceDescription</key>
	        <string>VirtualBox</string>
	        <key>ProgramArguments</key>
	        <array>
	           <string>/usr/bin/VBoxHeadless</string>
	           <string>-startvm</string>
	           <string>dev.subtrac.com</string>
	        </array>
	        <key>RunAtLoad</key>
	        <true/>
	        <key>HopefullyExitsFirst</key>
	        <true/>
	        <!-- use if you want it to bounce automatically...
	        <key>KeepAlive</key>
	        <true/>
	        -->
	        <key>UserName</key>
	        <string>root</string>
	    </dict>
	</plist>

### Login with out a prompt

	# generate a new keypair
	sh-keygen -t rsa

	# push the pub key up to the server
	cat ~/.ssh/id_rsa.pub | ssh keith@dev.subtrac.com "cat - >> ~/.ssh/authorized_keys"

	# chmod the file **on the server**:
	sudo chmod 600 ~/.ssh/authorized_keys


## Copyright

Copyright (c) 2009 Keith Salisbury. See LICENSE for details.
