FROM python:3.11-slim

# Сразу переходим в backend
WORKDIR /app

# Сначала копируем только requirements.txt
COPY backend/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Затем весь проект
COPY backend/ .

RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD sh -c "python manage.py migrate --noinput && python manage.py collectstatic --noinput && gunicorn --bind 0.0.0.0:8000 rental_project.wsgi:application"