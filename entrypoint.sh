#!/bin/bash
set -e

echo "Waiting for PostgreSQL..."
# Используем Python для проверки порта
python -c "
import socket
import time
import sys

host = '${POSTGRES_HOST}'
port = ${POSTGRES_PORT}
max_attempts = 30

for i in range(max_attempts):
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((host, port))
        sock.close()
        if result == 0:
            print('PostgreSQL is ready!')
            sys.exit(0)
    except:
        pass
    
    if i < max_attempts - 1:
        print(f'Attempt {i+1}/{max_attempts}: Waiting for PostgreSQL...')
        time.sleep(2)

print('ERROR: PostgreSQL is not available')
sys.exit(1)
"

# Миграции
echo "Applying migrations..."
python manage.py migrate --noinput

# Создание суперпользователя через manage.py команду (ПРАВИЛЬНЫЙ СПОСОБ)
echo "Creating superuser..."
python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser created')
else:
    print('Superuser already exists')
"

# Запуск Gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8000 rental_project.wsgi:application