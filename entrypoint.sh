#!/bin/bash
set -e

# Пробуем применить миграции несколько раз
echo "Trying to apply migrations..."
for i in {1..5}; do
    if python manage.py migrate --noinput; then
        echo "Migrations applied successfully!"
        break
    else
        echo "Migration attempt $i failed, retrying in 5 seconds..."
        sleep 5
    fi
    
    if [ $i -eq 5 ]; then
        echo "WARNING: Could not apply migrations, starting anyway..."
    fi
done

# Запускаем Gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8000 rental_project.wsgi:application