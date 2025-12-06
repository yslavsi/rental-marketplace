from django.urls import path
from django.shortcuts import redirect
from django.contrib.auth import logout
from django.contrib.auth.decorators import login_required
from rental.views import home
from rental.views import health_check
from . import views

def user_logout(request):
    logout(request)
    return redirect('home')

urlpatterns = [
    path('', lambda request: HttpResponse('<h1>Rental Marketplace работает! 🎉</h1>'), name='home'),
    path('health/', health_check, name='health_check'),
    path('', views.home, name='home'),
    path('listing/create/', views.create_listing, name='create_listing'),
    path('dashboard/', views.dashboard, name='dashboard'),
    path('accounts/logout/', user_logout, name='logout'),  # ✅ Logout!
]
