# diagnosis/views.py
import io
import logging
import threading
from typing import Tuple, Dict, Any
from django.db.models import Avg, Count
from rest_framework import generics
from rest_framework_simplejwt.tokens import RefreshToken

from PIL import Image

import torch
import torch.nn as nn
from torchvision import models, transforms
from django.utils import timezone
from datetime import timedelta
from .serializers import UserSerializer

from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAdminUser

from .models import Diagnosis, Scan
from .recommendations import RECOMMENDATIONS

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────
#  MODEL LOADING (LAZY + THREAD-SAFE)
# ────────────────────────────────────────────────

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_model = None
_class_names = None
_model_lock = threading.Lock()
_model_initialized = False


def get_model_and_classes() -> Tuple[nn.Module, list]:
    """
    Lazy-load the model and class names (only once, thread-safe).
    Returns (model, class_names)
    """
    global _model, _class_names, _model_initialized

    if _model_initialized:
        return _model, _class_names

    with _model_lock:
        if _model_initialized:  # double-checked locking
            return _model, _class_names

        logger.info("Loading plant disease classification model...")

        try:
            checkpoint = torch.load(
                "diagnosis/ml/model.pth",
                map_location=DEVICE,
                weights_only=True  # safer in newer torch versions
            )

            _class_names = checkpoint["class_names"]

            model = models.resnet18(weights=None)
            num_features = model.fc.in_features
            model.fc = nn.Linear(num_features, len(_class_names))

            model.load_state_dict(checkpoint["model_state_dict"])
            model.to(DEVICE)
            model.eval()

            _model = model
            _model_initialized = True

            logger.info(f"Model loaded successfully on {DEVICE}. Classes: {len(_class_names)}")

        except Exception as e:
            logger.exception("Failed to load model")
            raise RuntimeError(f"Model loading failed: {str(e)}") from e

        return _model, _class_names


# ────────────────────────────────────────────────
#  PREDICTION FUNCTION
# ────────────────────────────────────────────────

def predict(image_file) -> Tuple[str, float]:
    model, class_names = get_model_and_classes()

    try:
        image = Image.open(image_file).convert("RGB")
    except Exception as e:
        raise ValueError("Invalid image file") from e

    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225]
        )
    ])

    input_tensor = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        outputs = model(input_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        confidence, predicted_idx = torch.max(probabilities, 1)

    predicted_class = class_names[predicted_idx.item()]
    confidence_pct = round(confidence.item() * 100, 2)

    return predicted_class, confidence_pct


# ────────────────────────────────────────────────
#  API VIEWS
# ────────────────────────────────────────────────

class RegisterView(APIView):
    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        if not all([username, email, password]):
            return Response({"error": "Missing required fields"}, status=400)

        if User.objects.filter(username=username).exists():
            return Response({"error": "Username already exists"}, status=400)

        try:
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password
            )

            refresh = RefreshToken.for_user(user)

            return Response({
                "success": True,
                "message": "User created successfully",
                "refresh": str(refresh),
                "access": str(refresh.access_token),
                "username": user.username
            }, status=201)

        except Exception as e:
            logger.exception("Registration failed")
            return Response({"error": str(e)}, status=500)


class LoginView(APIView):
    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")

        user = authenticate(username=username, password=password)

        if user is None:
            return Response({"error": "Invalid credentials"}, status=401)

        token, _ = Token.objects.get_or_create(user=user)

        return Response({
            "token": token.key,
            "username": user.username
        })


class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        total_scans = Scan.objects.filter(user=request.user).count()
        return Response({
            "user": request.user.username,
            "total_scans": total_scans
        })


class ScanCropView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image_file = request.FILES.get("image")
        if not image_file:
            return Response({"error": "No image uploaded"}, status=400)

        try:
            disease, confidence = predict(image_file)

            # Normalize disease key
            normalized_disease = disease.lower().replace("__", "_").strip()

            recommendation = RECOMMENDATIONS.get(normalized_disease, {
                "pathogen": "Unknown",
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })

            scan = Scan.objects.create(
                user=request.user,
                image=image_file,
                disease_name=normalized_disease,
                confidence=confidence
            )

            return Response({
                "disease": normalized_disease,
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": recommendation
            }, status=201)

        except ValueError as ve:
            return Response({"error": str(ve)}, status=400)
        except Exception as e:
            logger.exception("Prediction / save failed")
            return Response({"error": "Internal server error"}, status=500)


class RecentScansView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        scans = Scan.objects.filter(user=request.user)\
                           .order_by("-created_at")[:10]

        data = []
        for scan in scans:
            rec = RECOMMENDATIONS.get(scan.disease_name, {
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })
            data.append({
                "id": scan.id,
                "image": scan.image.url,
                "disease": scan.disease_name,
                "confidence": scan.confidence,
                "date": scan.created_at.isoformat(),
                "recommendation": rec
            })

        return Response(data)
    

class AdminDashboardView(APIView):
    """
    Admin-only endpoint showing system-wide statistics.
    Accessible only to staff/superusers.
    """
    permission_classes = [IsAdminUser]  # only is_staff=True users

    def get(self, request):
        total_users = User.objects.count()
        total_scans = Scan.objects.count()
        recent_scans = Scan.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=30)
        ).count()
        avg_confidence = Scan.objects.aggregate(avg=Avg('confidence'))['avg']
        top_diseases = Scan.objects.values('disease_name').annotate(
            count=Count('id')
        ).order_by('-count')[:8]

        active_users_last_30 = Scan.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=30)
        ).values('user').distinct().count()

        data = {
            "system_overview": {
                "total_users": total_users,
                "total_scans": total_scans,
                "recent_scans_30d": recent_scans,
                "active_users_30d": active_users_last_30,
                "average_confidence": round(avg_confidence, 2) if avg_confidence else 0,
            },
            "top_diseases_last_30_days": [
                {"disease": item['disease_name'], "count": item['count']}
                for item in top_diseases
            ],
            "admin": {
                "username": request.user.username,
                "is_superuser": request.user.is_superuser,
                "last_login": request.user.last_login.isoformat() if request.user.last_login else None,
            }
        }

        return Response(data, status=status.HTTP_200_OK)
    

class AdminUserListCreateView(generics.ListCreateAPIView):
    """
    GET /api/admin/users/    → List all users (admin only)
    POST /api/admin/users/   → Create new user (admin only)
    """
    permission_classes = [IsAdminUser]
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        # Auto-set password if provided
        password = serializer.validated_data.pop('password', None)
        user = serializer.save()
        if password:
            user.set_password(password)
            user.save()


class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    GET /api/admin/users/<id>/    → Get single user
    PATCH /api/admin/users/<id>/  → Update user (email, is_staff, etc.)
    DELETE /api/admin/users/<id>/ → Delete user
    """
    permission_classes = [IsAdminUser]
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def perform_update(self, serializer):
        password = serializer.validated_data.pop('password', None)
        user = serializer.save()
        if password:
            user.set_password(password)
            user.save()


class ScanDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            scan = Scan.objects.get(id=pk, user=request.user)
            scan.delete()
            return Response(status=204)
        except Scan.DoesNotExist:
            return Response({"error": "Scan not found or not owned by you"}, status=404)
        except Exception as e:
            logger.exception("Scan delete failed")
            return Response({"error": str(e)}, status=500)


# Optional / legacy endpoint (consider deprecating)
class PredictDisease(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image_file = request.FILES.get("image")
        if not image_file:
            return Response({"error": "No image provided"}, status=400)

        try:
            disease, confidence = predict(image_file)

            rec = RECOMMENDATIONS.get(disease, {
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })

            # Legacy Diagnosis + Scan
            Diagnosis.objects.create(
                image=image_file,
                disease_name=disease,
                confidence=confidence
            )
            scan = Scan.objects.create(
                user=request.user,
                image=image_file,
                disease_name=disease,
                confidence=confidence
            )

            return Response({
                "disease": disease,
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": rec
            }, status=201)

        except Exception as e:
            logger.exception("Legacy predict failed")
            return Response({"error": str(e)}, status=500)