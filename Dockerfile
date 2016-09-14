FROM php:7.0-apache

# WKHTML2PDF
RUN apt-get update && apt-get install -y build-essential \ 
    libssl-dev \
    libxrender-dev \
    wget \
    gdebi

WORKDIR /var/www/html
