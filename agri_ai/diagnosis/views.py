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
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.response import Response
from rest_framework.views import APIView

from deep_translator import GoogleTranslator  # ← added for Dholuo translation

from .models import Diagnosis, Scan
from .recommendations import RECOMMENDATIONS

from .models import Diagnosis, Scan, UserProfile   # ← add UserProfile here

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
    global _model, _class_names, _model_initialized

    if _model_initialized:
        return _model, _class_names

    with _model_lock:
        if _model_initialized:
            return _model, _class_names

        logger.info("Loading plant disease classification model...")

        try:
            checkpoint = torch.load(
                "diagnosis/ml/model.pth",
                map_location=DEVICE,
                weights_only=True
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
#  HELPER: Get translated recommendation
# ────────────────────────────────────────────────

def get_recommendation(disease_key: str, lang: str = 'en') -> Dict[str, str]:
    rec_en = RECOMMENDATIONS.get(disease_key.lower().strip(), {
        "pathogen": "Unknown",
        "treatment": "No recommendation available.",
        "prevention": "No recommendation available."
    })

    if lang.lower() in ['luo', 'dholuo']:
        try:
            translator = GoogleTranslator(source='en', target='luo')
            return {
                "pathogen": translator.translate(rec_en["pathogen"]),
                "treatment": translator.translate(rec_en["treatment"]),
                "prevention": translator.translate(rec_en["prevention"]),
            }
        except Exception as e:
            logger.warning(f"Translation to Luo failed: {e}")
            return rec_en  # fallback to English
    return rec_en


def translate_disease_name(name: str, lang: str = 'en') -> str:
    if lang.lower() in ['luo', 'dholuo']:
        try:
            translator = GoogleTranslator(source='en', target='luo')
            # Replace underscores with spaces for nicer translation
            readable = name.replace("__", " ").replace("_", " ")
            return translator.translate(readable)
        except Exception:
            return name.replace("_", " ")
    return name.replace("_", " ")


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

        lang = request.query_params.get('lang', 'en').lower()

        try:
            disease, confidence = predict(image_file)
            normalized_disease = disease.lower().replace("__", "_").strip()

            recommendation = get_recommendation(normalized_disease, lang)
            disease_display = translate_disease_name(normalized_disease, lang)

            scan = Scan.objects.create(
                user=request.user,
                image=image_file,
                disease_name=normalized_disease,
                confidence=confidence
            )

            return Response({
                "disease": disease_display,
                "original_disease_key": normalized_disease,  # useful for debugging / consistency
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": recommendation,
                "language": "dholuo" if lang in ['luo', 'dholuo'] else "english"
            }, status=201)

        except ValueError as ve:
            return Response({"error": str(ve)}, status=400)
        except Exception as e:
            logger.exception("Prediction / save failed")
            return Response({"error": "Internal server error"}, status=500)


class RecentScansView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        lang = request.query_params.get('lang', 'en').lower()

        scans = Scan.objects.filter(user=request.user)\
                           .order_by("-created_at")[:10]

        data = []
        for scan in scans:
            recommendation = get_recommendation(scan.disease_name, lang)
            disease_display = translate_disease_name(scan.disease_name, lang)

            data.append({
                "id": scan.id,
                "image": scan.image.url,
                "disease": disease_display,
                "original_disease_key": scan.disease_name,
                "confidence": scan.confidence,
                "date": scan.created_at.isoformat(),
                "recommendation": recommendation
            })

        return Response(data)


# ────────────────────────────────────────────────
#  Admin & other views (unchanged)
# ────────────────────────────────────────────────

class AdminDashboardView(APIView):
    permission_classes = [IsAdminUser]

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
    permission_classes = [IsAdminUser]
    queryset = User.objects.all().order_by('-date_joined')
    serializer_class = UserSerializer

    def perform_create(self, serializer):
        password = serializer.validated_data.pop('password', None)
        user = serializer.save()
        if password:
            user.set_password(password)
            user.save()


class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
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
        
        
        
class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)

        return Response({
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "preferred_language": profile.preferred_language,
            "language_display": profile.language_display,
        })

    def patch(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)

        lang = request.data.get("preferred_language")
        if lang in ['en', 'sw', 'luo']:
            profile.preferred_language = lang
            profile.save()
            return Response({
                "message": "Language updated",
                "preferred_language": profile.preferred_language,
                "language_display": profile.language_display,
            }, status=200)
        else:
            return Response(
                {"error": "Invalid language. Use 'en', 'sw', or 'luo'."},
                status=400
            )


# Legacy endpoint (kept for backward compatibility)
class PredictDisease(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image_file = request.FILES.get("image")
        if not image_file:
            return Response({"error": "No image provided"}, status=400)

        lang = request.query_params.get('lang', 'en').lower()

        try:
            disease, confidence = predict(image_file)
            normalized_disease = disease.lower().replace("__", "_").strip()

            recommendation = get_recommendation(normalized_disease, lang)
            disease_display = translate_disease_name(normalized_disease, lang)

            Diagnosis.objects.create(
                image=image_file,
                disease_name=normalized_disease,
                confidence=confidence
            )
            scan = Scan.objects.create(
                user=request.user,
                image=image_file,
                disease_name=normalized_disease,
                confidence=confidence
            )

            return Response({
                "disease": disease_display,
                "original_disease_key": normalized_disease,
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": recommendation,
                "language": "dholuo" if lang in ['luo', 'dholuo'] else "english"
            }, status=201)

        except Exception as e:
            logger.exception("Legacy predict failed")
            return Response({"error": str(e)}, status=500)