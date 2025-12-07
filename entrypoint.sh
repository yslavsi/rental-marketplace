#!/bin/bash
set -e

echo "=== Starting Django Application ==="

# 1. Применяем миграции (это точно работает)
echo "Applying database migrations..."
python manage.py migrate --noinput

# 2. Создаем суперпользователя ПРОСТЫМ способом
echo "Creating superuser..."
DJANGO_SUPERUSER_USERNAME=${DJANGO_SUPERUSER_USERNAME:-admin}
DJANGO_SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-admin@example.com}
DJANGO_SUPERUSER_PASSWORD=${DJANGO_SUPERUSER_PASSWORD:-admin123}

# Способ 1: Через команду createsuperuser (самый надежный)
echo "Creating superuser via createsuperuser command..."
python manage.py createsuperuser --noinput --username "$DJANGO_SUPERUSER_USERNAME" --email "$DJANGO_SUPERUSER_EMAIL" || true

# Если нужно установить пароль, делаем отдельно
echo "Setting superuser password..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
try:
    user = User.objects.get(username='$DJANGO_SUPERUSER_USERNAME')
    user.set_password('$DJANGO_SUPERUSER_PASSWORD')
    user.save()
    print('Superuser password updated')
except User.DoesNotExist:
    print('Superuser does not exist, skipping password set')
"

# 3. Запускаем Gunicorn
echo "Starting Gunicorn server..."
exec gunicorn --workers=3 --bind 0.0.0.0:8000 rental_project.wsgi:application