#!/bin/bash
set -e

# Créer .env depuis .env.example si absent
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Attendre que MySQL soit prêt
echo "En attente de MySQL..."
while ! php -r "
    try {
        new PDO(
            'mysql:host=${DB_HOST};port=${DB_PORT}',
            '${DB_USERNAME}',
            '${DB_PASSWORD}'
        );
        exit(0);
    } catch (Exception \$e) {
        exit(1);
    }
" 2>/dev/null; do
    sleep 2
done

echo "MySQL est prêt."

# Générer la clé d'application si nécessaire
if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    php artisan key:generate --force
fi

# Exécuter les migrations
php artisan migrate --force

exec "$@"
