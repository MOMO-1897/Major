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
import re # Import regular expression module for cleaning strings

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
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}"

# Flag to check if Gemini API is configured for use
is_gemini_api_available = bool(GEMINI_API_KEY and GEMINI_API_KEY != "YOUR_ACTUAL_GEMINI_API_KEY_HERE")
if not is_gemini_api_available:
    print("WARNING: Gemini API Key is not set or is placeholder. Gemini API calls will be skipped.")

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

        # --- Sanitize predicted_label: remove special characters, keep alphanumeric and spaces ---
        # This will ensure cleaner text for the response and Gemini prompts.
        sanitized_label = re.sub(r'[^a-zA-Z0-9\s]', '', predicted_label).strip()

        # --- Initialize description, causes, treatment, and prevention ---
        disease_description = "Description not available."
        disease_causes = ["Causes information not available."]
        disease_treatment = ["Treatment information not available."]
        disease_prevention = ["Prevention information not available."]

        # --- Generate content based on prediction ---
        if "healthy" in sanitized_label.lower(): # Use sanitized label for check
            plant_type = sanitized_label.split(' ')[0]
            # For healthy plants, generate description about the plant itself
            try:
                if is_gemini_api_available:
                    prompt_desc = f"Provide a very short description of a {plant_type} plant, focusing on its common characteristics, in about 20-30 words."
                    payload_desc = {
                        "contents": [{"role": "user", "parts": [{"text": prompt_desc}]}],
                        "generationConfig": {"maxOutputTokens": 60}
                    }
                    headers = {'Content-Type': 'application/json'}

                    async with httpx.AsyncClient() as client:
                        gemini_response_desc = await client.post(GEMINI_API_URL, headers=headers, json=payload_desc, timeout=15.0)
                        gemini_response_desc.raise_for_status()
                        gemini_result_desc = gemini_response_desc.json()

                        if gemini_result_desc and gemini_result_desc.get("candidates") and gemini_result_desc["candidates"][0].get("content"):
                            generated_text = gemini_result_desc["candidates"][0]["content"]["parts"][0]["text"]
                            disease_description = f"Perfectly healthy plant. {generated_text.strip()}"
                        else:
                            print(f"Gemini API response missing content for healthy plant description: {gemini_result_desc}")
                            disease_description = "Perfectly healthy plant. No specific description available."
                else:
                    disease_description = "Perfectly healthy plant."
            except Exception as e:
                print(f"Error generating description for healthy plant: {e}")
                disease_description = "Perfectly healthy plant. Description generation failed."
            
            # For healthy plants, causes, treatment, and prevention are not applicable
            disease_causes = ["No specific disease causes."]
            disease_treatment = ["No treatment needed. Continue good plant care."]
            disease_prevention = ["Maintain optimal growing conditions, proper watering, and nutrition."]

        elif "background without leaves" in sanitized_label.lower(): # Handle "Background without leaves" specifically
            disease_description = "No leaves found in the image. Please upload an image containing plant leaves for analysis."
            disease_causes = ["Image does not contain leaves."]
            disease_treatment = ["No treatment applicable as no leaves were detected."]
            disease_prevention = ["Ensure images contain clear plant leaves."]

        else:
            # Logic for diseased plants
            if is_gemini_api_available:
                try:
                    # Prompt for description (what it is)
                    prompt_desc = f"Provide a brief description of what the plant disease '{sanitized_label}' is, in about 35 words." # Use sanitized label
                    payload_desc = {
                        "contents": [{"role": "user", "parts": [{"text": prompt_desc}]}],
                        "generationConfig": {"maxOutputTokens": 100}
                    }
                    headers = {'Content-Type': 'application/json'}

                    async with httpx.AsyncClient() as client:
                        gemini_response_desc = await client.post(GEMINI_API_URL, headers=headers, json=payload_desc, timeout=15.0)
                        gemini_response_desc.raise_for_status()
                        gemini_result_desc = gemini_response_desc.json()

                        if gemini_result_desc and gemini_result_desc.get("candidates") and gemini_result_desc["candidates"][0].get("content"):
                            disease_description = gemini_result_desc["candidates"][0]["content"]["parts"][0]["text"].strip()
                        else:
                            print(f"Gemini API response missing content for disease description: {gemini_result_desc}")

                except httpx.RequestError as e:
                    print(f"Gemini API request failed for description: {e}")
                except httpx.HTTPStatusError as e:
                    print(f"Gemini API HTTP error for description: {e.response.status_code} - {e.response.text}")
                except json.JSONDecodeError as e:
                    print(f"Failed to decode Gemini API JSON response for description: {e}")
                except Exception as e:
                    print(f"An unexpected error occurred during Gemini API call for description: {e}")

                # Generate causes for diseased plants
                try:
                    prompt_causes = f"Provide 5 short causes for the plant disease '{sanitized_label}', each 3-5 words long. List them as bullet points." # Use sanitized label
                    payload_causes = {
                        "contents": [{"role": "user", "parts": [{"text": prompt_causes}]}],
                        "generationConfig": {"maxOutputTokens": 70} # Sufficient for 5 points * 5 words
                    }
                    headers = {'Content-Type': 'application/json'}

                    async with httpx.AsyncClient() as client:
                        gemini_response_causes = await client.post(GEMINI_API_URL, headers=headers, json=payload_causes, timeout=15.0)
                        gemini_response_causes.raise_for_status()
                        gemini_result_causes = gemini_response_causes.json()

                        if gemini_result_causes and gemini_result_causes.get("candidates") and gemini_result_causes["candidates"][0].get("content"):
                            generated_text_causes = gemini_result_causes["candidates"][0]["content"]["parts"][0]["text"]
                            disease_causes = [
                                item.strip() for item in generated_text_causes.split('\n')
                                if item.strip() and (item.strip().startswith('- ') or item.strip().startswith('* '))
                            ]
                            disease_causes = [item[2:] if item.startswith(('- ', '* ')) else item for item in disease_causes]
                            disease_causes = [re.sub(r'[^a-zA-Z0-9\s]', '', cause).strip() for cause in disease_causes] # Remove special chars from causes
                            disease_causes = disease_causes[:5] # Ensure max 5 items
                        else:
                            print(f"Gemini API response missing content for causes: {gemini_result_causes}")
                            disease_causes = ["Causes generation failed."]

                except httpx.RequestError as e:
                    print(f"Gemini API request failed for causes: {e}")
                except httpx.HTTPStatusError as e:
                    print(f"Gemini API HTTP error for causes: {e.response.status_code} - {e.response.text}")
                except json.JSONDecodeError as e:
                    print(f"Failed to decode Gemini API JSON response for causes: {e}")
                except Exception as e:
                    print(f"An unexpected error occurred during Gemini API call for causes: {e}")

                # Generate treatment for diseased plants
                try:
                    prompt_treatment = f"Provide 5 short general treatment methods for the plant disease '{sanitized_label}', each 3-5 words long. List them as bullet points." # Modified prompt, use sanitized label
                    payload_treatment = {
                        "contents": [{"role": "user", "parts": [{"text": prompt_treatment}]}],
                        "generationConfig": {"maxOutputTokens": 70} # Sufficient for 5 points * 5 words
                    }
                    headers = {'Content-Type': 'application/json'}

                    async with httpx.AsyncClient() as client:
                        gemini_response_treatment = await client.post(GEMINI_API_URL, headers=headers, json=payload_treatment, timeout=15.0)
                        gemini_response_treatment.raise_for_status()
                        gemini_result_treatment = gemini_response_treatment.json()

                        if gemini_result_treatment and gemini_result_treatment.get("candidates") and gemini_result_treatment["candidates"][0].get("content"):
                            generated_text_treatment = gemini_result_treatment["candidates"][0]["content"]["parts"][0]["text"]
                            disease_treatment = [
                                item.strip() for item in generated_text_treatment.split('\n')
                                if item.strip() and (item.strip().startswith('- ') or item.strip().startswith('* '))
                            ]
                            disease_treatment = [item[2:] if item.startswith(('- ', '* ')) else item for item in disease_treatment]
                            disease_treatment = [re.sub(r'[^a-zA-Z0-9\s]', '', treatment).strip() for treatment in disease_treatment] # Remove special chars from treatment
                            disease_treatment = disease_treatment[:5] # Ensure max 5 items
                        else:
                            print(f"Gemini API response missing content for treatment: {gemini_result_treatment}")
                            disease_treatment = ["Treatment information generation failed."]

                except httpx.RequestError as e:
                    print(f"Gemini API request failed for treatment: {e}")
                except httpx.HTTPStatusError as e:
                    print(f"Gemini API HTTP error for treatment: {e.response.status_code} - {e.response.text}")
                except json.JSONDecodeError as e:
                    print(f"Failed to decode Gemini API JSON response for treatment: {e}")
                except Exception as e:
                    print(f"An unexpected error occurred during Gemini API call for treatment: {e}")

                # Generate prevention for diseased plants
                try:
                    prompt_prevention = f"Provide 5 short general prevention methods for the plant disease '{sanitized_label}', each 3-5 words long. List them as bullet points." # Modified prompt, use sanitized label
                    payload_prevention = {
                        "contents": [{"role": "user", "parts": [{"text": prompt_prevention}]}],
                        "generationConfig": {"maxOutputTokens": 70} # Sufficient for 5 points * 5 words
                    }
                    headers = {'Content-Type': 'application/json'}

                    async with httpx.AsyncClient() as client:
                        gemini_response_prevention = await client.post(GEMINI_API_URL, headers=headers, json=payload_prevention, timeout=15.0)
                        gemini_response_prevention.raise_for_status()
                        gemini_result_prevention = gemini_response_prevention.json()

                        if gemini_result_prevention and gemini_result_prevention.get("candidates") and gemini_result_prevention["candidates"][0].get("content"):
                            generated_text_prevention = gemini_result_prevention["candidates"][0]["content"]["parts"][0]["text"]
                            disease_prevention = [
                                item.strip() for item in generated_text_prevention.split('\n')
                                if item.strip() and (item.strip().startswith('- ') or item.strip().startswith('* '))
                            ]
                            disease_prevention = [item[2:] if item.startswith(('- ', '* ')) else item for item in disease_prevention]
                            disease_prevention = [re.sub(r'[^a-zA-Z0-9\s]', '', prevention).strip() for prevention in disease_prevention] # Remove special chars from prevention
                            disease_prevention = disease_prevention[:5] # Ensure max 5 items
                        else:
                            print(f"Gemini API response missing content for prevention: {gemini_result_prevention}")
                            disease_prevention = ["Prevention information generation failed."]

                except httpx.RequestError as e:
                    print(f"Gemini API request failed for prevention: {e}")
                except httpx.HTTPStatusError as e:
                    print(f"Gemini API HTTP error for prevention: {e.response.status_code} - {e.response.text}")
                except json.JSONDecodeError as e:
                    print(f"Failed to decode Gemini API JSON response for prevention: {e}")
                except Exception as e:
                    print(f"An unexpected error occurred during Gemini API call for prevention: {e}")
            else: # If Gemini API is not available
                print("Skipping Gemini API calls for diseased plant: API Key is not set or is placeholder.")
                disease_description = "Description not available (API Key missing)."
                disease_causes = ["Causes not available (API Key missing)."]
                disease_treatment = ["Treatment information not available (API Key missing)."]
                disease_prevention = ["Prevention information not available (API Key missing)."]

        # Return the JSON response including all generated information
        return JSONResponse(content={
            "disease": sanitized_label, # Use sanitized label in the response
            "confidence": round(predicted_confidence, 2),
            "description": disease_description,
            "causes": disease_causes,
            "treatment": disease_treatment,
            "prevention": disease_prevention
        })

    except Exception as e:
        print(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")