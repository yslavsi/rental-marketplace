from django.contrib import admin
from .models import Category, Listing, Booking, Message

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'parent']
    list_filter = ['parent']

@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ['title', 'owner', 'category', 'price_per_unit', 'price_unit', 'status', 'created_at']
    list_filter = ['status', 'category', 'price_unit', 'created_at']
    search_fields = ['title', 'description', 'owner__username']
    readonly_fields = ['views_count', 'created_at', 'updated_at']

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ['listing', 'renter', 'start_date', 'end_date', 'total_price', 'status']
    list_filter = ['status', 'start_date', 'created_at']
    search_fields = ['listing__title', 'renter__username']

admin.site.register(Message)
