import os
import tensorflow as tf
from tensorflow import keras
from PIL import Image # Pillow for image processing
import numpy as np
import io
import json # Import the json module

# --- Configuration ---
# Path to your existing .keras model file
# Ensure this file is in the same directory as this script, or provide an absolute path.
KERAS_H5_MODEL_PATH = "Plant_Disease_Detection.keras"

# Define your model's expected input dimensions
IMG_WIDTH = 160
IMG_HEIGHT = 160
IMAGE_CHANNELS = 3 # RGB

# IMPORTANT: Populate this array with the exact class names
# in the order determined by your Keras model's training.
# This list should be identical to `class_names` from your Python training script.
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

# --- 1. Load the Model ---
print(f"Attempting to load Keras model from: {KERAS_H5_MODEL_PATH}")
if not os.path.exists(KERAS_H5_MODEL_PATH):
    print(f"Error: Model file not found at: {KERAS_H5_MODEL_PATH}")
    exit() # Exit if model file is not found

try:
    model = tf.keras.models.load_model(KERAS_H5_MODEL_PATH, custom_objects=CUSTOM_OBJECTS)
    print("Keras model loaded successfully!")
    model.summary() # Print model summary to console for verification
except Exception as e:
    print(f"Error loading Keras model: {e}")
    exit() # Exit if model loading fails

# --- 2. Prepare a Sample Image for Prediction ---
# You'll need to replace 'path/to/your/sample_image.jpg' with an actual image file.
# For testing, you can download a sample image or use one from your dataset.
SAMPLE_IMAGE_PATH = 'soy-leaves-green-health.jpg' # <--- IMPORTANT: CHANGE THIS PATH

print(f"\nAttempting to predict on sample image: {SAMPLE_IMAGE_PATH}")
if not os.path.exists(SAMPLE_IMAGE_PATH):
    print(f"Error: Sample image file not found at: {SAMPLE_IMAGE_PATH}")
    print("Please update SAMPLE_IMAGE_PATH to a valid image file on your system.")
    exit()

try:
    # Load image using Pillow (PIL)
    # Ensure image is converted to RGB if it's grayscale or RGBA
    image = Image.open(SAMPLE_IMAGE_PATH).convert("RGB")
    image = image.resize((IMG_WIDTH, IMG_HEIGHT)) # Resize to model's expected input size

    # Convert PIL Image to NumPy array
    img_array = np.array(image, dtype=np.float32)

    # Add batch dimension: (H, W, C) -> (1, H, W, C)
    img_array = np.expand_dims(img_array, axis=0)

    # Apply MobileNetV3 preprocessing: scale from [0, 255] to [-1, 1]
    preprocessed_img_array = tf.keras.applications.mobilenet_v3.preprocess_input(img_array)

    # --- 3. Perform Prediction ---
    predictions = model.predict(preprocessed_img_array)

    # Get the probabilities and find the predicted class
    probabilities = predictions[0] # Get probabilities for the single image in the batch
    predicted_class_index = np.argmax(probabilities)
    predicted_confidence = float(np.max(probabilities)) * 100 # Convert to float and percentage

    predicted_label = CLASS_LABELS[predicted_class_index]

    # --- 4. Prepare Response as JSON ---
    response_data = {
        "predicted_class": predicted_label,
        "confidence": round(predicted_confidence, 2),
    }

    # Print the JSON string to console
    print(json.dumps(response_data, indent=2)) # Use indent for pretty-printing JSON

except Exception as e:
    print(f"An error occurred during prediction: {e}")

print("\nScript finished.")
