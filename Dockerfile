FROM debian:jessie

################################################################################
# Installation de wget
################################################################################

RUN \
    apt-get -qq update --fix-missing && \
    apt-get -qq install -y \
    wget

################################################################################
# Mise en place de DotDeb
################################################################################

RUN echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list && \
    echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list.d/dotdeb.org.list && \
    wget http://www.dotdeb.org/dotdeb.gpg -O dotdeb.gpg && \
    apt-key add dotdeb.gpg
################################################################################
# Installation des Libs Apache / PHP7 / Extensions de PHP
################################################################################
RUN \
    apt-get -qq update --fix-missing && \
    apt-get -qq install -y \
    php7.0 \
    apache2 \
    libapache2-mod-php7.0 \
    php7.0-mysql \
    php7.0-gd \
    php7.0-imagick \
    php7.0-dev \
    php7.0-curl \
    php7.0-opcache \
    php7.0-cli \
    php7.0-intl \
    php7.0-json \
    php7.0-mcrypt \
    php7.0-common \
    php7.0-apcu-bc \
    php7.0-mbstring \
    php7.0-zip
#   php7.0-soap \
#   php7.0-memcached \
#   php7.0-redis \
#   php7.0-xml \
#   php7.0-pspell \
#   php7.0-recode \
#   php7.0-common \
#   php7.0-sybase \
#   php7.0-sqlite3 \
#   php7.0-bz2 \
#   php7.0-sqlite \
#   php7.0-fpm \
#   php7.0-tidy \
#   php7.0-imap \
#   php7.0-shmop \

################################################################################
# Paramétrage de Apache / Inspiré de l'image php:7.0-latest
################################################################################

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

# Activation des modules Apache
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.0 && \
    a2enmod rewrite

# logs should go to stdout / stderr
RUN set -ex \
	&& . "$APACHE_ENVVARS" \
	&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
	&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"

################################################################################
# Installation des dépendances relatives au projet selfimmo
################################################################################

RUN apt-get -qq update --fix-missing \
    && apt-get -qq install -y build-essential \
    libxrender-dev \
    #TODO : confirmer que libldap2 est nécessaire
    libldap2-dev \
    zip \
    unzip \
    vim \
    curl \
    wkhtmltopdf

WORKDIR /var/www/html

################################################################################
# Installation de composer
################################################################################

# /!\ le hash impose une version particulière
# (voir https://getcomposer.org/download/ pour la dernière version)

RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
#RUN  wget --no-check-certificate https://getcomposer.org/installer -O composer-setup.php \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === 'e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer \
    && chmod 755 /usr/local/bin/composer


################################################################################
# Suppression des fichiers temporaires.
################################################################################
RUN apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

################################################################################
# Autorisations sur les répertoires caches et log.
################################################################################

RUN \
    mkdir -p /var/www/html/app/cache && \
    mkdir -p /var/www/html/app/logs && \
    chown -R www-data:www-data /var/www/html/app/cache && \
    chown -R www-data:www-data /var/www/html/app/logs

################################################################################
# Autorisations sur le répertoire composer
################################################################################

RUN \
    mkdir -p /var/www/.composer && \
    chown -R www-data:www-data /var/www/.composer
