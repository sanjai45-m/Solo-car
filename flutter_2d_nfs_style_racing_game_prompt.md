# Flutter 2D NFS-Style Racing Game Development Prompt

Build a complete **2D high-quality car racing game in Flutter**, inspired by the gameplay feel of classic Need for Speed-style arcade racing, but using completely original assets, UI, names, cars, environments, and sounds.

## Goal

Create a playable mobile racing game where the player drives a car at high speed through roads, avoids traffic, overtakes opponents, collects rewards, and progresses through races.

The game should feel like a real racing game, not like a simple Flutter animation or basic 2D demo.

## Technology

Use:

- Flutter
- Dart
- Flame game engine for the game loop, rendering, collision detection, sprites, particles, and game entities
- Flutter widgets for menus, HUD, settings, garage, race selection, etc.
- Keep the architecture modular and production-ready.

Do **not** build the entire game using normal Flutter widgets. Use Flame for the actual gameplay.

---

# 1. Game Camera

Use a **top-down / 2D pseudo-3D racing perspective**.

The player should see:

- Road extending toward the top of the screen
- Player car near the bottom
- Road scrolling continuously
- Traffic cars
- Opponent cars
- Roadside objects
- Buildings
- Trees
- Street lights
- Barriers
- Signs
- Grass
- Different environments

The road should give the impression that the car is travelling at high speed.

Implement smooth camera/road movement rather than simply moving one static background image.

---

# 2. Player Car

Create a controllable player car.

## Mobile Controls

Support:

- Left steering
- Right steering
- Accelerate
- Brake
- Nitro

Also support:

- Touch steering
- Optional tilt controls
- Optional virtual steering wheel

The player car should have:

- Acceleration
- Maximum speed
- Braking
- Steering
- Friction
- Nitro acceleration
- Collision detection
- Damage state

The car should visually rotate slightly while steering.

Make steering smooth rather than instantly changing the car position.

---

# 3. Physics

Implement arcade-style racing physics.

The player should have:

```text
speed
acceleration
maxSpeed
brakeForce
steering
steeringSensitivity
friction
nitroMultiplier
```

Example behavior:

- Holding accelerate gradually increases speed.
- Releasing accelerate causes the car to slow down naturally.
- Braking rapidly decreases speed.
- Steering becomes more responsive at lower speeds.
- At high speed, steering becomes slightly less sensitive.
- Nitro temporarily increases acceleration and maximum speed.
- Collisions reduce speed.

Do not attempt to create a completely realistic physics simulator.

The goal is **fun arcade racing physics**.

---

# 4. Road System

Create a reusable procedural road system.

The road should support:

- Straight roads
- Gentle left turns
- Gentle right turns
- Sharp turns
- Curved roads
- Different road widths
- Multiple lanes

The road should continuously generate ahead of the player and remove old sections behind the player.

This should prevent the game from requiring one enormous background image.

Create a system similar to:

```text
RoadManager
RoadSegment
Lane
RoadCurve
RoadDecoration
```

Each road segment can define:

```text
length
curve
laneCount
roadType
environment
```

---

# 5. Traffic

Add AI-controlled traffic vehicles.

Traffic cars should:

- Drive forward
- Stay within lanes
- Change lanes occasionally
- Have different speeds
- Avoid some collisions
- Spawn dynamically
- Despawn behind the player

Traffic should not look synchronized.

Create different traffic behaviors:

```text
SlowTraffic
NormalTraffic
FastTraffic
AggressiveTraffic
```

---

# 6. Opponent Racing AI

Create actual racing opponents.

Each opponent should:

- Follow the road
- Accelerate
- Brake
- Change lanes
- Avoid obstacles
- Overtake
- Compete with the player
- Have different difficulty levels

Difficulty:

```text
Easy
Normal
Hard
Expert
```

Do not make AI simply move at a fixed speed.

Use basic decision-making based on:

- Player position
- Nearby traffic
- Road curve
- Current speed
- Race position

---

# 7. Nitro System

Add a visually impressive nitro system.

When nitro is active:

- Car accelerates rapidly
- Screen slightly shakes
- Motion blur-like effect appears
- Exhaust flames appear
- Road speed increases visually
- Nitro particles appear
- Engine sound changes
- HUD nitro bar decreases

Nitro should recharge through gameplay.

For example:

- Overtaking cars
- Near misses
- Drifting
- Collecting nitro pickups

---

# 8. Drifting

Implement arcade drifting.

When the player takes a sharp turn at high speed:

- Car rotates slightly
- Tire smoke appears
- Drift particles appear
- Drift score increases
- Drift duration is tracked

Add:

```text
driftScore
driftMultiplier
driftDuration
```

Reward longer and more controlled drifts.

---

# 9. Collision System

Implement collisions between:

- Player ↔ traffic
- Player ↔ opponents
- Player ↔ barriers
- Player ↔ roadside objects

Different collisions should have different effects.

### Minor collision

```text
small speed reduction
small screen shake
```

### Major collision

```text
large speed reduction
car spin
damage
screen shake
```

---

# 10. Race System

Create multiple race modes.

### Circuit Race

Complete a specific number of laps.

### Sprint

Race from point A to point B.

### Time Trial

Reach the destination before the timer ends.

### Traffic Challenge

Drive through traffic and achieve a target score.

### Knockout

The last racer is eliminated periodically.

---

# 11. Race HUD

During gameplay show:

Top-left:

```text
POSITION
2 / 8
```

Top-center:

```text
LAP
2 / 3
```

Top-right:

```text
SPEED
248 KM/H
```

Bottom:

```text
NITRO BAR
```

Also display:

- Race timer
- Mini-map
- Current score
- Drift multiplier
- Near-miss notifications
- Countdown

Example:

```text
3
2
1
GO!
```

Make the HUD look like a modern racing game.

---

# 12. Mini Map

Create a small minimap.

It should show:

- Road
- Player
- Opponents
- Race direction

The minimap should update dynamically based on the current race.

---

# 13. Garage

Create a garage screen.

The player can view their cars.

Show:

```text
TOP SPEED
ACCELERATION
HANDLING
BRAKING
NITRO
```

Use graphical stat bars.

Allow the player to:

- Select cars
- Upgrade cars
- Change colors
- Change wheels
- Upgrade engine
- Upgrade brakes
- Upgrade handling
- Upgrade nitro

---

# 14. Car Progression

Create a currency system.

Example:

```text
Coins
Cash
Race Tokens
```

Players earn currency from races.

Use currency to upgrade cars.

Example:

```text
Engine Level 1 → 2
Handling Level 1 → 2
Brake Level 1 → 2
Nitro Level 1 → 2
```

Store player progress locally.

Use SharedPreferences or Hive for persistence.

---

# 15. Main Menu

Create a polished racing-game main menu.

Menu:

```text
PLAY
GARAGE
RACES
UPGRADES
SETTINGS
```

Display the player's selected car prominently.

Use animated background elements.

The menu should feel like a premium racing game.

---

# 16. Race Selection

Create a race-selection screen.

Display:

```text
Race 01
Race 02
Race 03
Race 04
Race 05
```

Each race should have:

- Environment
- Difficulty
- Distance
- Reward
- Best time
- Required unlock level

Lock future races until previous races are completed.

---

# 17. Environments

Create multiple environments.

## City

- Buildings
- Street lights
- Traffic
- Billboards
- Crossroads

## Highway

- Large road
- Multiple lanes
- High-speed traffic
- Bridges

## Desert

- Sand
- Rocks
- Cactus
- Mountains

## Forest

- Trees
- Curved roads
- Fog
- Different lighting

Use parallax layers to make the environments feel deeper.

---

# 18. Day/Night

Support:

- Day
- Sunset
- Night

Night mode should include:

- Headlights
- Street lights
- Building lights
- Neon signs
- Reflections

Use lighting overlays where possible.

---

# 19. Particles

Add polished particle effects.

Implement:

- Tire smoke
- Nitro flames
- Sparks
- Dust
- Rain
- Exhaust
- Collision particles
- Road debris

Use Flame's particle system where appropriate.

---

# 20. Audio

Add:

- Engine sound
- Acceleration sound
- Braking sound
- Nitro sound
- Collision sound
- Tire screech
- Countdown
- Race start
- Race finish
- UI click sounds
- Background music

Engine sound should change based on speed.

---

# 21. Camera Effects

Add subtle game-feel effects:

- Camera shake during collisions
- Camera shake during nitro
- Slight camera zoom during nitro
- Speed lines at high speed
- Screen flash for major collisions
- Smooth transitions

Do not overuse effects.

Performance must remain smooth.

---

# 22. Performance

The game must target:

```text
60 FPS
```

on modern Android devices.

Avoid:

- Creating thousands of objects every frame
- Loading huge textures unnecessarily
- Memory leaks
- Unnecessary rebuilds
- Expensive calculations inside update()
- Repeated asset loading

Use:

- Object pooling
- Sprite reuse
- Efficient collision detection
- Lazy asset loading
- Proper disposal

---

# 23. Responsive Design

The game must work on:

- Android phones
- Android tablets
- iPhones
- iPads

Gameplay should automatically adapt to different aspect ratios.

Do not hardcode positions based on one screen size.

---

# 24. Game Architecture

Use a clean architecture.

Suggested structure:

```text
lib/
 ├── main.dart
 ├── game/
 │   ├── racing_game.dart
 │   ├── components/
 │   │   ├── player_car.dart
 │   │   ├── opponent_car.dart
 │   │   ├── traffic_car.dart
 │   │   ├── road_segment.dart
 │   │   ├── road_manager.dart
 │   │   ├── obstacle.dart
 │   │   └── pickup.dart
 │   │
 │   ├── systems/
 │   │   ├── race_system.dart
 │   │   ├── traffic_system.dart
 │   │   ├── ai_system.dart
 │   │   ├── collision_system.dart
 │   │   ├── nitro_system.dart
 │   │   └── particle_system.dart
 │   │
 │   └── models/
 │       ├── car_model.dart
 │       ├── race_model.dart
 │       └── player_progress.dart
 │
 ├── screens/
 │   ├── main_menu.dart
 │   ├── garage.dart
 │   ├── race_selection.dart
 │   ├── settings.dart
 │   └── race_screen.dart
 │
 ├── services/
 │   ├── audio_service.dart
 │   ├── save_service.dart
 │   └── asset_service.dart
 │
 └── widgets/
     ├── game_hud.dart
     ├── speedometer.dart
     ├── nitro_bar.dart
     └── minimap.dart
```

---

# 25. Important Implementation Requirement

Do not create a fake demo where the car simply moves left and right over a background.

I want an actual playable racing-game architecture.

The first version should contain:

1. Main menu
2. Race selection
3. Playable race
4. Player car
5. Steering
6. Acceleration
7. Braking
8. Nitro
9. Traffic
10. Opponent AI
11. Collision
12. Speedometer
13. Race position
14. Timer
15. Finish screen
16. Rewards
17. Garage
18. Car upgrades
19. Save/load progress

---

# 26. Development Strategy

Do not attempt to generate the entire game in one giant implementation if that makes the code unstable.

Build it incrementally.

## Phase 1

Create:

- Flutter project
- Flame setup
- Game loop
- Road
- Player car
- Steering
- Acceleration
- Basic camera movement

Make sure this phase runs.

## Phase 2

Add:

- Traffic
- Collision
- Speed
- Nitro
- Particles

## Phase 3

Add:

- Opponent AI
- Race positions
- Finish conditions
- Race timer

## Phase 4

Add:

- Main menu
- Race selection
- Garage
- Upgrades
- Currency
- Save system

## Phase 5

Add:

- Multiple environments
- Day/night
- Audio
- Advanced effects
- Minimap
- Polish

After each phase, ensure the application compiles and runs before continuing.

---

# 27. Visual Quality

The game should look like a **premium mobile arcade racing game**.

Avoid:

- Basic rectangles
- Placeholder-looking UI
- Plain Flutter buttons
- Static backgrounds
- Generic demo-game appearance

Use:

- High-quality 2D sprites
- Gradients
- Glow effects
- Shadows
- Particles
- Smooth animations
- Modern racing UI
- Glass/metal/neon-style HUD elements

All assets must be original or generated/placeholder assets that can legally be replaced later. Do not copy Need for Speed assets, logos, cars, characters, sounds, or other copyrighted material.

---

# 28. Deliverables

Generate the actual Flutter source code.

Include:

- pubspec.yaml dependencies
- Complete folder structure
- Dart source files
- Asset loading system
- Game configuration
- Example assets/placeholders where necessary
- Instructions for running the project
- Instructions for replacing placeholder car/road assets

The final project should run with:

```bash
flutter pub get
flutter run
```

Do not stop at explaining how the game could be made.

Actually implement the playable game, starting with Phase 1 and then progressively implementing the remaining systems.

If a feature is too complex to implement immediately, create a clean abstraction/interface for it and continue with a working implementation rather than leaving broken or pseudocode sections.
