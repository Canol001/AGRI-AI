# views.py
import torch
import io
from PIL import Image

from django.contrib.auth.models import User
from django.contrib.auth import authenticate

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import IsAuthenticated

from torchvision import models
import torchvision.transforms as transforms
import torch.nn as nn

from .models import Diagnosis, Scan
from .serializers import DiagnosisSerializer
from .recommendations import RECOMMENDATIONS


# ------------------------------
# MODEL LOADING
# ------------------------------

MODEL = None
CLASS_NAMES = None
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def load_model():
    global MODEL, CLASS_NAMES

    if MODEL is None:
        checkpoint = torch.load("diagnosis/ml/model.pth", map_location=DEVICE)

        CLASS_NAMES = checkpoint["class_names"]

        model = models.resnet18(weights=None)
        model.fc = nn.Linear(model.fc.in_features, len(CLASS_NAMES))

        model.load_state_dict(checkpoint["model_state_dict"])
        model.to(DEVICE)
        model.eval()

        MODEL = model

    return MODEL


# ------------------------------
# IMAGE PREDICTION
# ------------------------------

def predict(image_file):
    model = load_model()
    image = Image.open(image_file).convert("RGB")

    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(
            [0.485, 0.456, 0.406],
            [0.229, 0.224, 0.225]
        )
    ])

    input_tensor = transform(image).unsqueeze(0).to(DEVICE)

    with torch.no_grad():
        outputs = model(input_tensor)
        probabilities = torch.softmax(outputs, dim=1)
        confidence, predicted_idx = torch.max(probabilities, 1)

    predicted = CLASS_NAMES[predicted_idx.item()]
    confidence = round(confidence.item() * 100, 2)

    return predicted, confidence


# ------------------------------
# USER REGISTRATION
# ------------------------------

class RegisterView(APIView):

    def post(self, request):
        username = request.data.get("username")
        email = request.data.get("email")
        password = request.data.get("password")

        if User.objects.filter(username=username).exists():
            return Response({"error": "Username already exists"}, status=400)

        user = User.objects.create_user(
            username=username,
            email=email,
            password=password
        )

        token = Token.objects.create(user=user)

        return Response({
            "message": "User created successfully",
            "token": token.key
        })


# ------------------------------
# LOGIN
# ------------------------------

class LoginView(APIView):

    def post(self, request):
        username = request.data.get("username")
        password = request.data.get("password")

        user = authenticate(username=username, password=password)

        if user is None:
            return Response({"error": "Invalid credentials"}, status=401)

        token, created = Token.objects.get_or_create(user=user)

        return Response({
            "token": token.key,
            "username": user.username
        })


# ------------------------------
# DASHBOARD
# ------------------------------

class DashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        total_scans = Scan.objects.filter(user=request.user).count()
        return Response({
            "user": request.user.username,
            "total_scans": total_scans
        })


# ------------------------------
# SCAN CROPS (AI PREDICTION)
# ------------------------------

class ScanCropView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image = request.FILES.get("image")
        if not image:
            return Response({"error": "No image uploaded"}, status=400)

        try:
            disease, confidence = predict(image)

            # Normalize disease key (handle casing and double underscores)
            normalized_disease = disease.lower().replace("__", "_").strip()

            # Get recommendations using normalized key
            recommendation = RECOMMENDATIONS.get(normalized_disease, {
                "pathogen": "Anything",
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })

            # Save scan
            scan = Scan.objects.create(
                user=request.user,
                image=image,
                disease_name=normalized_disease,
                confidence=confidence
            )

            return Response({
                "disease": normalized_disease,
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": recommendation
            })

        except Exception as e:
            return Response({"error": str(e)}, status=500)


# ------------------------------
# RECENT SCANS
# ------------------------------

class RecentScansView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        scans = Scan.objects.filter(user=request.user).order_by("-created_at")[:10]
        data = []
        for scan in scans:
            recommendation = RECOMMENDATIONS.get(scan.disease_name, {
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })
            data.append({
                "id": scan.id,
                "image": scan.image.url,
                "disease": scan.disease_name,
                "confidence": scan.confidence,
                "date": scan.created_at,
                "recommendation": recommendation
            })
        return Response(data)


# ------------------------------
# DELETE SCAN
# ------------------------------

class ScanDeleteView(APIView):
    permission_classes = [IsAuthenticated]

    def delete(self, request, pk):
        try:
            scan = Scan.objects.get(id=pk, user=request.user)
            scan.delete()
            return Response({"message": "Scan deleted successfully"}, status=204)
        except Scan.DoesNotExist:
            return Response({"error": "Scan not found or not owned by you"}, status=404)
        except Exception as e:
            return Response({"error": str(e)}, status=500)


# ------------------------------
# LEGACY PREDICT (OPTIONAL)
# ------------------------------

class PredictDisease(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image = request.FILES.get('image')
        if not image:
            return Response({"error": "No image provided"}, status=400)

        try:
            disease, confidence = predict(image)

            # Get recommendations
            recommendation = RECOMMENDATIONS.get(disease, {
                "treatment": "No recommendation available.",
                "prevention": "No recommendation available."
            })

            # Save Diagnosis & Scan
            diagnosis = Diagnosis.objects.create(
                image=image,
                disease_name=disease,
                confidence=confidence
            )
            scan = Scan.objects.create(
                user=request.user,
                image=image,
                disease_name=disease,
                confidence=confidence
            )

            return Response({
                "disease": disease,
                "confidence": confidence,
                "scan_id": scan.id,
                "recommendation": recommendation
            })

        except Exception as e:
            return Response({"error": str(e)}, status=500)