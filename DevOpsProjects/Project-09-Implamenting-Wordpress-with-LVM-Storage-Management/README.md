# **This Project is In Progress**

# **Implementing Wordpress Website with LVM Storage Management**

## In this project I will be creating a scalable  WordPress website using AWS EC2 and Logical Volume Management (LVM) storage.

### **Preparing the Web Server**

The site will be *ThreeTier Architecture*

    Client-server software architecture pattern that consists of 3 separate layers

        1. Presentation Layer (PL):
            The use interface as the client server / browser
        2. Business Layer (BL):
            Backend program that implements business logic. Application / Webserver
        3. Data Access / Management Layer (DAL):
            Computer data storage / data access layer consisting of Database Server / File System Server.
            such as FTP Server or NFS Server

 This will be demonstrated by

        1. Configuring storage subsystems for the Web & Database servers based on Linux OS. 

        2. Installing WordPress and connecting it to a remote MySQL database server.

## **Implementing LVM on Linux (Web & Database) Servers**

I launched an EC2 instance loaded with Redhat that will serve as the Web Server. Created 3 EBS Volumes with 10 GiB of space and attached to the running instance.

 To create the volumes i selected Volumes under the AWS dropdown Elastic Block Store -> create volume -> adjusted to the size needed-? made sure it was in the same availability zone as the instance-> selected create volume.

![ebs-creation](Screens/WBS/ebs-volume-creation.png)

To attach the volumes, one at a time, to an instance I selected the volume -> went to actions-> selected attach volume -> chose the instance to attach to.

![ebs-attach](Screens/WBS/attach-ebs.png)

I then connected to the webserver via ssh.

![ssh-ws](Screens/WBS/ws-ssh.png)

Once connected via ssh I checked what block devices were attached to the server. by using the command.

    lsblk

![LSBLK-1](Screens/WBS/lsblk-1.png)

The 3 volumes that were created and attached were named xvdf, xvdh, xvdg.

![ls-dev-verify](Screens/WBS/ls-dev-verification.png)

The command

    df -h

Shows all mounts and free space on the server



To create a single partition on the 3 disks I used gdisk

    sudo gdisk /dev/xvdf



    sudo gdisk /dev/xvdg



    sudo gdisk /dev/xvdh

![partition](Screens/WBS/partition-disk.png)

To check the partitioned disks I once again used the command

    lsblk

![lsblk-2](Screens/WBS/lsblk-2.png)

I installed lvm2 and ran sudo lvmdiskscan to check for available partitions

![lvmdiskscan](Screens/WBS/lvmdiscscan-ws.png)

To create a volume group of the 3 physical volumes installed I used pvcreate 

    sudo pvcreate /dev/xvdh1 /dev/xvdg1 /dev/xvdf1

Once the Physical Volumes (PV) were createdI verified by using the command

    sudo pvs

![c&c-pvs](Screens/WBS/create&check-PV.png)

To create a Volume Group (VG) I used the *vgcreate* utility to add the 3 PVs. This group was named webdata-vg and created by using 

    sudo vgcreate webdata-vg /dev/xvdf1 /dev/xvdg1 /dev/xvdh1 

Once the VG was created it was verified by inputting

    sudo vgs

![VG-CnC](Screens/WBS/VG-C&C.png)

After the volumes were created and verified, I created 2 logical volumes (LV). These logical volumes are apps-lv (one half of the PV in size) , and logs-lv ( the remaining space of the PV was used)

    sudo lvcreate -n apps-lv -L 14G webdata-vg
    sudo lvcreate -n logs-lv -L 14G webdata-vg



To verify the entire creation and setup of the physical and logical volumes, partitions i used the command 

    sudo vgdisplay -v #view complete setup - VG, PV, and LV
    sudo lsblk 

![vg-display](Screens/WBS/vg-display.png)

![lsblk-3](Screens/WBS/lsblk-3.png)

I then formatted the logical volumes with the ext4 filesystem

To do this the commands used are

    sudo mkfs -t ext4 /dev/webdata-vg/apps-lv
    sudo mkfs -t ext4 /dev/webdata-vg/logs-lv

![app-logs-lv-creation](Screens/WBS/apps-logs-lv-create.png)

Once the volumes were set and formatted an html directory was created to store the website files

    sudo mkdir -p /var/www/html

Another directory was also created to stre backups of log data

    sudo mkdir -p /home/recovery/logs

The directory /var/www/html was then mounted on the apps-lv Logical Volume

    sudo mount /dev/webdata-vg/apps-lv /var/www/html/

![c&m](Screens/WBS/dir-create-mount.png)

Next was to mount the recovery log storage onto the logs-lv Logical Volume

BEFORE mounting this directory it MUST be backed up using the *rsync* utility via

    sudo rsync -av /var/log/. /home/recovery/logs/

![rsync](Screens/WBS/rsync-backup.png)

Once mounted the existing data on /var/log will be deleted! Hence the previous backup of that location.

Mounting of /var/log on logs-lv is done by usig the command

    sudo mount /dev/webdata-vg/logs-lv /var/log

Restoring the backup of the var/log directory is done via

    sudo rsync -av /home/recovery/logs/. /var/log

![log-mount-restore](Screens/WBS/mount-restore-logs.png)

To set the mount configuration to reload after a server restart the /etc/fstab file must be updated by using the UUID of the device.

This is aquired by using

    sudo blkid

![UUID-gathering](Screens/WBS/blkid.png)

Once the UUID is found for the devices it needs to be added to the /etc/fstab file using vi

![fstab-edit](Screens/WBS/fstab-edit.png)

Time to test the configuration, reload the daemon and verify the completed setup!

    sudo mount -a

    sudo systemctl daemon-reload

    df -h



## **Installing WordPress** and *Configuring MySQL Database*

### **PREPARING THE DB SERVER**

To start the process for the database server, I created another Redhat EC2 Instance, as well as 3 more 10 GiB Volumes, and attached them just as before

Connection:

![dbs-ssh](Screens/DBS/db-ssh.png)

Update of server:

![dbs-update](Screens/DBS/dbss-update.png)

I checked for the volumes by using
    lsblk

![dbs-lsblk-1](Screens/DBS/dbs-lsblk-1.png)

I then created partitions on each of the volumes

    sudo gdisk /dev/xvdf

    sudo gdisk /dev/xvdg
    
    sudo gdisk /dev/xvdh

![dbs-partitions](Screens/DBS/dbs-partitions.png)

To check for available partitions I installed lvm2 and scanned the disk

    sudo lvmdiscscan

![ldbs-lvmdiscscan](Screens/DBS/dbs-lvmdiscscan.png)

I used pvcreate utility to mark the disks as Physical Volumes and used sudo pvs to verify their creation

    sudo pvcreate /dev/xvdf1

    sudo pvcreate /dev/xvdg1
    
    sudo pvcreate /dev/xvdh1

Once Verified I created and verified a Volume Group

    sudo lvcreate -n db-lv -L 29G database-vg
    
    sudo lvs

![db-lvs](Screens/DBS/dbs-lvs.png)

When mounted and the /etc/fstab was configured the daemon was reloaded and the setup was verified

![edit, mount, reload,verify](Screens/DBS/dbs-fstab-edit-mount-damion-reload-verify.png)


### **INSTALLING WORDPRESS ON THE WEBSERVER**

Once the database was setup I went back to the webserver. There I updated the repository, Installed wget, Apache, as well as Apache dependancies.


    sudo yum update -y

    sudo yum install wget -y
    
    sudo yum install httpd -y

    sudo yum install php -y

    sudo yum install php-mysqlnd -y

    sudo yum install php-fpm -y

    sudo yum install php-json -y

Once installed I enabled and started the Apache (httpd) service

    sudo systemctl enable httpd

![httpd-enable&start](Screens/WBS/httpd-enable-start.png)

### **INSTALLING MYSQL ON DB SERVER**

To install PHP and it's dependancies I used the following procedure.

    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    
![fedora](Screens/WBS/fedora-install.png)

    sudo yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm

![util-install](Screens/WBS/yum-util-install.png)

    sudo yum module list php
    
![module](Screens/WBS/module-list.png)

    sudo yum module reset php

![module-reset](<Screens/WBS/module reset.png>)
    
    sudo yum module enable php:remi-7.4
 
    sudo yum install php php-opcache php-gd php-curl php-mysqlnd

![install php php-opcache php-gd php-curl php-mysqlnd](<Screens/WBS/install php php-opcache php-gd php-curl php-mysqlnd.png>)
    
    sudo systemctl start php-fpm
    
    sudo systemctl enable php-fpm
    
    sudo setsebool -P httpd_execmem 1

![php-fpm-start-enable](Screens/WBS/php-fpm-start-enable.png)

Once installed I restarted httpd and verified its status

![status-httpd](Screens/WBS/httpd-status.png)

Next was to download and copy wordpress to the  location /var/www/html

This was done by the following:

    mkdir wordpress
    cd   wordpress
    sudo wget http://wordpress.org/latest.tar.gz
    sudo tar xzvf latest.tar.gz
    sudo rm -rf latest.tar.gz
    sudo cp wordpress/wp-config-sample.php wordpress/wp-config.php
    sudo cp -R wordpress /var/www/html/

![wordpress-check](Screens/WBS/wordpress-install-sheck.png)

Configuring SELinux Policies

    sudo chown -R apache:apache /var/www/html/wordpress
    sudo chcon -t httpd_sys_rw_content_t /var/www/html/wordpress -R
    sudo setsebool -P httpd_can_network_connect=1

## **Installing MySQL on Database Server**

I started by updating, then I installed mysql-server 

    sudo apt insstall mysql-server -y

![install-mysql-server](Screens/DBS/dbs-install-mysql-server.png)    

Once installed i checked the status of mysqld, it wasnt running, and was disabled.

I restarterd  mysqld, enabled , and checked its status once again to verify it was running correctly.

![status-restart-enable-status-mysqld](Screens/DBS/dbs-mysqld-status-restart-enable.png)

## **Configuring DB to work with Wordpress**

To configure the installed MySQL database I logged into MySQL, created the wordpress database, created a user and password, and granted permissions to access the database remotely.

    sudo mysql
        
        CREATE DATABASE wordpress;
        
        CREATE USER `myuser`@`<Web-Server-Private-IP-Address>` IDENTIFIED BY 'mypass';
        
        GRANT ALL ON wordpress.* TO 'myuser'@'<Web-Server-Private-IP-Address>';
        
        FLUSH PRIVILEGES;
        
        SHOW DATABASES;

    exit


![db-config-4-wordpress](Screens/DBS/dbs-mysql-wordpress-configuration.png)

Once completed I went and changed the instance inbound rules to ONLY allow access to the Database serverfrom the wordpress webserver on port 3306 

![Inbound-connecton-ws-only](Screens/DBS/Inbound-rule.png)

## **Configuring WordPress for Remote Connection to Database**

To connect to the database from the webserver I installed and tested the connectivity of mysql-client

    sudo mysql -u myuser -p -h 172.31.31.249
    
    SHOW DATABASES; 

![mysql-login-connection](Screens/WBS/ws-db-test-connection.png)

Once this was connecting via the command line I went into the wp-config file located in /var/www/html/wordpress and edited its contents to allow connection to the database

![wp-config-edit](Screens/WBS/wp-config-settings.png)

I then opened traffic from anywhere on port 80  via an inbound rule change on the webserver ec2 instance.

Once all was comleted I went to my webbrowser, input the public ip of the webserver ec2 followed bt /wordpress and the results are as follows

![MIND_BLOWN!!](Screens/Final-Final.png)





