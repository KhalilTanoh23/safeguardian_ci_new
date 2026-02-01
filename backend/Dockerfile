FROM php:8.5-fpm-alpine

# Installer les dépendances système
RUN apk add --no-cache \
    postgresql-client \
    postgresql-dev \
    nginx \
    curl \
    git

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    json

# Copier le code de l'application
WORKDIR /var/www/html
COPY backend/ .

# Définir les permissions
RUN chown -R www-data:www-data /var/www/html

# Exposer le port
EXPOSE 8000

# Commande par défaut (serveur PHP intégré pour dev)
CMD ["php", "-S", "0.0.0.0:8000"]
