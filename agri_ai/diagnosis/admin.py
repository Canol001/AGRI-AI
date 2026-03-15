# diagnosis/admin.py
from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from django.db.models import Avg, Count
from django.utils import timezone
from datetime import timedelta

from .models import Scan


@admin.register(Scan)
class ScanAdmin(admin.ModelAdmin):
    """
    Admin interface for managing crop disease scans.
    Includes image preview, user links, recommendation summary, stats dashboard, etc.
    """

    # ────────────────────────────────────────────────
    # List View Configuration
    # ────────────────────────────────────────────────
    list_display = (
        'thumbnail',
        'user_link',
        'disease_name',
        'confidence_display',
        'created_at',
        'recommendation_preview',
    )
    list_display_links = ('disease_name',)
    list_filter = (
        'created_at',
        'disease_name',
        'user',
    )
    search_fields = (
        'user__username',
        'user__email',
        'disease_name',
        'recommendation',
    )
    date_hierarchy = 'created_at'
    ordering = ('-created_at',)
    list_per_page = 25

    # ────────────────────────────────────────────────
    # Display Fields / Helpers
    # ────────────────────────────────────────────────
    def thumbnail(self, obj):
        """Small image preview in list view"""
        if obj.image:
            return format_html(
                '<img src="{}" style="max-height: 60px; border-radius: 4px; object-fit: cover;" />',
                obj.image.url
            )
        return "—"
    thumbnail.short_description = "Image"

    def user_link(self, obj):
        """Clickable link to the user admin page"""
        if obj.user:
            url = reverse("admin:auth_user_change", args=(obj.user.id,))
            return format_html('<a href="{}">{}</a>', url, obj.user.username or obj.user.email)
        return "—"
    user_link.short_description = "User"

    def confidence_display(self, obj):
        """Formatted confidence percentage"""
        return f"{obj.confidence:.1f}%"
    confidence_display.short_description = "Confidence"
    confidence_display.admin_order_field = 'confidence'

    def recommendation_preview(self, obj):
        """Short preview of the main recommendation text"""
        if not obj.recommendation:
            return "—"
        treatment = obj.recommendation.get('treatment', '')
        if treatment:
            return (treatment[:70] + "...") if len(treatment) > 70 else treatment
        return "No advice"
    recommendation_preview.short_description = "Treatment Advice"

    # ────────────────────────────────────────────────
    # Detail View (Change Form)
    # ────────────────────────────────────────────────
    readonly_fields = (
        'thumbnail_large',
        'user_with_stats',
        'created_at',
        'confidence_display_detail',
        'recommendation_formatted',
    )
    fields = (
        ('user_with_stats', 'created_at'),
        'thumbnail_large',
        ('disease_name', 'confidence_display_detail'),
        'recommendation_formatted',
    )

    def thumbnail_large(self, obj):
        """Full-size image preview in detail view"""
        if obj.image:
            return format_html(
                '<img src="{}" style="max-width: 100%; max-height: 500px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15);" />',
                obj.image.url
            )
        return "No image uploaded"
    thumbnail_large.short_description = "Scan Image"

    def user_with_stats(self, obj):
        """Link to user + quick stats"""
        if obj.user:
            url = reverse("admin:auth_user_change", args=(obj.user.id,))
            scan_count = obj.user.scans.count()
            return format_html(
                '<a href="{}">{}</a> • {} total scans',
                url, obj.user.username or obj.user.email, scan_count
            )
        return "—"
    user_with_stats.short_description = "User"

    def confidence_display_detail(self, obj):
        return f"{obj.confidence:.2f}%"
    confidence_display_detail.short_description = "Confidence Score"

    def recommendation_formatted(self, obj):
        """Pretty-print the recommendation JSON in detail view"""
        if not obj.recommendation:
            return "No recommendation data"
        html = "<div style='background:#f8f9fa; padding:12px; border-radius:6px; font-family:monospace;'>"
        for key, value in obj.recommendation.items():
            html += f"<strong>{key.title()}:</strong> {value}<br>"
        html += "</div>"
        return format_html(html)
    recommendation_formatted.short_description = "Full Recommendation"

    # ────────────────────────────────────────────────
    # Dashboard Stats on Change List Page
    # ────────────────────────────────────────────────
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}

        # Quick stats
        total_scans = Scan.objects.count()
        recent_30 = Scan.objects.filter(created_at__gte=timezone.now() - timedelta(days=30))
        recent_count = recent_30.count()
        avg_confidence = recent_30.aggregate(avg=Avg('confidence'))['avg']
        top_diseases = recent_30.values('disease_name').annotate(
            count=Count('id')
        ).order_by('-count')[:6]

        extra_context.update({
            'title': 'CropGuard Scans Overview',
            'total_scans': total_scans,
            'recent_scans_30_days': recent_count,
            'avg_confidence': round(avg_confidence or 0, 1),
            'top_diseases': top_diseases,
        })

        return super().changelist_view(request, extra_context=extra_context)

    # Use custom template to show stats dashboard-style
    change_list_template = "admin/scan_changelist.html"  # create this template

    # Optional: soft-delete action (if you have is_deleted field)
    actions = ['soft_delete_selected']

    def soft_delete_selected(self, request, queryset):
        updated = queryset.update(is_deleted=True)
        if updated:
            self.message_user(request, f"Successfully soft-deleted {updated} scans.")
    soft_delete_selected.short_description = "Soft delete selected scans"