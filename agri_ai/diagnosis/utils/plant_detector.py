import logging
import io
from PIL import Image
import requests

# ==================== LOGGER SETUP ====================
logger = logging.getLogger(__name__)

# ==================== CONFIG ====================
PLANTNET_API_KEY = "2b10XYYFfAhPQ6CMl7XWUB1xu"
PLANTNET_URL = "https://my-api.plantnet.org/v2/identify/all"


def detect_plant(image_file) -> bool:
    """
    Checks if the uploaded image is likely a plant/leaf using PlantNet API.
    Returns True if it passes the plant detection, False otherwise.
    
    This version is safer for both web and Flutter mobile uploads.
    """
    try:
        # Always reset file pointer at the beginning
        image_file.seek(0)

        # Open and convert image safely
        image = Image.open(image_file).convert("RGB")

        # Save as JPEG with consistent quality (helps PlantNet)
        buffer = io.BytesIO()
        image.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)

        files = {
            "images": ("image.jpg", buffer, "image/jpeg")
        }

        params = {"api-key": PLANTNET_API_KEY}
        data = {"organs": "leaf"}

        logger.info("Sending request to PlantNet API...")

        response = requests.post(
            PLANTNET_URL,
            files=files,
            data=data,
            params=params,
            timeout=12
        )

        logger.info(f"PlantNet response status: {response.status_code}")

        if response.status_code != 200:
            logger.warning(f"PlantNet API error: {response.text[:500]}")
            # If PlantNet clearly says it's not a plant (404), reject
            if response.status_code == 404:
                return False
            # For other errors (timeout, rate limit, etc.), be a bit lenient or reject
            return False

        # Parse response
        result = response.json()
        results = result.get("results", [])

        if not results:
            logger.info("PlantNet returned no results")
            return False

        top_score = results[0].get("score", 0.0)
        logger.info(f"PlantNet top score: {top_score:.4f}")

        # CRITICAL: Reset the file pointer so Django can read the image again for prediction
        image_file.seek(0)

        # Lowered threshold - more friendly for real crop photos from mobile
        # You can adjust this value (0.05 ~ 0.10 works well in practice)
        return top_score > 0.07

    except Exception as e:
        logger.error(f"detect_plant exception: {e}", exc_info=True)
        # Always try to reset pointer even on error
        try:
            image_file.seek(0)
        except Exception:
            pass
        return False