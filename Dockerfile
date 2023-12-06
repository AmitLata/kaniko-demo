# This Docker file will install, configure and Deploy Apache web server and its code
FROM centos:7

# Author Details
MAINTAINER Amit Lata <amit.lata80@gmail.com>

# Adding Meta Data to my Docker Image (LABEL)
LABEL version="1.0.0" appname="offersapp" builddate="18-8-2018" reldate="19-8-2018"

# To update the OS and then Install Apache Web Server
RUN yum -y update
RUN yum -y install httpd

# To Deploy Some Code
RUN mkdir -p /var/www/html
copy index.html /var/www/html
RUN echo $HOSTNAME >> /var/www/html/index.html

# EXPOSE the port of container to external world for communication
EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
