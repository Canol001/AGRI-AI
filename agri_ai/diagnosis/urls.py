from django.urls import path
#from .views import PredictDisease
from .views import *
from rest_framework_simplejwt.views import TokenObtainPairView

urlpatterns = [

    path('register/', RegisterView.as_view()),
    path('login/', TokenObtainPairView.as_view()),
    path('predict/', PredictDisease.as_view(), name='predict'),
    path('dashboard/', DashboardView.as_view()),
    path('scan/', ScanCropView.as_view()),
    path('recent-scans/', RecentScansView.as_view()),
    path('scans/<int:pk>/', ScanDeleteView.as_view(), name='scan-delete'),
]