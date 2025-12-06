# backend/Dockerfile
FROM python:3.11-slim

# Amvera монтирует код в /workspace/
WORKDIR /workspace

# Копируем requirements.txt
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь проект
COPY . .

# Собираем статику
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "rental_project.wsgi:application"]