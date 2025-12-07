#!/bin/bash
set -e

# Функция проверки порта на Python (без netcat)
wait_for_db() {
    echo "Waiting for PostgreSQL at ${POSTGRES_HOST}:${POSTGRES_PORT}..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        # Используем Python для проверки порта
        python -c "
import socket
import sys
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)
    result = sock.connect_ex(('${POSTGRES_HOST}', ${POSTGRES_PORT}))
    sock.close()
    sys.exit(result)
except Exception as e:
    sys.exit(1)
" && break || sleep 2
        
        echo "Attempt $attempt/$max_attempts: PostgreSQL not ready..."
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        echo "ERROR: PostgreSQL is not available after $max_attempts attempts"
        exit 1
    fi
    
    echo "PostgreSQL is ready!"
}

# Ждем БД
wait_for_db

# Миграции
echo "Applying migrations..."
python manage.py migrate --noinput

# Создаем суперпользователя если не существует
echo "Creating superuser if needed..."
python << EOF
import os
import django
django.setup()
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print("Superuser 'admin' created")
EOF

# Запуск Gunicorn
echo "Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:8000 rental_project.wsgi:application