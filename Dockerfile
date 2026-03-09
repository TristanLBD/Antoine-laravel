# Stage 1 : build des assets front (Vite) avec Node
FROM node:20-bookworm-slim AS nodebuilder
WORKDIR /var/www/html
COPY package.json ./
COPY resources ./resources
COPY public ./public
COPY vite.config.js ./
RUN npm install && npm run build

# Stage 2 : application Laravel (PHP + Nginx)
FROM php:8.2-fpm-bookworm

# Dépendances système
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    libzip-dev \
    libpng-dev \
    libxml2-dev \
    libicu-dev \
    libonig-dev \
    default-mysql-client \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Extensions PHP pour Laravel
RUN docker-php-ext-install \
    pdo_mysql \
    zip \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    opcache

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copie de l'application (sans vendor, géré par composer install)
COPY . .

# Récupération des assets buildés depuis le stage Node
COPY --from=nodebuilder /var/www/html/public/build ./public/build

# Installation des dépendances PHP (sans dev en prod, on garde dev pour artisan)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

EXPOSE 80

COPY docker/nginx/default.conf /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
