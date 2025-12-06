from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.core.paginator import Paginator
from django.db.models import Q
from django.utils import timezone
from .models import Listing, Booking, Category, Message
from .forms import BookingForm, ListingForm, RegisterForm
from django.contrib.auth import logout
from django.shortcuts import redirect

def home(request):
    listings = Listing.objects.filter(status='active').order_by('-created_at')[:12]
    categories = Category.objects.filter(parent=None)
    return render(request, 'home.html', {'listings': listings, 'categories': categories})

def listing_list(request):
    query = request.GET.get('q', '')
    category_id = request.GET.get('category')
    location = request.GET.get('location')
    
    listings = Listing.objects.filter(status='active')
    
    if query:
        listings = listings.filter(Q(title__icontains=query) | Q(description__icontains=query))
    if category_id:
        listings = listings.filter(category_id=category_id)
    if location:
        listings = listings.filter(location__icontains=location)
    
    paginator = Paginator(listings, 12)
    page_number = request.GET.get('page')
    listings = paginator.get_page(page_number)
    
    return render(request, 'listings/list.html', {'listings': listings})

def listing_detail(request, pk):
    listing = get_object_or_404(Listing, pk=pk, status='active')
    listing.views_count += 1
    listing.save()
    
    if request.method == 'POST':
        form = BookingForm(request.POST, listing=listing)
        if form.is_valid():
            booking = form.save(commit=False)
            booking.listing = listing
            booking.renter = request.user
            booking.total_price = listing.calculate_price(booking.start_date, booking.end_date)
            booking.save()
            messages.success(request, 'Запрос на аренду отправлен!')
            return redirect('booking_success', booking.pk)
    else:
        form = BookingForm(listing=listing)
    
    return render(request, 'listings/detail.html', {'listing': listing, 'form': form})

@login_required
def create_listing(request):
    if request.method == 'POST':
        form = ListingForm(request.POST)
        if form.is_valid():
            listing = form.save(commit=False)
            listing.owner = request.user
            listing.save()
            messages.success(request, 'Объявление создано!')
            return redirect('dashboard')
    else:
        form = ListingForm()
    return render(request, 'accounts/create_listing.html', {'form': form})

@login_required
def dashboard(request):
    user_listings = request.user.listings.filter(status='active')
    pending_bookings = Booking.objects.filter(listing__owner=request.user, status='pending')
    user_rentals = request.user.rentals.all()
    
    return render(request, 'accounts/dashboard.html', {
        'user_listings': user_listings,
        'pending_bookings': pending_bookings,
        'user_rentals': user_rentals
    })

@login_required
def manage_bookings(request, pk):
    booking = get_object_or_404(Booking, pk=pk, listing__owner=request.user)
    
    if request.method == 'POST':
        action = request.POST.get('action')
        if action == 'confirm':
            booking.status = 'confirmed'
            messages.success(request, 'Бронь подтверждена!')
        elif action == 'reject':
            booking.status = 'rejected'
            messages.success(request, 'Бронь отклонена!')
        booking.save()
        return redirect('dashboard')
    
    return render(request, 'accounts/manage_booking.html', {'booking': booking})

@login_required
def user_logout(request):
    """Выход из аккаунта"""
    logout(request)
    return redirect('home')