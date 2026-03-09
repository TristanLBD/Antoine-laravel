# Lancer le projet avec Docker

## Prérequis

- Docker et Docker Compose installés

## Démarrage

```bash
# Construire et lancer les conteneurs (app Laravel + MySQL)
docker compose up -d --build

# L'application est accessible sur http://localhost:8000
# MySQL est accessible sur localhost:3306 (user: laravel, password: secret, database: laravel)
```

Au premier lancement, le script d’entrée :

- attend que MySQL soit prêt ;
- génère `APP_KEY` si besoin ;
- exécute les migrations.

## Commandes utiles

```bash
# Voir les logs
docker compose logs -f app

# Exécuter des commandes Artisan dans le conteneur
docker compose exec app php artisan migrate
docker compose exec app php artisan tinker

# Installer des dépendances Composer (après modification de composer.json)
docker compose exec app composer install

# Arrêter les conteneurs
docker compose down

# Arrêter et supprimer les données MySQL
docker compose down -v
```

## Variables d’environnement

Les variables liées à la base sont définies dans `docker-compose.yml` et écrasent le `.env` pour l’app :

- `DB_HOST=mysql`
- `DB_DATABASE=laravel`
- `DB_USERNAME=laravel`
- `DB_PASSWORD=secret`

Pour un `.env` local avec Docker, vous pouvez copier `.env.example` et adapter si besoin (les valeurs du compose restent prioritaires).
