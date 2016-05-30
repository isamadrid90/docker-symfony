FROM debian:jessie

MAINTAINER Vincent Chalamon <vincentchalamon@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      curl \
      nginx \
      mysql-client \
      php5 \
      php5-curl \
      php5-fpm \
      php5-intl \
      php5-pgsql \
      php5-mysql \
      php5-memcache \
      php5-apcu \
      php-twig \
      supervisor \
      php5-xdebug \
      vim

# Configure PHP-FPM & Nginx
RUN sed -e 's/;daemonize = yes/daemonize = no/' -i /etc/php5/fpm/php-fpm.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /etc/php5/fpm/pool.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /etc/php5/fpm/pool.d/www.conf \
    && echo "opcache.enable=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "opcache.enable_cli=1" >> /etc/php5/mods-available/opcache.ini \
    && echo "\ndaemon off;" >> /etc/nginx/nginx.conf

RUN echo 'date.timezone = "Europe/Madrid";' >> /etc/php5/cli/php.ini

RUN echo "zend_extension=$(find /usr/lib/php5/ -name xdebug.so)" > /etc/php5/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /etc/php5/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_autostart=1" >> /etc/php5/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_host=localhost" >> /etc/php5/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /etc/php5/fpm/conf.d/20-xdebug.ini


ADD supervisor.conf /etc/supervisor/conf.d/supervisor.conf
ADD vhost.conf /etc/nginx/sites-available/default

RUN usermod -u 1000 www-data

VOLUME /var/www
WORKDIR /var/www

EXPOSE 80

CMD ["/usr/bin/supervisord"]
