# Dockerfile for Apache web server.

# Select ubuntu as the base image
# # http://phusion.github.io/baseimage-docker/
FROM phusion/baseimage:0.9.15

ENV HOME /root

# Make sure root user is added to apache group
RUN usermod -a -G www-data root

# Use baseimage-docker's init system.
COPY server-base-start.sh /root/server-base-start.sh
RUN chmod 777 /root/server-base-start.sh
CMD sh /root/server-base-start.sh && /sbin/my_init

RUN apt-get update -qy && apt-get dist-upgrade -qy && apt-get install -qy git mysql-client apache2 libapache2-mod-php5 python-setuptools vim-tiny php5-mysql php5-gd php5-curl sshfs

# Install SASS and Compass
RUN apt-get install ruby1.9.1 -y
RUN apt-get install ruby1.9.1-dev -y
RUN gem update rdoc
RUN apt-get install build-essential -y
RUN gem install sass -v 3.2.19
RUN gem install compass -v 0.12.6

# RUN useradd -rm ruby_dev -u 1000 -g 50
# don't add source code, going to mount it
# ADD . /srv/www/siteroot

RUN mkdir /data && chown -R www-data:www-data /data
RUN mkdir -p /srv/www && chown -R www-data:www-data /srv/www
RUN ln -s /data /srv/www/siteroot
RUN echo "The code for your application lives here. This will link directly to your site root folder." > /data/README.txt
RUN mv /var/www/html/index.html /data/

# www
ADD config/apache2/www.conf /etc/apache2/sites-available/www.conf
# sites-common
RUN mkdir -p /etc/apache2/sites-common
ADD config/apache2/wwww /etc/apache2/sites-common/wwww

RUN a2ensite www
RUN a2dissite 000-default
RUN a2enmod usertrack
RUN a2enmod rewrite
RUN a2enmod proxy_http

# Make apache start and be monitored by runit
RUN mkdir /etc/service/apache
ADD config/apache2/apache.sh /etc/service/apache/run
RUN chmod +x /etc/service/apache/run

EXPOSE 80 3306 443 11211