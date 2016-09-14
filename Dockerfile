FROM php:7.0-apache

# WKHTML2PDF
RUN apt-get update && apt-get install -y build-essential \ 
    libssl-dev \
    libxrender-dev \
    wget \
    gdebi

WORKDIR /var/www/html

RUN wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    gdebi --n wkhtmltox-0.12.2.1_linux-jessie-amd64.deb && \
    rm wkhtmltox-0.12.2.1_linux-jessie-amd64.deb
