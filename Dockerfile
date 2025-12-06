# Dockerfile (без экранирования кавычек)
FROM python:3.11-slim

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

RUN python manage.py collectstatic --noinput

RUN if [ -n \"$POSTGRES_HOST\" ] || [ -f \"/app/db.sqlite3\" ]; then \
        python manage.py migrate --noinput; \
    else \
        echo \"Skipping migrations - no database configured\"; \
    fi
EXPOSE 8000

CMD gunicorn --bind 0.0.0.0:8000 rental_project.wsgi:application