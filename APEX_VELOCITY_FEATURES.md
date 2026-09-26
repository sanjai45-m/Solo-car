# 🏎️ APEX VELOCITY: Complete Feature Specification & Architecture Guide

---

## 🌟 Executive Summary

**Apex Velocity** is a high-speed, cross-platform Cyberpunk Arcade Racing Game built with **Flutter 3.x** and the **Flame Engine**. It seamlessly blends responsive 2D physics gameplay with high-gloss 3D UI aesthetics, real-time cloud multiplayer, dedicated Google authentication, procedural synthesizer audio, and serverless cloud persistence.

---

## 📑 Feature Breakdown

### 1. 🏎️ High-Speed Racing & Physics Engine
- **Physics-Driven Flame Game Engine**: Smooth 60+ FPS collision detection, custom momentum curves, and dynamic camera vibration.
- **Nitro Boost System**: Hold or tap nitro to unleash high-speed speed multipliers accompanied by cyan/orange particle jet streams and screen blur.
- **Dynamic Drift Scoring**: Drift around turns to build combo multipliers and bank high scores.
- **Near-Miss Bonus System**: Overtaking traffic at high speeds awards instant nitro refuels and style points.
- **Procedural Traffic & Obstacles**: AI traffic cars with lane-switching logic, oil slicks, and laser energy barriers that scale dynamically in difficulty.
- **Multi-Track Selection**:
  - *Neon City Cyber Highway* (High-speed straightaways & traffic weaving)
  - *Midnight Outrun Boulevard* (Technical corners & tunnel sections)
  - *Cyber Downtown Circuit* (Chicane turns & neon skyscrapers)

---

### 2. 🎨 2D/3D Hybrid Visual Aesthetics & UI Design System
- **3D App Emblem & High-Gloss Logo**: Custom 3D futuristic chrome emblem with neon cyan glow and specular top-rim lighting.
- **Cinematic 3D Animated Splash Screen**: Camera zoom-in, glowing emblem pulse, real-time telemetry loading bar, and seamless audio transition into the main menu.
- **3D Hypercar Cinematic Background**: Dynamic high-resolution 3D concept racing art integrated across all menus with dark cyberpunk vignette overlays.
- **Stationary 3D Glassmorphism Cards**: Multi-tier drop shadows, top specular bevels, and frosted backdrop filters engineered with zero jitter or shaking on click.
- **3D Extruded Neon Push Buttons**: Physical depth extrusion with responsive tactile push animations on touch/click.
- **Futuristic HUD Overlay**: Real-time analog/digital tachometer, speedometer, nitro gauge, minimap radar, and race position telemetry.

---

### 3. 📱 Cross-Platform Responsive UX & Controls
- **Mobile Landscape Orientation Guard**: Custom rotation barrier overlay instructing mobile users to rotate their devices for optimal widescreen racing.
- **Dual Control Schemes**:
  - *Touch Controls*: Responsive on-screen left/right steer buttons, brake pedal, and nitro trigger.
  - *Keyboard & Mouse (Web / Desktop)*: Full WASD / Arrow key controls and spacebar nitro.
- **Responsive Canvas Scaling**: Dynamically adapts from mobile screens (1080p / 1440p) to ultrawide desktop monitors without distortion.

---

### 4. 🌐 Real-Time Multiplayer & Cloud Invitations
- **Dedicated 24/7 Cloud WebSocket Server**: Hosted on **Render** (`wss://apex-velocity-server.onrender.com/ws`), kept permanently active via **UptimeRobot** monitoring.
- **Quick Race Matchmaking**: Jump instantly into public rooms matching live players worldwide with low-latency position syncing.
- **Private Lobbies & 4-Digit Room Codes**: Create private rooms with custom track selections and host start controls.
- **Automated Gmail SMTP Invitations**: Enter a friend's email in the lobby to automatically dispatch a styled HTML email containing the 4-digit room code and direct play links.
- **Smart Peer & Database Fallback**: If network interruptions occur, the game automatically switches to cloud database sync to prevent disconnections.

---

### 5. 🔐 Cross-Platform Google Authentication & Racer Profiles
- **Dedicated Dual OAuth 2.0 Configuration**:
  - **Web Application Client ID**: `638423180265-gsh54ui9q2dqshrtp6ubtc7qo4dt8t2j.apps.googleusercontent.com`
  - **Android / Mobile Client ID**: `638423180265-9iclq3d50de0btf60j03c4cq5v0unnq6.apps.googleusercontent.com`
- **Guest / Instant Play Mode**: Jump into races immediately without mandatory login.
- **Competitive ELO Rating & Stats**: Tracks player ELO (starts at 1000), total races, multiplayer wins, win percentage, and championship trophies.
- **Profile Customization**: Google avatar sync, custom racer callsigns, and trophy showcases.

---

### 6. 🚗 Cyberpunk Garage & Vehicle Customization
- **Multi-Tier Hypercar Roster**:
  - *Phantom GT* (Balanced street racer)
  - *Cyber Spectre* (Ultra-high top speed hypercar)
  - *Viper 2077* (Drift-focused agility vehicle)
  - *Apex Nemesis* (Maximum acceleration dragster)
- **Performance Upgrade System**:
  - Top Speed Tuning
  - Acceleration & Torque Boosters
  - Handling & Downforce Upgrades
  - Nitro Capacity & Burn Rate Tuning
- **Custom Visuals**: Paint color palette selector, custom neon underglow lighting, and rim styles.

---

### 7. 🎵 Procedural Synthesizer Audio Engine
- **Pure Dart 16-Bit 44.1kHz Stereo PCM Synthesizer**: Generates rich retro-futuristic arcade music in real-time without bulky external MP3 files:
  - *Neon Nightdrive* (Deep synthwave menu theme)
  - *Apex Overdrive* (High-octane Phrygian racing metal synth)
- **Dynamic Sound Effects (SFX)**:
  - Adaptive engine RPM pitch modulation based on vehicle speed.
  - Nitro combustion whoosh and boost sounds.
  - Tire screeches during high-angle drifts.
  - Near-miss whoosh and crash impacts.
  - Starting grid countdown beeps and checkered flag victory cheers.

---

### 8. ☁️ Cloud Persistence & Database Architecture
- **Neon Serverless PostgreSQL Database**:
  - `racer_profiles`: Authoritative cloud storage for user stats, ELO, and unlocks.
  - `multiplayer_lobbies`: Live lobby coordination and player slot tracking.
  - `match_records`: Global multiplayer match results, victory logs, and timestamps.
- **Local Persistence (`SharedPreferences`)**: Instant offline fallback saving all garage purchases, wallet credits, and game settings.

---

### 9. 🚀 DevOps, Cloud Infrastructure & Deployments
- **Web CDN Deployment**: Live on **[Netlify](https://apex-velocity-game.netlify.app)** with instant global Edge delivery.
- **Dedicated Backend Container**: Multi-stage native AOT compiled Docker container running 24/7 on **Render**.
- **Android Release Pipeline**: Optimized 55.1 MB release APK with ProGuard resource shrinking and debug certificate verification.
- **Continuous Version Control**: Fully synchronized on **GitHub** ([`sanjai45-m/Solo-car`](https://github.com/sanjai45-m/Solo-car)).

---

## 🔗 Quick Reference Links

| Resource | Link |
| :--- | :--- |
| 🌐 **Live Web Game** | [https://apex-velocity-game.netlify.app](https://apex-velocity-game.netlify.app) |
| 📱 **Android Release APK** | [Download app-release.apk (55.1 MB)](https://tmpfiles.org/dl/wSwYpNgRW8oA/app-release.apk) |
| ⚡ **Live Render Backend** | [https://apex-velocity-server.onrender.com/api/health](https://apex-velocity-server.onrender.com/api/health) |
| 🐙 **GitHub Repository** | [https://github.com/sanjai45-m/Solo-car](https://github.com/sanjai45-m/Solo-car) |
| 🗄️ **Database** | Neon Cloud PostgreSQL (`ep-quiet-grass-a1w13c5j.ap-southeast-1.aws.neon.tech`) |
