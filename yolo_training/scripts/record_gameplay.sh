#!/bin/bash
# record_gameplay.sh
# 
# This script records the screen of your Android Virtual Device (AVD) 
# and saves it locally as an MP4 file. It then uses ffmpeg to automatically
# extract frames from that video into a folder so you can upload them to Roboflow.
#
# Usage: ./record_gameplay.sh <duration_in_seconds> <output_filename>

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./record_gameplay.sh <duration_in_seconds> <output_filename_without_extension>"
    echo "Example: ./record_gameplay.sh 60 combat_session_1"
    exit 1
fi

DURATION=$1
FILENAME=$2
DEVICE_PATH="/sdcard/${FILENAME}.mp4"
LOCAL_PATH="../data/raw/${FILENAME}.mp4"
FRAMES_DIR="../data/raw/frames_${FILENAME}"

echo "Ensure your AVD is running and the game is open."
echo "Starting recording for ${DURATION} seconds..."

# Run screenrecord on the emulator
adb shell screenrecord --time-limit $DURATION $DEVICE_PATH

echo "Recording finished. Pulling video to local machine..."
mkdir -p ./yolo_dataset
adb pull $DEVICE_PATH $LOCAL_PATH

echo "Video saved to ${LOCAL_PATH}"

# Optional: Extract frames using ffmpeg if it's installed
if command -v ffmpeg &> /dev/null; then
    echo "Extracting 1 frame per second for YOLO dataset..."
    mkdir -p $FRAMES_DIR
    # -r 1 means 1 frame per second. Adjust if you want more/less screenshots.
    ffmpeg -i $LOCAL_PATH -r 1 "${FRAMES_DIR}/frame_%04d.jpg"
    echo "Frames extracted to ${FRAMES_DIR}."
else
    echo "ffmpeg is not installed. Skipping automatic frame extraction."
    echo "You can manually extract frames from the MP4, or install ffmpeg:"
    echo "sudo apt install ffmpeg (Ubuntu/Debian)"
    echo "brew install ffmpeg (macOS)"
fi

echo "Cleaning up device storage..."
adb shell rm $DEVICE_PATH

echo "Done! Upload the images in ${FRAMES_DIR} to Roboflow."
