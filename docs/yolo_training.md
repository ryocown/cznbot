# YOLOv8 Training Pipeline for CZNbot

To enable the bot to "see" the game state (identify cards, enemies, and characters), we use a custom-trained **YOLOv8** model optimized for mobile devices.

This document outlines the end-to-end workflow for gathering data, labeling it, training the model, and integrating it into the Android application.

---

## 🏗 Directory Structure
All training-related assets are stored in the `yolo_training/` directory at the root of the project:
- `data/raw/`: Original gameplay screenshots and videos.
- `data/annotated/`: Labeled images and YOLO-format text files.
- `scripts/`: Automation tools (e.g., `record_gameplay.sh`).
- `models/`: Exported `.tflite` or `.onnx` models.
- `notebooks/`: Training scripts (Jupyter/Colab).

---

## 📥 Phase 1: Data Collection
We need diverse screenshots of the game in combat.
1. Use the AVD (Android Virtual Device) to run *Chaos Zero Nightmare*.
2. Run the collection script:
   ```bash
   cd yolo_training/scripts
   ./record_gameplay.sh <seconds> <session_name>
   ```
3. This script will:
   - Record the AVD screen using `adb`.
   - Pull the video to `yolo_training/data/raw/`.
   - Use `ffmpeg` to extract frames at 1 frame-per-second (FPS).

---

## 🏷 Phase 2: Labeling (Annotation)
Upload the extracted frames from `data/raw/` to an annotation platform (e.g., [Roboflow](https://roboflow.com/) or CVAT).

**Target Classes:**
- `card`: Individual cards in the player's hand.
- `character`: Ally characters on the field.
- `enemy`: Enemy entities (foes).
- `button_end_turn`: The interface element to end the turn.

**Export:**
Once labeled, export the dataset in **YOLOv8** format. Extract the resulting ZIP into `yolo_training/data/annotated/`.

---

## 🧠 Phase 3: Training
We use **YOLOv8 Nano (n)** as the base model because it provides the best balance of speed and accuracy for mobile processors.

1. Open `yolo_training/notebooks/train_yolov8.ipynb`.
2. Run the training cells. If using a local machine without a GPU, it's recommended to upload this notebook to **Google Colab**.
3. **Hyperparameters:** 
   - Image size: 640
   - Epochs: 50–100 (depending on dataset size).

---

## 📲 Phase 4: Mobile Export & Integration
Once training is complete, the model must be converted from PyTorch (`.pt`) to TensorFlow Lite (`.tflite`).

1. **Export Command:**
   ```python
   model.export(format='tflite')
   ```
2. **Move to Android Assets:**
   Copy the resulting `best_saved_model.tflite` into:
   `/app/src/main/assets/yolo_model.tflite`

3. **In-App Usage:**
   The `ScreenCaptureService` will load this model to identify bounding boxes, which are then passed to the Gemini Agent as logical slot coordinates.
