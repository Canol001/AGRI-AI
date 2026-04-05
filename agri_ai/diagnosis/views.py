# diagnosis/views.py
import io
import logging
import threading
from typing import Tuple, Dict, Any
from datetime import timedelta

from django.db.models import Avg, Count
from django.utils import timezone
from django.contrib.auth import authenticate
from django.contrib.auth.models import User

from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.authtoken.models import Token
from rest_framework_simplejwt.tokens import RefreshToken

from PIL import Image
import torch
import torch.nn as nn
from torchvision import models, transforms
from deep_translator import GoogleTranslator

from .models import Diagnosis, Scan, UserProfile
from .serializers import UserSerializer
from .recommendations import RECOMMENDATIONS

import base64
from django.core.files.base import ContentFile

from diagnosis.utils.plant_detector import detect_plant

logger = logging.getLogger(__name__)

# ────────────────────────────────────────────────
#  MODEL LOADING (LAZY + THREAD-SAFE)
# ────────────────────────────────────────────────

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

_model = None
_model2 = None
_class_names = None
_model_lock = threading.Lock()
_model_initialized = False

def load_single_model(path):

    checkpoint = torch.load(
        path,
        map_location=DEVICE,
        weights_only=True
    )

    class_names = checkpoint["class_names"]

    model = models.resnet18(weights=None)
    num_features = model.fc.in_features
    model.fc = nn.Linear(num_features, len(class_names))

    model.load_state_dict(checkpoint["model_state_dict"])
    model.to(DEVICE)
    model.eval()

    return model, class_names


def get_models_and_classes():
    global _model1, _model2, _class_names, _model_initialized

    if _model_initialized:
        return _model1, _model2, _class_names

    with _model_lock:

        if _model_initialized:
            return _model1, _model2, _class_names

        logger.info("Loading both models...")

        _model1, class_names1 = load_single_model("diagnosis/ml/model.pth")
        _model2, class_names2 = load_single_model("diagnosis/ml/model2.pth")

        _class_names = class_names1

        _model_initialized = True

        logger.info("Both models loaded successfully")

    return _model1, _model2, _class_names


# ────────────────────────────────────────────────
#  LANGUAGE HELPERS
# ────────────────────────────────────────────────

# Pre-fetch supported languages to avoid crashes
try:
    SUPPORTED_LANGS = GoogleTranslator().get_supported_languages(as_dict=True)
except Exception:
    SUPPORTED_LANGS = {'english': 'en', 'swahili': 'sw'}

def get_user_language(request) -> str:
    """
    Returns the language code.
    Priority: query param → saved profile → default 'en'
    """
    lang_from_query = request.query_params.get('lang')
    if lang_from_query:
        lang = lang_from_query.lower()
        if lang in ['en', 'sw', 'luo', 'dholuo']:
            return 'luo' if lang in ['luo', 'dholuo'] else lang

    try:
        if request.user.is_authenticated:
            profile = request.user.profile
            saved_lang = profile.preferred_language
            if saved_lang in ['en', 'sw', 'luo']:
                return saved_lang
    except (AttributeError, UserProfile.DoesNotExist):
        pass

    return 'en'

def safe_translate(text: str, target_lang: str) -> str:
    """Helper to translate safely, falling back to English on error."""
    if not text or target_lang == 'en':
        return text
    
    # Map 'luo' to 'ach' (Acholi) or similar if 'luo' isn't in the dict, 
    # but based on your logs, 'luo' is explicitly failing.
    # We check the SUPPORTED_LANGS dict values.
    if target_lang not in SUPPORTED_LANGS.values():
        return text

    try:
        return GoogleTranslator(source='en', target=target_lang).translate(text)
    except Exception as e:
        logger.error(f"Translation failed for {target_lang}: {e}")
        return text

def get_recommendation(disease_key: str, lang: str = 'en') -> Dict[str, str]:
    rec_en = RECOMMENDATIONS.get(disease_key.lower().strip(), {
        "pathogen": "Unknown",
        "treatment": "No recommendation available.",
        "prevention": "No recommendation available."
    })

    if lang == 'en':
        return rec_en

    return {
        "pathogen": safe_translate(rec_en["pathogen"], lang),
        "treatment": safe_translate(rec_en["treatment"], lang),
        "prevention": safe_translate(rec_en["prevention"], lang),
    }

def translate_disease_name(name: str, lang: str = 'en') -> str:
    readable = name.replace("__", " ").replace("_", " ").title()
    if lang == 'en':
        return readable
    return safe_translate(readable, lang)


# ────────────────────────────────────────────────
#  PREDICTION LOGIC
# ────────────────────────────────────────────────

def predict(image_file) -> Tuple[str, float]:

    model1, model2, class_names = get_models_and_classes()

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

        outputs1 = model1(input_tensor)
        outputs2 = model2(input_tensor)

        # Ensemble: average predictions
        outputs = (outputs1 + outputs2) / 2

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
            user = User.objects.create_user(username=username, email=email, password=password)
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

        # Check if image exists
        if not image_file:
            return Response({"error": "No image uploaded"}, status=400)

        # Validate file type
        if not image_file.content_type.startswith("image/"):
            return Response(
                {"error": "Only image files are allowed"},
                status=400
            )

        # Limit file size (5MB)
        if image_file.size > 5 * 1024 * 1024:
            return Response(
                {"error": "Image too large. Maximum allowed size is 5MB"},
                status=400
            )

        lang = get_user_language(request)

        try:
            # -------------------------------
            # NEW: Ensure image contains plant
            # -------------------------------
            if not detect_plant(image_file):
                return Response(
                    {"error": "Only plant images are allowed. Please upload a crop or leaf image."},
                    status=400
                )

            # Reset pointer after reading image
            image_file.seek(0)

            # Run disease prediction
            disease, confidence = predict(image_file)

            normalized_disease = disease.lower().replace("__", "_").strip()

            recommendation = get_recommendation(normalized_disease, lang)
            disease_display = translate_disease_name(normalized_disease, lang)

            # Save scan record
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
                "language_used": lang
            }, status=201)

        except ValueError as ve:
            return Response({"error": str(ve)}, status=400)

        except Exception as e:
            logger.exception("Prediction / save failed")
            return Response(
                {"error": "Internal server error"},
                status=500
            )


class RecentScansView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        lang = get_user_language(request)
        scans = Scan.objects.filter(user=request.user).order_by("-created_at")[:10]

        data = []
        for scan in scans:
            recommendation = get_recommendation(scan.disease_name, lang)
            disease_display = translate_disease_name(scan.disease_name, lang)

            data.append({
                "id": scan.id,
                "image": scan.image.url if scan.image else None,
                "disease": disease_display,
                "original_disease_key": scan.disease_name,
                "confidence": scan.confidence,
                "date": scan.created_at.isoformat(),
                "recommendation": recommendation
            })
        return Response(data)


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
        
        return Response({"error": "Invalid language. Use 'en', 'sw', or 'luo'."}, status=400)


class ScanDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            scan = Scan.objects.get(id=pk, user=request.user)
            scan.delete()
            return Response(status=204)
        except Scan.DoesNotExist:
            return Response({"error": "Scan not found"}, status=404)


class AdminDashboardView(APIView):
    permission_classes = [IsAdminUser]

    def get(self, request):
        total_users = User.objects.count()
        total_scans = Scan.objects.count()
        recent_scans = Scan.objects.filter(created_at__gte=timezone.now() - timedelta(days=30)).count()
        
        avg_confidence = Scan.objects.aggregate(avg=Avg('confidence'))['avg']
        top_diseases = Scan.objects.values('disease_name').annotate(count=Count('id')).order_by('-count')[:8]

        data = {
            "system_overview": {
                "total_users": total_users,
                "total_scans": total_scans,
                "recent_scans_30d": recent_scans,
                "average_confidence": round(avg_confidence, 2) if avg_confidence else 0,
            },
            "top_diseases_last_30_days": [
                {"disease": item['disease_name'], "count": item['count']}
                for item in top_diseases
            ],
            "admin": {"username": request.user.username}
        }
        return Response(data)


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


class PredictDisease(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):

        image_file = request.FILES.get("image")

        # If image not sent as file, check base64
        if not image_file:
            base64_image = request.data.get("image")

            if base64_image:
                format, imgstr = base64_image.split(';base64,')
                ext = format.split('/')[-1]

                image_file = ContentFile(
                    base64.b64decode(imgstr),
                    name='upload.' + ext
                )

        if not image_file:
            return Response({"error": "No image provided"}, status=400)

        # ----- PLANT DETECTION CHECK -----
        if not detect_plant(image_file):
            return Response(
                {"error": "Uploaded image does not seem to be a plant."},
                status=400
            )

        lang = get_user_language(request)

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
                "language_used": lang
            }, status=201)

        except Exception as e:
            logger.exception("Prediction failed")
            return Response({"error": str(e)}, status=500)