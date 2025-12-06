# Dockerfile в корне (с правильными путями)
FROM python:3.11-slim

WORKDIR /app

# Копируем requirements.txt из backend
COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь проект Django
COPY backend/ .

# Создаем пользователя
RUN useradd -m -u 1000 django && chown -R django:django /app
USER django

# Собираем статику
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "rental_project.wsgi:application"]