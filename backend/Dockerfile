# backend/Dockerfile
FROM python:3.11-slim-bullseye

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    curl \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию
WORKDIR /app

# Устанавливаем Poetry (если используете) или копируем requirements
COPY requirements.txt .

# Устанавливаем Python зависимости
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Копируем все файлы проекта
COPY . .

# Создаем пользователя для безопасности
RUN useradd -m -u 1000 django && \
    chown -R django:django /app

# Настройка Nginx
COPY deploy/nginx.conf /etc/nginx/sites-available/default
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Настройка Supervisor
COPY deploy/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Собираем статические файлы
RUN python manage.py collectstatic --noinput

# Открываем порты
EXPOSE 8000

# Переключаемся на непривилегированного пользователя
USER django

# Запускаем через Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "3", "rental_project.wsgi:application"]