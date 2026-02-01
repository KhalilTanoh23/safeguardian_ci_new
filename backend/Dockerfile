FROM php:8.5-alpine

# Installer les dépendances système
RUN apk add --no-cache \
    postgresql-client \
    postgresql-dev \
    curl \
    git \
    && rm -rf /var/cache/apk/*

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql

# Copier le code de l'application
WORKDIR /var/www/html
COPY backend/ .

# Définir les permissions
RUN chown -R nobody:nobody /var/www/html

# Exposer le port
EXPOSE 8000

# Commande par défaut (serveur PHP intégré)
CMD ["php", "-S", "0.0.0.0:8000"]
