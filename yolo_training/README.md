# YOLOv8 Training Side Quest

This directory contains everything needed to train the custom YOLO vision model for CZNbot.

## 1. Raw Data Collection (`data/raw/`)
Run `scripts/record_gameplay.sh <seconds> <name>` while the game is open in the emulator. 
It will pull a video, extract screenshots at 1fps using ffmpeg, and place them in `data/raw/`.

## 2. Annotation (`data/annotated/`)
Upload the screenshots from `data/raw/` to a labeling tool like Roboflow or CVAT.
Draw bounding boxes around:
- `card`
- `character`
- `enemy`

Export the dataset in "YOLOv8" format (.yaml and txt files) into the `data/annotated/` folder.

## 3. Training (`notebooks/`)
Use the `notebooks/train_yolov8.ipynb` script (locally or in Google Colab) pointing to the `data/annotated/` folder.
This will fine-tune the `yolov8n.pt` model.

## 4. Export (`models/`)
The notebook will export a `.tflite` file. Move that file into the `models/` directory for safekeeping, and copy it into the Android App's `app/src/main/assets/` folder to be used by the Bot's Actuator.
