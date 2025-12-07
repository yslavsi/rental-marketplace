from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

# Health check для мониторинга
def health_check(request):
    return HttpResponse("OK", content_type="text/plain")

def home(request):
    return HttpResponse("""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Rental Market</title>
        <style>
            body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
            .success { color: green; font-size: 24px; }
            .error { color: red; }
        </style>
    </head>
    <body>
        <h1 class="success">✅ Django is Running!</h1>
        <p>Rental Market Application</p>
        <p>Database: Connected</p>
        <p>Gunicorn: Running on port 8000</p>
        <hr>
        <p><a href="/admin/">Admin Panel</a> | <a href="/health/">Health Check</a></p>
    </body>
    </html>
    """)

urlpatterns = [
    path('', home, name='home'),
    path('health/', health_check, name='health_check'),
    path('admin/', admin.site.urls),
    path('accounts/', include('accounts.urls')),
    path('rental/', include('rental.urls')),
]