Vagrant - LAMP (Linux Apache MySQL PHP)
========================================

A web development environment using Ubuntu Server 13.10 x86_64, Vagrant, Virtualbox, and Puppet.

Virtualbox is software that lets you create virtual machines, allowing you to run another operating system in a sandbox. Vagrant is used to customize, load, and access that virtual machine. Once it's running, Puppet is used to manage the software on the virtual machine.  Puppet makes sure things like Apache and MySQL are installed, running as a service, configured properly, and restarted when necessary.

All together, this creates an Ubuntu LAMP webserver that can be run on your current computer, whether it be Windows, Apple OSX, or Linux itself. Many developers prefer this type of environment instead of installing something like WAMP, XAMPP, or MAMP. One major benefit is that it doesn't interfere with your current computer. Another is that when on a team or in a class, everybody could be developing on the exact same environment with the same versions of all software.

Features
--------

* It uses a single config file for everything. No need to dig into Puppet code to customize.
* Chef and Puppet provisioners are pre-installed.
* It adds a repository that will give you the latest PHP (5.5+) and Apache (2.4+).
* It installs phpMyAdmin for you so that you can manage databases.
* It also configures MySQL so that you can use local DB software on your computer, like MySQL Workbench.
* It installs Composer globally in your path for you to easily manage PHP dependencies.
* It installs and configures Xdebug so that you may debug with local IDEs, like PHPStorm and Netbeans.

Installation
--------

1. First, install Virtualbox, then Vagrant. You don't need Puppet on your host computer; it will exist on the linux virtual machine.
 * Virtualbox - https://www.virtualbox.org/wiki/Downloads
 * Vagrant - http://www.vagrantup.com/

2. Next, download this repository. You could just download the .zip file and extract it where you keep your work, but cloning with Git is preferred. If you haven't learned Git yet, you really should.
 * Git - http://git-scm.com/downloads
 * Go to your project folder (on Windows, it's probably something like 'C:\Users\Scott\Documents\'), open a terminal/command promt, and type `git clone https://github.com/pigeontech/cptserver.git`.
 * This creates a copy on your computer, like 'C:\Users\Scott\Documents\cptserver\'.  Go into that folder.

3. Open the config/config.yaml file in a text editor, and change anything that you feel needs changed. Right now, the only thing that probably matters is the mysql password. You can add virtual hosts later.  Also, if your computer is already using port 80, like if you run a media server to stream movies to your TV, you might need to change port 80 to something else, like 8080.

4. Open a terminal in the repository folder. If the terminal is still open from the Git step, just type `cd cptserver`.

5. Now type `vagrant up`.
 * It will streamline the entire process for you, from creating the virtual machine to installing PHP and its modules.
 * The first time you run it, it will be slow, because it must download and install a linux box, which is a few hundred mb.
 
6. It's ready. Inside the `www/default/` folder is a sample website. Open your browser and go to `http://localhost` and see if it works. Check out `http://localhost/phpmyadmin` as well, and try logging with the username `root` and the password you set in the config.yaml file.  If you changed the port, these URLs would look like `http://localhost:8080` and `http://localhost:8080/phpmyadmin`.

Virtual Hosts
---------

You will probably build more than one website. Using localhost/foldername is too ugly. So we use virtual hosts.  A few have already been created in the config.yaml file.  There is another step you must do though.  On your actual computer, you have to edit the `hosts` file. On Windows, it's located at `C:\Windows\System32\drivers\etc`. You may need to open Notepad with admin privilages for it to allow you to save changes.

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
* `vagrant ssh`
 * Once you're up and running, this is a command you'll use most often. It lets you into Ubuntu, as if you were really sitting at the computer terminal. From here, you can run commands like `sudo apt-get install <something>`. Often, you'll want to immediately go into the web root with `cd /var/www`.  Any changes made here are also mirrored on your host computer's www folder.  Try it!  If you're not familiar with the linux file structure, it's worth doing a Google search. When you're readty to go back to your normal computer's terminal, type `exit`.

Composer
----------
Composer is a dependency manager for common libraries, such as the popular Laravel framework, or the PHPUnit testing library.  It will automatically download the latest/specified version of them, as well as any dependencies that they rely on.  It will then create an autoload.php file, which you include into your actual project to load the library and dependencies.  Composer, like Git, is one of those technologies that separates the new school from the old school.  Don't get left behind! It's more important than ever for web developers to become familiar with these command line tools.

1. Log in via `vagrant ssh` and navigate to your website folder, such as `cd /var/www/mywebsite`.

2. Create a `composer.json` file in the same place containing the following:

 ```
 {
     "require-dev": {
         "phpunit/phpunit": "3.7.14"
     }
 }
 ```

 Don't make things difficult. You don't have to use Vi or Nano to create and edit this file. You can do this step on your normal computer with Sublime Text, Notepad, etc. Remember that the www folder is shared between your computer and the vm. Changes to one happen to both. That's the whole point of using Vagrant!

3. Back to the terminal, type `composer install`. This will create a `vendor` folder, download all of the software packages you specified in the json file, and also download their dependencies. For example, if you specify PHPUnit as above, your project and vendor folder will look like this:

 ```
 - \var\www\mywebsite
 -- vendor
 -- composer.json
 -- composer.lock
 -- composer.phar
 -- index.php
 
 - \var\www\mywebsite\vendor
 -- bin
 -- composer
 -- phpunit
 -- symfony
 -- autoload.php
 ```
4. Now in your index.php file, you'd put something like `require 'vendor/autoload.php';`.

5. Keep in mind that you need to do all of these steps for each website you build. Composer is dependency managment on a per project basis. So if you create another website, like `\var\www\lolcatpics`, it will need its own composor.json, and you'll need to run `composer install` in that directory, and a vendor folder will be created.

6. Visit the following websites to learn more about fitting these tools into your workflow:
 * http://daylerees.com/composer-primer
 * https://www.digitalocean.com/community/articles/how-to-install-and-use-composer-on-your-vps-running-ubuntu 
 * https://jtreminio.com/2013/03/unit-testing-tutorial-introduction-to-phpunit/
