# Chaos Zero Nightmare: Combat System & Automation Framework

## 1. Core Combat Architecture

The game utilizes a turn-based, deck-building combat system with roguelike progression.

* **Action Points (AP):** The player receives **3 AP** at the start of every turn. Card costs range from 0 to 4+ AP.
* **Card Draw & Hand Limits:** The agent draws **5 cards** at the beginning of its turn. The maximum hand size is **10 cards**.
* **Discard Logic:** At the end of the turn, all unused cards are moved to the Graveyard (discard pile). The deck reshuffles when empty.
* **Health Pool:** The deployed team of three operators shares a **single cumulative HP bar** and shield pool, rather than individual health pools.
* **Enemy Action Triggers:** Enemies do not adhere to standard alternating turns. Instead, they operate on an **Action Counter**. The counter decreases by 1 for every card the player plays. When the counter reaches 0, the enemy immediately interrupts to take its action. Enemy intent (Powerful Attack, Consecutive Strikes, Defensive Shield) is broadcasted via an icon above their model.

---

## 2. Operator Roles (Classes)

Operators must be drafted and positioned based on their mechanical archetypes. The AI should prioritize team compositions that include a dedicated tank (Vanguard), a healer/buffer (Controller/Supporter), and a primary damage dealer.

| Class | Combat Role | Primary Function for AI Logic |
| --- | --- | --- |
| **Striker** | Frontline DPS / Bruiser | Balanced offense/defense; handles sustained frontline damage. |
| **Psionic** | Burst DPS | High-multiplier burst damage; requires setup or specific AP thresholds. |
| **Vanguard** | Tank | Generates team-wide shields, absorbs heavy damage, applies taunts/damage mitigation. |
| **Ranger** | Ranged DPS | Provides consistent, single-target damage output from safety. |
| **Hunter** | Control DPS | Agile attacker prioritizing precision strikes, counterattacks, and enemy disruption. |
| **Controller** | Support / Debuffer | Heals the shared HP bar, manages team stress, and applies debuffs (e.g., Vulnerable, Weaken). |

---

## 3. Attribute System & Weaknesses

The combat math is heavily dictated by elemental advantage and the enemy's shield threshold.

* **The Five Attributes:** Passion, Void, Instinct, Order, and Justice.
* **Tenacity Gauge:** Elite enemies and bosses possess a Tenacity Gauge beneath their HP bar, acting as extreme damage mitigation.
* **Breakthrough State:** The AI must prioritize breaking the Tenacity Gauge by attacking with the enemy's **weakness attribute** or using **high-cost AP cards**. When the gauge reaches zero, the enemy enters a "Breakthrough" (stunned) state, leaving them immobilized and highly susceptible to burst damage.

---

## 4. Card Typology & Keywords

The deck consists of multiple card types that the AI must identify and sequence correctly.

| Card Type | Color Code | AI Execution Logic |
| --- | --- | --- |
| **Attack Cards** | Red | Select target and execute direct damage. |
| **Skill Cards** | Blue | Apply shields, heal shared HP, or draw additional cards. |
| **Upgrade Cards** | Green | Permanent buffs for the duration of the combat instance. Prioritize early in the encounter. |
| **Status Cards** | Gray | Neutral cards; often low-impact buffs or minor debuffs. |
| **Curse Cards** | Black/Purple | Negative modifiers implanted by enemies/events (e.g., Bleed). AI must prioritize purging these if mechanics allow. |

**Critical Card Keywords & Mechanics:**

* **Epiphany ("Flash of Inspiration"):** Cards will occasionally glow with a spark in hand. Playing an Epiphany card generates a unique, character-exclusive card that costs **0 AP** for one turn.
* **Exhaust / Void:** Cards that are removed from the deck for the remainder of the battle after use. Certain operators (like Kayron) scale their damage based on the total number of Exhausted "Void" status cards in the Graveyard.
* **Remove:** Event cards with this tag delete themselves after use and do not penalize the Save Data cap.

---

## 5. Mental Stress & Breakdown Mechanics

Stress management is a secondary health economy that the AI must actively monitor.

* **Stress Accumulation:** Operators accumulate stress (purple bar) when taking damage or navigating polluted map nodes.
* **Mental Breakdown Threshold:** If an operator hits 100% Stress, they suffer a Breakdown.
* **Penalties:** 1. The team instantly loses **1/3 of its Maximum HP**.
2. Normal cards belonging to that operator are replaced by unplayable "Break Cards".
3. Ego Skills (Ultimates) are disabled.
4. *Fail State:* If all three operators break down simultaneously, the run ends in a Game Over.
* **Recovery:** The AI must use healing/shielding Skill cards to mitigate damage before stress caps, or meet specific recovery conditions (e.g., playing a required number of Break cards) to cleanse the Breakdown state.

---

## 6. Ego Skills & Time Manipulation

* **Ego Skills (Ultimates):** The AI generates EP by spending AP, killing enemies, and ending turns. Ego skills cost EP (not AP) and are character-specific ultimate abilities. The AI should hoard EP for Breakthrough phases or emergency healing.
* **Manifest Ego:** This is the duplicate (gacha dupes) progression system. Operators gain significant mechanical shifts at specific nodes (e.g., E1, E2, E6), altering the mathematical value of their cards. The AI must ingest the Manifest Ego level of an operator to calculate true damage output.
* **Proto Skill (Sands of Time):** Located via the hourglass icon. The AI can utilize this system to correct state errors. It allows the agent to **undo the last card played**, **rewind to the start of the turn**, or **reroll ultimate skills**.

---

## 7. Roguelike Run Logic: "Save Data"

As the AI navigates a run (Map nodes: Red for Combat, Purple for Elites, Yellow for Camps, '?' for Events), it modifies the deck. The game strictly limits deck bloat via the "Save Data" points cap.

* **Cap Calculation:** Base Tier equals Chaos difficulty (e.g., Difficulty 6 = Tier 6). Exceeding the point cap forces the game to automatically delete cards or remove Epiphanies from the deck.
* **Point Costs:**
* *Neutral / Monster Cards:* Adding these costs high points (e.g., Monster Cards = 80 points).
* *Card Removal:* Scales up per use ($0 \rightarrow 10 \rightarrow 30 \rightarrow 50 \rightarrow 70$). Removing a base character card incurs an immediate +20 penalty.
* *Card Conversion:* Costs 10 points.


* **AI Optimization Loop:** The AI should convert a bad base card to a neutral card (10 points) and *then* remove the neutral card, bypassing the +20 base removal penalty. It should strictly avoid retaining Monster Cards at the end of a run unless the Tier cap allows it.