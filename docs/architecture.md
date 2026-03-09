# CZNbot Implementation Plan

## Goal Description
Develop an Android application that autonomously plays the mobile game "Chaos Zero Nightmare". The bot uses Gemini in a **Tool-Use (Agent) Architecture**. The AI receives access to specific functions (tools) to investigate the game state and execute physical actions via emulated gestures.

This iteration addresses the specific mechanics of CZN (AP, EP, Stress, Tenacity) and refines how the bot interacts with the screen and game data.

## Proposed Architecture

### 1. The Screen Capturer & Turn Detector (`MediaProjection` Service)
*   A Foreground Service that uses the `MediaProjection` API.
*   **Turn Polling:** The service will capture a frame **every 1 second** and perform lightweight local processing (or send to a fast, dedicated vision model/heuristic) to determine if it is the player's turn (e.g., looking for the End Turn button or AP UI). Once detected, it triggers the Brain.

### 2. The Actuator (`AccessibilityService` & Local Computer Vision)
*   **Object Detection (`YOLO` Model):** 
    Before Gemini can execute an action, a lightweight `YOLO` (You Only Look Once) model runs locally on the Android device (via ONNX Runtime or TFLite). It scans the fresh screenshot and identifies all interactive objects: Friendlies, Foes, and Cards in Hand.
    See [YOLO Training Pipeline](./yolo_training.md) for details on how we train this model.
*   **Coordinate Injection:** 
    The YOLO model returns a bounding box (X, Y coordinates) for each detected entity. These coordinates are appended to the entity's logical name before being passed to Gemini (e.g., `enemy1_loc: [450, 800]`, `slot3_loc: [120, 950]`).
*   **Coordinate Mapping:** 
    When Gemini calls `play_card(card_id, target_id)`, the Actuator looks up the YOLO-generated coordinates for those two IDs and executes the mapped physical drag/tap gestures using the `AccessibilityService`.

### 3. Canonical Database (SQLite + JSON)
*   A local data store acting as the source of truth for the game domain.
*   Contains definitions for Cards (AP cost, traits like Exhaust/Remove), Characters (Roles, Attributes, Ego Skills), Enemies (Tenacity, Weaknesses), and Status/Curse modifiers.
*   This ensures Gemini operates on exact, mathematical definitions rather than hallucinating text from small screen captures.

### 4. The Brain (Gemini Tool-Use Agent)
*   Integration with the Gemini SDK utilizing `Function Declarations`. Gemini is provided the following tools to manage HP, AP, EP, Stress, and Save Data:
    
    *   **Core Inspection Tools:**
        *   `read_screen()`: Request a fresh screenshot and logical summary (e.g., card count, current AP/EP).
        *   `read_card(card_identifier)`: Queries the local SQLite DB for exact effects.
        *   `read_enemy(enemy_name)`: Queries the local DB for Tenacity gauge weaknesses and innate traits.
    
    *   **Action Tools (Automatically map Slots -> Coordinates):**
        *   `play_card(hand_slot_index, target_slot_index?)`: Drag a card from the fluctuating hand UI to an ally/enemy.
        *   `play_skill(character_slot_index, target_slot_index?)`: Drag a standard character skill.
        *   `play_ego_skill(character_slot_index, target_slot_index?)`: Use a character's Ultimate ability (consumes EP).
        *   `use_proto_skill(action_type)`: Access the hourglass to "undo", "rewind", or "reroll".
        *   `end_turn()`: Tap the end turn button to pass initiative back to the enemy Action Counters.

## Verification Plan

### Automated Tests
1.  **Coordinate Math Tests:** Given a simulated screen width and a hand size of N (1-10), verify the Actuator correctly calculates the center X coordinate for slot index K.
2.  **Tool Routing Tests:** Verify that Gemini's function call requests are properly routed to the correct local methods.
3.  **Database Queries:** Verify the SQLite + JSON data loader correctly surfaces complex attributes (like "Breakthrough" weaknesses) to the agent.

### Manual Verification
1.  **Polling Test:** Run the app over the game and verify it correctly detects the start of a turn and fires the trigger event without draining excessive battery.
2.  **E2E Agent Loop:** Observe Gemini intelligently prioritizing target elements (e.g., breaking a Tenacity gauge before bursting) using the provided tools.
