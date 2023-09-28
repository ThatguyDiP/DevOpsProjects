# **Implementing Loadbalancers with Nginx**

For this project I spun up a total of three EC2 instances loaded with Ubuntu.

Two instances I installed apache webserver, opened port 8000 to allow traffic, and updated the default page to show their respective public ip addresses.

The final instance was loaded with Ubuntu and nginx was installed and configured as a load balancer to distribute traffic between the two webserver instances.
## **Webserver Creation**

### Webserver Setup

After I created, started, and edited inbound rules for two of EC2 instances loaded with Ubuntu I connected viaSSH,o updated and installed apache using the following compiled command

    sudo apt update -y && sudo apt install apache2 -y

![webserver setup](<Screens/Load Balancer/apache install.png>)

![webserver2 setup](<Screens/Load Balancer/apache install2.png>)

Once updated and installed I checked the functionality of apache on both servers

    sudo systemctl status apache2

![apache2 status](<Screens/Load Balancer/apache2 status.png>)

I edited configuration of the Apache webservers to serve content through port 8000 rather than the default port 80 by opening the configuration file with the vi editor

    sudo vi /etc/apache2/ports.conf 

![Listen port setup](<Screens/Load Balancer/apache port listen setup.png>)

I then opened and edited the virtual host statement to change the port from 80 to 8000. Again using vi

    sudo vi /etc/apache2/sites-available/000-default.conf

![Virtual host edit](<Screens/Load Balancer/port8000.png>)

Once edited, saved and quit from the vi editor i then restarted Apache to enact the changes 

    sudo systemctl restart apache2

![apache conf file setup and restart](<Screens/Load Balancer/apache config files and restart.png>)

### Creating html file

I created a new index.html file using vi for both servers using the command
    sudo vi index.html
 Once within the vi editor I entered the following text using the servers public ip where needed

            <!DOCTYPE html>
        <html>
        <head>
            <title>My EC2 Instance</title>
        </head>
        <body>
            <h1>Welcome to my EC2 instance</h1>
            <p>Public IP: YOUR_PUBLIC_IP</p>
        </body>
        </html>


![html index](<Screens/Load Balancer/html index setup.png>)

After saving and exiting vi I changed the file ownership via

    sudo cp -f ./index.html /var/www/html/index.html

The apache server must be restarted for changes to take effect this was done by

    sudo systemctl restart apache2

![apache restart](<Screens/Load Balancer/Apache Restart.png>)

To check the results I went to the public ip in a web browser

![webserver image](<Screens/Load Balancer/webserver 1 running.png>)

![Webserver 2](<Screens/Load Balancer/webserver 2 running.png>)

Now that that is all set up I moved onto the next step

## **Configuring Nginx as a Load Balancer**

### SETUP

Setting up the Final EC2 instance with Ubuntu, connecting via SSH, updating, and installing & configuring Nginx.

![Connecting to the 3rd ec2 instance](<Screens/Load Balancer/connecting to ec2.png>)

Next was updating / installing nginx

    sudo apt update -y && sudo apt install nginx -y

![nginx install](<Screens/Load Balancer/nginx server setup.png>)

Once update and install are complete I verified installation 

    sudo systemctl status nginx

![nginx status](<Screens/Load Balancer/nginx run status.png>)

Now its onto the configuring nginx to act as a load balancer!!

### Configuration

I opened the the nginx configuration file to edit using

    sudo vi /etc/nginx/conf.d/loadbalancer.conf

I then edited the file with my servers public ip's

![Nginx config](<Screens/Load Balancer/loadbalancer configureation.png>)

The sections of this file are

    - upstream backend_servers
        This defines a group of backend servers

    -server
       Located in the upstream block 
        Lists the addresses and ports of the backend servers

    - proxy_pass
        Located in the location block
            Sets up the load balancing
             Distributing requests to the backend servers

    - proxy_set_header
        Located in the the location block
            These lines pass the necessary headers to the backend servers to correctly handle the requests

![Loadbalance conf setup](<Screens/Load Balancer/loadbalancerconf setup.png>)

Once the file is completed, saved, and vi is closed test that syntax is correct

        sudo nginx -t

![Syntax test](<Screens/Load Balancer/nginx syntax test.png>)

If no errors are present restart nginx

    sudo systemctl restert nginx

![restart nginx](<Screens/Load Balancer/nginx restart.png>)

Once Nginx is restarted put the public ip into a web browser and it should show the webpages served by the webservers.

![Load balanced site](<Screens/Load Balancer/loadbalancedsite.png>)

