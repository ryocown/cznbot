# Project Status & Tasks

This document tracks the current development status and future tasks for CZNbot.

## Phase 1: Planning and Setup
- [x] Initial project review and architecture drafted
- [x] Refine Tool-Use architecture (Slots, SQLite+JSON DB, 1s Polling)
- [x] Get final approval on the mechanics-adjusted implementation plan

## Phase 2: Core Android Services
- [x] Set up `MediaProjection` foreground service for continuous screen capture
- [ ] Implement 1-second turn polling heuristic
- [x] Set up `AccessibilityService` for dispatching gestures
- [ ] Integrate local YOLO model (TFLite/ONNX) to identify object bounding boxes
- [ ] Create coordinate injection pipeline to pass locations to Gemini tools

## Phase 3: Bot Brain (Tool-Use Agent)
- [ ] Establish the Canonical Database (SQLite + JSON) for Cards, Entities, Attributes, and Skills
- [ ] Configure the Gemini API client with Function Declarations (Tools)
- [ ] Implement Tool: `read_screen()`
- [ ] Implement Tool: `read_card(card)` and `read_enemy(enemy)`
- [ ] Implement Tool: `play_card(slot, target_slot?)`
- [ ] Implement Tool: `play_skill(char_slot, target_slot?)`
- [ ] Implement Tool: `play_ego_skill(char_slot, target_slot?)`
- [ ] Implement Tool: `use_proto_skill(action_type)`
- [ ] Implement Tool: `end_turn()`

## Phase 4: Testing & Iteration
- [ ] Test dynamic coordinate mapping logic (1 to 10 cards)
- [ ] Test SQLite canonical data retrieval
- [ ] Test End-to-End game loop inside AVD with Gemini 1.5 Pro
