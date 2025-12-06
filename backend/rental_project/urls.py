from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.auth import views as auth_views

urlpatterns = [
    path('health/', health_check, name='health_check'),
    path('', views.home, name='home'),
    path('admin/', admin.site.urls),
    path('', include('rental.urls')),
    path('accounts/', include('django.contrib.auth.urls')),  # ✅ LOGIN + LOGOUT!
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
