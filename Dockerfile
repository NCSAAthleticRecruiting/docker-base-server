# Dockerfile for Apache web server.

# Select ubuntu as the base image
# # http://phusion.github.io/baseimage-docker/
# Extends smartive/varnish which enables varnish on top of phusion base
FROM phusion/baseimage:0.9.15

RUN apt-get update -qy && apt-get dist-upgrade -qy && apt-get install -qy git mysql-client apache2 libapache2-mod-php5 python-setuptools vim-tiny php5-mysql php5-gd php5-curl

RUN mkdir -p /srv/www/siteroot

# RUN useradd -rm ruby_dev -u 1000 -g 50

# don't add source code, going to mount it
# ADD . /srv/www/siteroot

RUN mkdir /data && chown -R www-data:www-data /data
RUN ln -s /data /srv/www/siteroot
RUN echo "The code for your application lives here. This will link directly to your site root folder." > /data/README.txt

# www
ADD www.conf /etc/apache2/sites-available/www.conf
# sites-common
ADD wwww /etc/apache2/sites-common/wwww

RUN a2ensite www
RUN a2dissite 000-default
RUN a2enmod usertrack
RUN a2enmod rewrite
RUN a2enmod proxy_http

# Make apache start and be monitored by runit
RUN mkdir /etc/service/apache
ADD apache.sh /etc/service/apache/run
RUN chmod +x /etc/service/apache/run

COPY server-base-start.sh /root/server-base-start.sh
RUN chmod 777 /root/server-base-start.sh

# Define default command.
CMD ["/root/server-base-start.sh"]

EXPOSE 80 3306 443 11211
