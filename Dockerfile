FROM php:7.0.8-apache

# WKHTML2PDF
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libssl-dev \
    libxrender-dev \
    wget \
    gdebi

WORKDIR /var/www/html

RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    gdebi --n wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb

# Installation des dépendances
RUN \
    apt-get update && \
    apt-get install libldap2-dev -y && \
    apt-get install zip -y && \
    apt-get install unzip -y && \
    apt-get install vim -y && \
    apt-get install curl -y && \
    apt-get install wget -y && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql

# Active le module de réécriture d'apache
RUN \
    a2enmod rewrite

# Installation de composer
# /!\ le hash impose une version particulière (voir https://getcomposer.org/download/ pour la dernière version)
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && chmod 755 /usr/local/bin/composer

# Installation de l'extension PHP GD
RUN \
    apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev && \
    docker-php-ext-install -j$(nproc) iconv mcrypt && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd exif

# Suppression des fichiers temporaires.
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Autorisations sur les répertoires caches et log.
RUN \
    mkdir -p /var/www/html/app/cache && \
    mkdir -p /var/www/html/app/logs && \
    chown -R www-data:www-data /var/www/html/app/cache && \
    chown -R www-data:www-data /var/www/html/app/logs

# Autorisations sur le répertoire composer
RUN \
    mkdir -p /var/www/.composer && \
    chown -R www-data:www-data /var/www/.composer
