FROM php:8.2.8-apache
WORKDIR faveo-web
ENV APP_ENV=dev
ENV APP_DEBUG=true
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN apt-get update && apt-get install -y zip libzip-dev libc-client-dev libkrb5-dev
RUN rm -r /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install pdo pdo_mysql bcmath zip imap mysqli
COPY faveo /var/www/html
COPY 000-default.conf /etc/apache2/sites-available
COPY php.ini /usr/local/etc/php/
COPY .env /var/www/html/.env
RUN chmod 777 -R /var/www/html/storage/
RUN chown -R www-data:www-data /var/www/
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer
RUN rm -rf /var/www/html/faveo-web
RUN a2enmod rewrite
RUN service apache2 restart
