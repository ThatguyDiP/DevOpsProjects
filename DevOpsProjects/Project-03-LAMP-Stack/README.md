# **LAMP STACK IMPLAMENTATION**

*In this project, I have created a working linux environment,configured with Apache web server, MySQL databases, and writing PHP code for server functionality.*

## Instaling Apache

After starting an EC2 instance in AWS you must install Apache.

### *Installing Apache and Updating the Firewall*

#### To update the list of available packages use

    sudo apt update

![apt update](Screens/s1-a-apt-update.png)

#### Installing Apache2

    sudo apt install apache2

![InstallApache2](Screens/s1-b-install-apache2.png)

 To verify that apache2 is running correctly use the command

    sudo systemctl status apache2

![apache2statuschk](Screens/s1-c-status-check.png)

To find the server public ip addressfrom the command line you can use the following command

    curl -s http://169.254.169.254/latest/meta-data/public-ipv4

![Public ip](Screens/s1-e-find-public-ip.png)

To test the server on the command line insert

    curl http://localhost:80


![Locla curl](Screens/s1-d-curl-localhost.png)

Another way is to go to your internet browser of choice and insert the public ip address
When i went to the website this came up showing that apache was properly installed

![apache2 running](Screens/s1-final.png)

## **Installing MySQL**

Once I was able to get the webserver running I installed a database management system.

To install MySQL i ran the command 

     sudo apt install mysql-server


![sql install](Screens/s2-a-installmysql-1.png)

Once the install was complete i then logged into the MySQL console by entering the command

    sudo mysql

![sql console](Screens/s2-b-mysql-connection.png)

From there the process to properly secure the SQL Shell is as follows:

Run security script that removes the default security settings and creates a custom configuration of the shell via the following commands

    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PassWord.1';


![Loging in with native password](Screens/s2-c-nativepass.png)
 
    $ sudo mysql_secure_installation

![SQL Password setup](Screens/s2-d-pass-setup.png)

Once the MySQL security has been updated i tested the settings by using the command
    sudo mysql -p

This was flagged with -p to prompt a password to log in

![SQL Login With Password Prompt](Screens/s2-e-pass-prompt.png)

Type exit on the command line to leave the MySQL Console

## **Installing PHP**
PHP is installed to process code to allow the end user to see the content in a dynamic state rather than lines of code

### To create this I installed PHP and 2  nessicary modules


#### The first module allows PHP to communicate with MySQL databases

     php-mysql

#### The second module enables Apache to handle PHP files

    libapache2-mod-php

### Consolidation of Package Install

 Rather than installing each package  individually I opted to install with one line of code to save time

    sudo apt install php libapache2-mod-php php-mysql

![Bulk Package Install](Screens/s3-a-php-packages-install.png)

Once the installation is complete you can verify the PHP version by typing the command 

    php -v

![PHP Version Verification](Screens/s3-b-php-version.png)

## **Creating a Virtual Host Using Apache**

### In this project I setup the domain as  ***projectlamp***

 Apache has one server block enabled by default that is configured to serve documents from the /var/www/html directory

 #### I left this  configuration and created my own directory next to the default
 
  I created this directory using the command
    
    sudo mkdir /var/www/projectlamp

 I then assigned ownership of this directory via 
    
    sudo chown -R  $USER:$USER /var/www/projectlamp

Finally I created and opened a new config file in Apache's sites-available directory using the vi command-line editor

    sudo vi /etc/apache2/sites-available/projectlamp.cfg

 ![Alt text](Screens/s4-a-c.png) 

#### This created  a new blank file and opened it to allow editing

The following bare-bones configuration was then inserted by pressing the i key to enter insert mode

    <VirtualHost *:80>
        ServerName projectlamp
        ServerAlias www.projectlamp 
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/projectlamp
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>

 ![Bare-Bones Config](Screens/s4-d-barebones-config.png)


To save and close the file follow the steps below

    1. Press the esc key
    2. Type :
    3. Type wq  (w is write q is quit)
    4. Press Enter

The following command will show the new file in the Sites-available directory

    sudo ls /etc/apache2/sites-available
 
 ![sites-avail](Screens/s4-e-.conf-files.png)

To enable the newly configured virtual host input the following command

    sudo a2ensite projectlamp
    
 ![enable virtual host](Screens/s4-f-enable-site.png) 

To disable Apache default website  

    sudo a2dissite 000-default

 ![disable default ](Screens/s4-g-disable-default.png) 

To check for syntax errors in the configuration file  and to reload Apacheuse the following lines of code

    sudo apache2ctl configtest

    sudo systemctl reload apache2

![Config syntax error check and reload commands](Screens/s4-h-itest-reload.png)

To test the virtual host is properly working

 Create and index.html file in the web root /var/www/projectlamp 

     sudo echo 'Hello LAMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/projectlamp/index.html
  
 ![Virtual host test](Screens/s4-j-echo-to-web.png)

## **Enable PHP on the Website**

The default Directory index settings of Apache create a presidence of index.html over index.php.
For website maintenence creating a temporary index.html file will direct end users to that over the actual index.php
After maintenence is finished the index.html is renamed or removed  allowing access to the regualr application page
### Editing Directory Index 
To change the Directory Index behavior  I changed the order in which the index.php file is listed using the following to open vim

       sudo vim /etc/apache2/mods-enabled/dir.conf

and to change the directory order

    <IfModule mod_dir.c>
        #Change this:
        #DirectoryIndex index.html index.cgi index.pl index.php index.xhtml index.htm
        #To this:
        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
    </IfModule>


![vim editing config](Screens/s5-a-vim-edit-conf.png)

Once this is complete Apache Must be reloaded for changes to take effect

![Alt text](Screens/s5-b-reload-apache2.png)

A PHP test script was created and put into a newly created file "index.php" to confirm that Apache can handle and process PHP requests

File creation

    $ vim /var/www/projectlamp/index.php

![index.php](Screens/s5-c-create-write-php-file-code.png)

File edit in vim

    <?php
    phpinfo();

![editing php code](Screens/s5-c2-php-code.png)


Once finished save and close the file and refresh the webpage that had the Apache Default Page.

![SUCCESS](Screens/SUCCESS.png)

## **If this is what poped up upon refresh that means it has been done correctly**

It is best to remove this file that was created for security reasons

It is removed the following way

    $ sudo rm /var/www/projectlamp/index.php

![Alt text](Screens/saftey-removal.png)