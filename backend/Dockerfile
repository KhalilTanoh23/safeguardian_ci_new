FROM php:8.5-alpine

# Installer les dépendances système et outils de build nécessaires
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    postgresql-dev \
    postgresql-client \
    curl \
    git \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm -rf /var/cache/apk/*

# Copier le code de l'application
WORKDIR /var/www/html
COPY backend/ .

# Définir les permissions
RUN chown -R nobody:nobody /var/www/html

# Port par défaut (Railway fournit $PORT à l'exécution)
ENV PORT=8000
EXPOSE 8000

# Lancer le serveur PHP intégré en utilisant la variable d'environnement $PORT
CMD ["sh", "-c", "php -S 0.0.0.0:${PORT:-8000} -t /var/www/html"]
