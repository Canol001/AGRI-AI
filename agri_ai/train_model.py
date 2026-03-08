# agri_ai/train_model.py

import os
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms, models
from torch.utils.data import DataLoader
from sklearn.model_selection import train_test_split

# =========================
# CONFIG
# =========================
DATA_DIR = "dataset/train"
BATCH_SIZE = 16
EPOCHS = 12
LEARNING_RATE = 0.001
MODEL_SAVE_PATH = "diagnosis/ml/model.pth"

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using device:", device)

# =========================
# TRANSFORMS
# =========================
train_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(10),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225]
    )
])

# =========================
# DATASET
# =========================
dataset = datasets.ImageFolder(DATA_DIR, transform=train_transform)

print("Classes detected:", dataset.classes)
print("Number of classes:", len(dataset.classes))

loader = DataLoader(dataset, batch_size=BATCH_SIZE, shuffle=True)

# =========================
# MODEL (Transfer Learning)
# =========================
model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)

# Freeze all layers
for param in model.parameters():
    param.requires_grad = False

# Replace final layer
model.fc = nn.Linear(model.fc.in_features, len(dataset.classes))
model = model.to(device)

# =========================
# LOSS & OPTIMIZER
# =========================
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.fc.parameters(), lr=LEARNING_RATE)

# =========================
# TRAINING LOOP
# =========================
for epoch in range(EPOCHS):
    model.train()
    running_loss = 0.0
    correct = 0
    total = 0

    for images, labels in loader:
        images, labels = images.to(device), labels.to(device)

        outputs = model(images)
        loss = criterion(outputs, labels)

        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        running_loss += loss.item()

        _, predicted = torch.max(outputs, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()

    epoch_loss = running_loss / len(loader)
    epoch_acc = 100 * correct / total

    print(f"Epoch [{epoch+1}/{EPOCHS}] "
          f"Loss: {epoch_loss:.4f} "
          f"Accuracy: {epoch_acc:.2f}%")

# =========================
# SAVE MODEL
# =========================
os.makedirs("diagnosis/ml", exist_ok=True)

torch.save({
    "model_state_dict": model.state_dict(),
    "class_names": dataset.classes
}, MODEL_SAVE_PATH)

print("Model trained and saved successfully.")