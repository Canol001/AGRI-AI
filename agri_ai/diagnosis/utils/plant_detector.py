import requests
from PIL import Image
import io

PLANTNET_API_KEY = "2b10XYYFfAhPQ6CMl7XWUB1xu"
PLANTNET_URL = "https://my-api.plantnet.org/v2/identify/all"


def detect_plant(image_file):
    try:
        image_file.seek(0)

        # Convert any image format to JPEG
        image = Image.open(image_file).convert("RGB")

        buffer = io.BytesIO()
        image.save(buffer, format="JPEG")
        buffer.seek(0)

        files = {
            "images": ("image.jpg", buffer, "image/jpeg")
        }

        params = {
            "api-key": PLANTNET_API_KEY
        }

        data = {
            "organs": "leaf"
        }

        response = requests.post(
            PLANTNET_URL,
            files=files,
            data=data,
            params=params,
            timeout=15
        )

        if response.status_code != 200:
            print("PlantNet API error:", response.text)
            return False

        result = response.json()

        results = result.get("results", [])

        if not results:
            return False

        top_score = results[0].get("score", 0)

        image_file.seek(0)

        return top_score > 0.15

    except Exception as e:
        print("PlantNet exception:", e)
        return False