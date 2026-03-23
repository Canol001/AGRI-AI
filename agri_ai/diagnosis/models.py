# diagnosis/models.py
from django.db import models
from django.contrib.auth.models import User


class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile"
    )

    # Language choices - stored as short codes for efficiency
    LANGUAGE_CHOICES = [
        ('en', 'English'),
        ('sw', 'Kiswahili'),
        ('luo', 'Dholuo'),
    ]

    preferred_language = models.CharField(
        max_length=10,
        choices=LANGUAGE_CHOICES,
        default='en',
        verbose_name="Preferred Language"
    )

    # ────────────────────────────────────────────────
    # Human-readable language name (used in admin & API)
    # ────────────────────────────────────────────────
    @property
    def language_display(self):
        """Returns the full readable name instead of the short code"""
        return dict(self.LANGUAGE_CHOICES).get(self.preferred_language, "English")

    def __str__(self):
        return f"{self.user.username}'s profile"

    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"


class Diagnosis(models.Model):
    image = models.ImageField(upload_to='uploads/')
    disease_name = models.CharField(max_length=255)
    confidence = models.FloatField()

    # 🔥 recommendation storage (treatment & prevention)
    recommendation = models.JSONField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.disease_name} ({self.confidence}%)"

    class Meta:
        verbose_name = "Diagnosis"
        verbose_name_plural = "Diagnoses"


class Scan(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="scans"
    )
    image = models.ImageField(upload_to='scans/')
    disease_name = models.CharField(max_length=255)
    confidence = models.FloatField()

    # optional recommendation (mirror Diagnosis if you want)
    recommendation = models.JSONField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.disease_name}"

    class Meta:
        verbose_name = "Scan"
        verbose_name_plural = "Scans"
        ordering = ['-created_at']