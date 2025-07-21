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
CLASS_LABELS = [
    'Apple___Apple_scab',
    'Apple___Black_rot',
    'Apple___Cedar_apple_rust',
    'Apple___healthy',
    'Background_without_leaves',
    'Blueberry___healthy',
    'Cherry___Powdery_mildew',
    'Cherry___healthy',
    'Corn___Cercospora_leaf_spot Gray_leaf_spot',
    'Corn___Common_rust',
    'Corn___Northern_Leaf_Blight',
    'Corn___healthy',
    'Grape___Black_rot',
    'Grape___Esca_(Black_Measles)',
    'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
    'Grape___healthy',
    'Orange___Haunglongbing_(Citrus_greening)',
    'Peach___Bacterial_spot',
    'Peach___healthy',
    'Pepper,_bell___Bacterial_spot',
    'Pepper,_bell___healthy',
    'Potato___Early_blight',
    'Potato___Late_blight',
    'Potato___healthy',
    'Raspberry___healthy',
    'Soybean___healthy',
    'Squash___Powdery_mildew',
    'Strawberry___Leaf_scorch',
    'Strawberry___healthy',
    'Tomato___Bacterial_spot',
    'Tomato___Early_blight',
    'Tomato___Late_blight',
    'Tomato___Leaf_Mold',
    'Tomato___Septoria_leaf_spot',
    'Tomato___Spider_mites Two-spotted_spider_mite',
    'Tomato___Target_Spot',
    'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
    'Tomato___Tomato_mosaic_virus',
    'Tomato___healthy'
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
        model.summary() # Print model summary to console for verification
        print("Keras model loaded successfully!")
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

        # Format all probabilities into a dictionary
        all_probabilities = {
            label: round(float(prob * 100), 2) for label, prob in zip(CLASS_LABELS, probabilities)
        }

        # Return the JSON response
        return JSONResponse(content={
            "predicted_class": predicted_label,
            "confidence": round(predicted_confidence, 2),
        })

    except Exception as e:
        print(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Prediction failed: {e}")

# --- Run the FastAPI application (for development) ---
# To run this, save it as e.g., 'main.py' and execute: uvicorn main:app --reload
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) # You can change the port if 8000 is in use
