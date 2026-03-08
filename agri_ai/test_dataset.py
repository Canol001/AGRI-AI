# test_dataset.py

from torchvision import datasets, transforms

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor()
])

dataset = datasets.ImageFolder("dataset/train", transform=transform)

print("Classes:", dataset.classes)
print("Number of images:", len(dataset))