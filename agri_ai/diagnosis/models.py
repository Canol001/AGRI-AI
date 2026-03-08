from django.db import models
from django.contrib.auth.models import User


class Diagnosis(models.Model):
    image = models.ImageField(upload_to='uploads/')
    disease_name = models.CharField(max_length=255)
    confidence = models.FloatField()

    # 🔥 recommendation storage (treatment & prevention)
    recommendation = models.JSONField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.disease_name} ({self.confidence}%)"


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