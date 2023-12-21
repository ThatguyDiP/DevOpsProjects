# DEVOPS TOOLING WEBSITE SOLUTION

## In this project a tooling website is designed to store the commonly used tools in Devops using the following components

    Infrastructure : 
        AWS

    Webserver : 
        RHEL-8.6

    Database Server : 
        Ubuntu 20.04 &  MySQL

    Storage Server :
        RHEL-8.6 Network File System (NFS) Server

    Programming Language : 
        PHP

    Code Repository : 
        GitHub

## IMPLAMENTATION

## The backend storage server being used in this project is setup as a NFS Server

### Below are the steps to creating the NFS Server :

    Create AWS Instance
    Create & Attach Volumes
    Setup the server
    Configure the NFS Server to be accessible to the Webservers
 
## **1. Prepare the NFS Server**

- I spun up a new EC2 Instance loaded with a  specific RHEL 8.6.0 ami

     ![AMI](Screens/NFS/NFS-AMI.png)

- Creation & attachment of 3 volumes fou use by NFS Server

    ![Volume-Create](Screens/NFS/NFS-VOLUME-CREATE.png)

    ![Volume-Attach](Screens/NFS/NFS-ATTACH.png)

- Connection  via ssh, to confirm volume availability

        lsblk

        df-h


     ![CON&CONFIRM](Screens/NFS/Connect-Confirm.png)

### **Configuring LVM on NFS Server**

 - Partitioning :

    **Using ***gdisk*** utility :**

        sudo gdisk /dev/xvdf 


    ![XVDF-Part](Screens/NFS/xvdf-part.png)

        sudo gdisk /dev/xvdg

    ![xvdg-part](Screens/NFS/xvdg-part.png)

        sudo gdisk /dev/xvdh

    ![XVDH-PART](Screens/NFS/xvdh-part.png)

 - Install lvm2 package :

        sudo yum install lvm2 -y

    ![Install-lvm](Screens/NFS/lvm-install.png)

 - Using pvcreate to create physical volumes on the partitions
        
        sudo pvcreate /dev/xvdf1
        
        sudo pvcreate /dev/xvdg1

        sudo pvcreate /dev/xvdh1

    ![Physical-Volume-Creation](Screens/NFS/pvcreate.png)

 - Using vgcreate to construct a Volume Group 'webdata'

        sudo vgcreate webdata-vg /dev/xvdf1 /dev/xvdg1 /dev/xvdh1

    ![webdata-vg-creation](Screens/NFS/webdata-vg-create.png)

 - Using lvcreate to make Logical Volumes, apps, logs, opt

        sudo lvcreate -n lv-apps -L 9GiB webdata-vg

        sudo lvcreate -n lv-logs -L 9GiB webdata-vg

        sudo lvcreate -n lv-opt -L 9GiB webdata-vg

    ![lvcreate](Screens/NFS/lvcreate-apps-logs-opt.png)

    Verification of  PV,VG,LV Creation :

    ![vg-display](Screens/NFS/vg-display.png)

 - Formatting 
    
    MKSF Utility is used to format the disks to xfs

        sudo mkfs -t xfs /dev/webdata-vg/lv-apps

        sudo mkfs -t xfs /dev/webdata-vg/lv-logs

        sudo mkfs -t xfs /dev/webdata-vg/lv-opt
        
    ![Formatting](Screens/NFS/Formatting.png)

 - Create mount points and mounting of the logical volumes

     lv-apps -> /mnt/apps : 
to be used by webservers
    
            sudo mkdir /mnt/apps
            sudo mount /dev/webdata-vg/lv-apps /mnt/apps


     lv-logs -> /mnt/logs : to be used by webserver logs

            sudo mkdir /mnt/logs
            sudo mount /dev/webdata-vg/lv-logs /mnt/logs

     lv-opt -> /mnt/opt : to be used by Jenkins in a future project

            sudo mkdir /mnt/opt
            sudo mount /dev/webdata-vg/lv-opt /mnt/opt

![create-n-mount](Screens/NFS/create-point-and-mount.png)

### **Install NFS Server**

- Install

        sudo yum update -y
        sudo yum install nfs-utils -y

![update-install](Screens/NFS/yum-update-nfs-utils-install.png)

- Configure to start on reboot

        sudo systemctl start nfs-server.service

        sudo enable nfs-server.service

- Verify the server is up and running

        sudo systemctl status nfs-server.service
        
    ![Alt text](Screens/NFS/systemctl-start-enable-status-nfs-server.png)

### **Exporting Mounts for webservers on Subnet**

 - Setting Permissions to webservers for read, write, execute of NSF files

        sudo chown -R nobody: /mnt/apps
        sudo chown -R nobody: /mnt/logs
        sudo chown -R nobody: /mnt/opt

        sudo chmod -R 777 /mnt/apps
        sudo chmod -R 777 /mnt/logs
        sudo chmod -R 777 /mnt/opt

![permissions](Screens/NFS/nfs-permissions.png)

 - Restart NFS Server Services

        sudo systemctl restart nfs-server.service

        sudo systemctl status nfs-server.service

![restart-status](Screens/NFS/restart-nfs-status-nfs-server.png)

 - Configure client access of NFS on subnet CIDR - 172.31.16.0/20
    
        sudo vi /etc/exports

             /mnt/apps 172.31.16.0/20(rw,sync,no_all_squash,no_root_squash)

            /mnt/logs 172.31.16.0/20(rw,sync,no_all_squash,no_root_squash)

            /mnt/opt 172.31.16.0/20(rw,sync,no_all_squash,no_root_squash)

![vi-exports](Screens/NFS/vi-exports.png)

        sudo exportfs -arv    

![exportfs](Screens/NFS/exportfs-arv.png)

 - Check ports used by NFS and create new inbound rules  for EC2 Security Group

        rpcinfo -p | grep nfs

![ports](Screens/NFS/NFS-Port.png)


***IMPORTANT NOTE :***

For the NFS server to be accessable from the client the following ports must be opened

    TCP 111
    UDP 111
    TCP 2049
    UDP 2049

![Inbound-rules](Screens/NFS/inbound-rules.png)

## **2. Configure the Database Server**

### For this section I will :

1. Spin up an EC2 Instance with ubuntu 20.04 

2. Install MySQL Server

3. Create a database named tooling

4. Grant full permission to the user webaccess on tooling database **ONLY** from within the *172.31.16.0/20 Subnet*
 
 
## - Connecting to Server, Updating, Installing MySQL

![ssh-in](Screens/Database/ssh-database.png)

    sudo apt update -y

![apt update](Screens/Database/apt-update.png)


![alter-mysql-user](Screens/Database/alter-user-mysql.png)

![Secure-installation](Screens/Database/secure-instal.png)

![GRANT_ALL_PERMISSIONS](Screens/Database/GRANT-ALL-PERMISSIONS.png)



## **Preparing the Wweb Servers**

### I spun up 3 EC2 Instances with Rhel 8 Operating systems

During the next steps I will :

- Configure NFS Client (on all 3 webservers)


Beyond this I have no idea what happened nothi9ong I or the support staff @ DAREY.IO could help me get to a solution


Here are the screenshots of what i have done::

![Alt text](Screens/webserver/apache-files-dir-nfs.png)


![Alt text](Screens/webserver/apache-files-dir.png)

![Alt text](Screens/webserver/disable-selinux.png)

![Alt text](Screens/webserver/enable-remi-7.4.png)
![Alt text](Screens/webserver/fedora-dl.png)
![Alt text](Screens/webserver/fstab-edit.png)
![Alt text](Screens/webserver/fstab-edit.png)![Alt text](Screens/webserver/httpd-install.png)![Alt text](Screens/webserver/install-php.png)![Alt text](Screens/webserver/logs-mount-daemon-reload.png)![Alt text](Screens/webserver/logs-mount-fstab.png)![Alt text](Screens/webserver/nfs-util-installx3.png)![Alt text](Screens/webserver/remirepo-8-install.png)![Alt text](Screens/webserver/reset-module-php.png)![Alt text](Screens/webserver/start-enable-setsbool.png)![Alt text](Screens/webserver/start-enable-setsbool.png)![Alt text](Screens/webserver/touch-test-ws-1-all-showing.png)![Alt text](Screens/webserver/var-www-mount-nfs-target.png)![Alt text](Screens/webserver/webbrowser-pre-config.png)