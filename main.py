# main.py (or app.py) for your FastAPI service

import os
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
import uvicorn
import tensorflow as tf
from tensorflow import keras
from PIL import Image # Pillow for image processing
import numpy as np
import io
import json # Import the json module
import httpx # For making async HTTP requests to Gemini API

# --- Configuration ---
# Path to your existing .keras model file
# Ensure this file is in the same directory as this FastAPI script,
# or provide an absolute path.
KERAS_H5_MODEL_PATH = "Plant_Disease_Detection.keras"

# Define your model's expected input dimensions
IMG_WIDTH = 160
IMG_HEIGHT = 160
IMAGE_CHANNELS = 3 # RGB

# IMPORTANT: Populate this array with the exact class names
# in the order determined by your Keras model's training.
# Removed '___' and replaced '_' with spaces for better readability.
CLASS_LABELS = [
    'Apple Apple Scab',
    'Apple Black Rot',
    'Apple Cedar Apple Rust',
    'Apple healthy',
    'Background without leaves',
    'Blueberry healthy',
    'Cherry Powdery Mildew',
    'Cherry healthy',
    'Corn Cercospora leaf spot Gray leaf spot',
    'Corn Common Rust',
    'Corn Northern Leaf Blight',
    'Corn healthy',
    'Grape Black Rot',
    'Grape Esca (Black Measles)',
    'Grape Leaf blight (Isariopsis Leaf Spot)',
    'Grape healthy',
    'Orange Haunglongbing (Citrus greening)',
    'Peach Bacterial Spot',
    'Peach healthy',
    'Pepper, bell Bacterial Spot',
    'Pepper, bell healthy',
    'Potato Early Blight',
    'Potato Late Blight',
    'Potato healthy',
    'Raspberry healthy',
    'Soybean healthy',
    'Squash Powdery Mildew',
    'Strawberry Leaf Scorch',
    'Strawberry healthy',
    'Tomato Bacterial Spot',
    'Tomato Early Blight',
    'Tomato Late Blight',
    'Tomato Leaf Mold',
    'Tomato Septoria leaf spot',
    'Tomato Spider mites Two-spotted spider mite',
    'Tomato Target Spot',
    'Tomato Tomato Yellow Leaf Curl Virus',
    'Tomato Tomato mosaic virus',
    'Tomato healthy'
]

# --- Define the custom activation function used by MobileNetV3Large ---
# This is CRUCIAL for loading MobileNetV3 models correctly from .keras.
@tf.keras.utils.register_keras_serializable()
def hard_swish(x):
    return x * tf.nn.relu6(x + 3) / 6

# --- Define custom objects dictionary for model loading ---
CUSTOM_OBJECTS = {
    "hard_swish": hard_swish,
    "HardSwish": hard_swish # Include both for robustness
}

# --- Gemini API Configuration ---
# IMPORTANT: When running locally, you MUST provide your own API key.
# 1. Go to Google AI Studio: https://aistudio.google.com/app/apikey
# 2. Click "Get API key" or "Create API key in new project".
# 3. Copy your generated API key and paste it below, replacing the empty string.
# Example: GEMINI_API_KEY = "YOUR_ACTUAL_GEMINI_API_KEY_HERE"
GEMINI_API_KEY = "AIzaSyBNwIQ3hC4dmyN80bAK91EURbtUvFHJt5A" # <--- REPLACE THIS EMPTY STRING WITH YOUR ACTUAL GEMINI API KEY

# The GEMINI_API_URL is constructed once based on the GEMINI_API_KEY set above.
# If GEMINI_API_KEY is empty or invalid, API calls will likely fail,
# but the check is no longer duplicated within the prediction logic.
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}"

# --- Initialize FastAPI App ---
app = FastAPI(
    title="KrishiCare ML Prediction Service",
    description="API for plant disease prediction using a pre-trained Keras model.",
    version="1.0.0",
)

# --- Global variable to hold the loaded model ---
model: keras.Model = None

# --- Startup Event: Load the model when the FastAPI application starts ---
@app.on_event("startup")
async def load_model_on_startup():
    """
    Loads the Keras model into memory when the FastAPI application starts.
    This prevents reloading the model for every prediction request.
    """
    global model
    print(f"Attempting to load Keras model from: {KERAS_H5_MODEL_PATH}")
    if not os.path.exists(KERAS_H5_MODEL_PATH):
        raise RuntimeError(f"Model file not found at: {KERAS_H5_MODEL_PATH}")

    try:
        # Load the Keras model from the .keras file, providing custom_objects
        model = tf.keras.models.load_model(KERAS_H5_MODEL_PATH, custom_objects=CUSTOM_OBJECTS)
        print("Keras model loaded successfully!")
        model.summary() # Print model summary to console for verification
    except Exception as e:
        print(f"Error loading Keras model: {e}")
        raise RuntimeError(f"Failed to load Keras model: {e}")

# --- Health Check Endpoint ---
@app.get("/health")
async def health_check():
    """
    Checks if the service is running and the model is loaded.
    """
    if model:
        return {"status": "ok", "model_loaded": True}
    return {"status": "ok", "model_loaded": False, "message": "Model not yet loaded or failed to load."}

# --- Prediction Endpoint ---
@app.post("/predict")
async def predict_plant_disease(file: UploadFile = File(...)):
    """
    Receives an image file, preprocesses it, and returns a plant disease prediction.
    """
    if not model:
        raise HTTPException(status_code=503, detail="ML model not loaded. Please try again later.")

    try:
        # Read image bytes from the uploaded file
        image_bytes = await file.read()

        # Load image using Pillow (PIL)
        # Ensure image is converted to RGB if it's grayscale or RGBA
        image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        image = image.resize((IMG_WIDTH, IMG_HEIGHT)) # Resize to model's expected input size

        # Convert PIL Image to NumPy array
        img_array = np.array(image, dtype=np.float32)

        # Add batch dimension: (H, W, C) -> (1, H, W, C)
        img_array = np.expand_dims(img_array, axis=0)

        # Apply MobileNetV3 preprocessing: scale from [0, 255] to [-1, 1]
        # This is the same function used as the first layer in your Keras model.
        preprocessed_img_array = tf.keras.applications.mobilenet_v3.preprocess_input(img_array)

        # Perform prediction
        predictions = model.predict(preprocessed_img_array)

        # Get the probabilities and find the predicted class
        probabilities = predictions[0] # Get probabilities for the single image in the batch
        predicted_class_index = np.argmax(probabilities)
        predicted_confidence = float(np.max(probabilities)) * 100 # Convert to float and percentage

        predicted_label = CLASS_LABELS[predicted_class_index]

        # --- Generate description based on prediction ---
        disease_description = "Description not available." # Default in case of API failure

        # Check if the predicted label indicates a healthy plant
        if "healthy" in predicted_label.lower():
            # Extract plant name (e.g., "Apple" from "Apple healthy")
            plant_type = predicted_label.split(' ')[0]
            try:
                # Prompt for a description of the healthy plant
                prompt = f"Provide a very short description of a {plant_type} plant, focusing on its common characteristics, in about 20-30 words."
                payload = {
                    "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "maxOutputTokens": 60 # Adjusted token limit for 20-30 words
                    }
                }
                headers = {'Content-Type': 'application/json'}

                # Make the API call. If GEMINI_API_KEY is invalid, it will raise an error handled below.
                async with httpx.AsyncClient() as client:
                    gemini_response = await client.post(GEMINI_API_URL, headers=headers, json=payload, timeout=15.0)
                    gemini_response.raise_for_status()
                    gemini_result = gemini_response.json()

                    if gemini_result and gemini_result.get("candidates") and gemini_result["candidates"][0].get("content"):
                        generated_text = gemini_result["candidates"][0]["content"]["parts"][0]["text"]
                        disease_description = f"Perfectly healthy plant. {generated_text.strip()}"
                    else:
                        print(f"Gemini API response missing content for healthy plant: {gemini_result}")
                        disease_description = "Perfectly healthy plant. No specific description available."
            except Exception as e:
                print(f"Error generating description for healthy plant: {e}")
                disease_description = "Perfectly healthy plant. Description generation failed."
        else:
            # Existing logic for diseased plants
            try:
                # Prompt for a description around 50 words, focusing on symptoms and impact
                prompt = f"Provide a brief description of the plant disease '{predicted_label}'. Describe its key symptoms and potential impact in about 50 words."
                payload = {
                    "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                    "generationConfig": {
                        "maxOutputTokens": 100 # Increased token limit to allow for ~50 words (approx 2 tokens per word)
                    }
                }
                headers = {'Content-Type': 'application/json'}

                # Make the API call. If GEMINI_API_KEY is invalid, it will raise an error handled below.
                async with httpx.AsyncClient() as client:
                    gemini_response = await client.post(GEMINI_API_URL, headers=headers, json=payload, timeout=15.0)
                    gemini_response.raise_for_status()
                    gemini_result = gemini_response.json()

                    if gemini_result and gemini_result.get("candidates") and gemini_result["candidates"][0].get("content"):
                        generated_text = gemini_result["candidates"][0]["content"]["parts"][0]["text"]
                        disease_description = generated_text.strip()
                    else:
                        print(f"Gemini API response missing content: {gemini_result}")
            except httpx.RequestError as e:
                print(f"Gemini API request failed: {e}")
            except httpx.HTTPStatusError as e:
                print(f"Gemini API HTTP error: {e.response.status_code} - {e.response.text}")
            except json.JSONDecodeError as e:
                print(f"Failed to decode Gemini API JSON response: {e}")
            except Exception as e:
                print(f"An unexpected error occurred during Gemini API call: {e}")
        # --- End description generation ---

        # Return the JSON response including the description
        return JSONResponse(content={
            "predicted_class": predicted_label,
            "confidence": round(predicted_confidence, 2),
            "description": disease_description # Added description here
        })

    except Exception as e:
        print(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

# --- Run the FastAPI application (for development) ---
# To run this, save it as e.g., 'main.py' and execute: uvicorn main:app --reload
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) # You can change the port if 8000 is in use
