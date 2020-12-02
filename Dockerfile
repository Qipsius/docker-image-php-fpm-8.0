FROM php:8.0.0-fpm-buster

RUN apt-get update && apt-get install -y sudo \
    nano \
    supervisor \
    git \
    zip \
    libzip-dev \
    unzip \
    openssl \
    procps \
    acl \
    zlib1g-dev \
    libxml2-dev \
    libpng-dev \
    wget \
    gdebi \
    gnupg \
    libpq-dev \
    librabbitmq-dev \
    libonig-dev
    # Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    composer --version; \
    mkdir /var/www/.composer; \
    chown -R www-data /var/www/.composer
    # Install MySQL
RUN apt-get install -y default-mysql-client
    # Install PostgreSQL
RUN apt-get install -y postgresql-client
    # Install Redis extension
RUN pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-enable redis
    # Install Opcache extension
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache
    # Install PostgreSQL extensions
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql
    # Install extensions
RUN docker-php-ext-install pdo \
    pdo_mysql \
    pdo_pgsql \
    bcmath \
    xml \
    gd \
    mbstring \
    soap \
    intl \
    posix \
    zip \
    mysqli \
    ftp
    #install ssh2
RUN apt-get install -y libssh2-1-dev
RUN cd /tmp && git clone https://git.php.net/repository/pecl/networking/ssh2.git && cd /tmp/ssh2 \
    && phpize && ./configure && make && make install \
    && echo "extension=ssh2.so" > /usr/local/etc/php/conf.d/ext-ssh2.ini \
    && rm -rf /tmp/ssh2
    # install ampq
RUN pecl install amqp; \
    docker-php-ext-enable amqp
    # Configure php
COPY config/tzone.ini /usr/local/etc/php/conf.d/tzone.ini
COPY config/uploads.ini /usr/local/etc/php/conf.d/uploads.ini
COPY config/errors.ini /usr/local/etc/php/conf.d/errors.ini
COPY config/cache.ini /usr/local/etc/php/conf.d/cache.ini
