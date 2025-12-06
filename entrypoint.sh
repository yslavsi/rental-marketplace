#!/bin/bash
set -e

# Ждем БД
while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
    sleep 1
done

# Миграции
python manage.py migrate --noinput

# Собираем статику
python manage.py collectstatic --noinput

# Создаем суперпользователя
echo "Creating superuser..."
python << EOF
import os
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
EOF

# Запускаем Gunicorn
exec gunicorn --workers=3 --bind 0.0.0.0:8000 rental_project.wsgi:application