# **Client-ServerArchitecture**

In this project I have connected from a client to a remote server, using MySQL as the DBMS, to gain an understanding of data management, connectivity, and communication between clients and servers.

## Setting up and connecting to EC2 Instances

For this project I have setup 2 AWS EC2 Instances. They are both loaded with ubuntu, connecter to via the terminal through SSH.

![Client](<Screens/aws client summary.png>)
 ![Server](<Screens/aws server summary.png>)

## Inbound Rule
Once the instances were up and running I created a new inbound rule within the aws security group used for the server instance.

    Port range  3306
    Source <client private ip>

This will allow an incoming connection from the client  on the default MySQL port.

![Setting Inbound Rule for port 3306](<Screens/inbound rule port 3360.png>)

## Installing MySQL

Prior to installation I updated via
 
     sudo apt update

To install Mysql to the client instance i used the command 

    sudo apt install mysql-client -y

![MYSQL CLIENT INSTALL](<Screens/MySQL CLient install.png>)

For the server side I installed MySQL-Server

    sudo apt install mysql-server -y

![MySQL Server Install](<Screens/mysql-server install.png>)

To verify the install i ran the following command on both instances

    system ctl status mysql

![MySQL Install Verify)](<Screens/mysql ststus .png>)

### Once installed I needed to create a user to be able to connect from the client to the server remotely. 

This was done through the following steps.

**1.** *Creating a secure installation of MySQL*

    sudo mysql-secure-installation

![MySQL Secure Install](<Screens/mysql secur install.png>)

**2.** *Creating a user with  password, and granting privileges*

    sudo mysql -u root -p

    CREATE USER 'username'@'host' IDENTIFIED BY 'password';

    GRANT ALL PRIVILEGES ON *.* TO 'user'@'host' WITH GRANT OPTION;

    **User and Host are changed to the username connecting and the private ip in which the connection is originating **

![MySQL User Creation](<Screens/mysql user setup.png>)

## Configuring MySQL Server for Remote Host Connection

To allow connections to the server remotely I needed to change the bind-address in the mysqld.cnf file from 127.0.0.1 to 0.0.0.0 using the vi editor

    sudo vi /etc/mysql/mysql.conf.d/mysqld.cnf 

![Editing mysqld.cnf](<Screens/edit of mysqld.cnf file.png>)

Once edited and saved **MySQL MUST BE RESTARTED** to enable changes

    sudo systemctl restart mysql

![Edit cnf and restart mysql](<Screens/edit-restart of myql cnf file.png>)

## Checking connectivity

### *Due to previous connectivity issues I added a step to the project.*

Installation and use of NMAP functionality on the client side

    nmap -Pn -p <port> <private ip >

![nmap client to server](<Screens/nmap 3306 from client to server.png>)

I also used ping from the Client to check the status of the server

    ping <server private ip>

![Ping server from client](<Screens/pinging server from client to checkl connection.png>)

## Making Connection

Once the ping and nmap was showing connection capabilities I logged into MySQL on the Client  and connected remotely to the server

    sudo mysql<username> @<private ip of server to be connected to>

Once connected Via MySQL I was able to verify connection by showing the database of the server on the client machine in the mysql shell

    show databases;

![Show database](<Screens/database showing on client.png>)