from transformers import pipeline
from PIL import Image

# Load classifier once when server starts
classifier = pipeline("image-classification", model="google/vit-base-patch16-224")

PLANT_KEYWORDS = [
    "plant",
    "leaf",
    "tree",
    "flower",
    "corn",
    "maize",
    "tomato",
    "potato",
    "vegetable",
    "fruit"
]


def detect_plant(image_file):
    image = Image.open(image_file).convert("RGB")

    results = classifier(image)

    # results example:
    # [{'label': 'leaf beetle', 'score': 0.82}, ...]

    for result in results:
        label = result["label"].lower()

        for keyword in PLANT_KEYWORDS:
            if keyword in label:
                return True

    return False