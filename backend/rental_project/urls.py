from django.contrib import admin
from django.urls import path
from rental.views import home, health_check

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check, name='health_check'),
    path('', home, name='home'),
]
