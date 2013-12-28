cptserver
=========

A student web development environment using Vagrant, Virtualbox, and Puppet.

Virtualbox is software that lets you create virtual machines, allowing you to run another operating system in a sandbox. Vagrant is used to create a customized virtual machine that will run Ubuntu linux. Once it's running, Puppet is used to managed the software on the virtual machine.  Puppet makes sure things like Apache and MySQL are installed, running as a service, configured properly, and restarted when necessary.

All together, this creates a LAMP webserver that can be run on your current computer, whether it be Windows, Apple OSX, or Linux itself. Many developers prefer this type of environment instead of installing something like WAMP or MAMP. One major benefit is that it doesn't interfere with your current computer. Another is that when on a team or in a class, everybody could be developing on the exact same environment with the same versions of all software

Installation
--------

1. First, install Virtualbox, then Vagrant. You don't need Puppet on your host computer; it will exist on the linux virtual machine.
 * Virtualbox - https://www.virtualbox.org/wiki/Downloads
 * Vagrant - http://www.vagrantup.com/
2. Next, download this repository. You could just download the .zip file and extract where you keep your work, but cloning with Git is preferred. If you haven't learned Git yet, you really should.
 * Git - http://git-scm.com/downloads
 * Go to your project folder, open a terminal/command promt, and type `git clone https://github.com/pigeontech/cptserver.git`.
 * This creates a copy on your computer.
3. Open the config/config.yaml file in a text editor, and change anything that you feel needs changed. Right now, the only thing that probably matters is the mysql password. You can add virtual hosts later.  Also, if your computer is already using port 80, like if you run a media server to stream movies to your TV, you might need to change port 80 to something else, like 8080.
4. Open a terminal in the repository folder. If the terminal is still open from the last step, just type `cd cptserver`.
5. Now type `vagrant up`.
 * It will streamline the entire process for you, from creating the virtual machine to 
 * The first time you run it, it will be slow, because it must download and install a linux box, which is a few hundred mb.
6. It's ready. Inside the `www/default/` folder is a sample website. Open your browser and go to `http://localhost` and see if it works. Check out `http://localhost/phpmyadmin` as well, and try logging with the username `root` and the password you set in the config.yaml file.  If you changed the port, these URLs would look like `http://localhost:8080` and `http://localhost:8080/phpmyadmin`.

Virtual Hosts
---------

You will probably build more than one website. Using localhost/foldername is too ugly. So we use virtual hosts.  A few have already been created in the config.yaml file.  There is another step you must do though.  On your actual computer, you have to edit the `hosts` file. On Windows, it's located at `C:\Windows\System32\drivers\etc`. You may need to open it with admin privilages for it to allow you to save changes.

Make the file look like this:
```
127.0.0.1       localhost localhost.dev www.localhost.dev default default.dev www.default.dev
127.0.0.1       wordpress.dev www.wordpress.dev
```

By looking at config.yaml, you'll know that everything in the first line directs to the `default` folder, and everything in the second line directs to a `wordpress` folder.  That wordpress folder doesn't actually exist, it's just an example of how to add more websites.  If you want to challenge yourself, go ahead and create that folder, download Wordpress from http://wordpress.org, and try installing it. It's a good first project!

More Vagrant Commands
---------

These are more commands you'll need. As before, make sure the terminal is open in the root of the cptserver folder.

* `vagrant provision`
 * Any time you make changes to the config.yaml file, like adding a vhost you need to run this command.
* `vagrant reload --provision`
 * If you make changes in top (vagrant) portion of the config.yaml, you need to run this.
* `vagrant halt`
 * This is how you turn it off when you're done. Your computer won't go into sleep mode when a virtual machine is running.
* `vagrant up`
 * Ready to start working on your website again? Run this.
* `vagrant destroy`
 * This will completely wipe out the linux installation and delete the virtual machine. Use with great caution, as you'll lose your databases. Only run this command if things are broken, you're lost, and you want to start over.
