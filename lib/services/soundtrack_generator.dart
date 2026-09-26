import 'dart:math';
import 'dart:typed_data';

/// Represents a background soundtrack track with metadata
class GameTrack {
  final String id;
  final String title;
  final String genre;
  final String subtitle;
  final double bpm;

  const GameTrack({
    required this.id,
    required this.title,
    required this.genre,
    required this.subtitle,
    required this.bpm,
  });

  static const List<GameTrack> allTracks = [
    GameTrack(
      id: 'ps2_smackdown_machi',
      title: '2007 SmackDown: Machi Open The Bottle',
      genre: 'Tamil Kuthu Rock & PS2 Arena Fusion',
      subtitle: '🔥 High-Voltage Heavy Rock & Dholak Beats (PS2 Mod Anthem)',
      bpm: 146,
    ),
    GameTrack(
      id: 'aaluma_doluma_overdrive',
      title: 'Aaluma Doluma: Cyber Overdrive',
      genre: 'Chennai Fast Kuthu EDM',
      subtitle: '⚡ Ultra-Fast 150 BPM Chennai Street Gaana Synth',
      bpm: 150,
    ),
    GameTrack(
      id: 'danga_maari_night',
      title: 'Danga Maari: Retro Nightclub',
      genre: 'Tamil Street Gaana & Retro Funk',
      subtitle: '🏎️ Funky Kuthu Bassline & Neon 8-Bit Lead',
      bpm: 142,
    ),
    GameTrack(
      id: 'vaathi_raid_drill',
      title: 'Vaathi Raid: Street King Anthem',
      genre: 'Tamil Cyber Drill & 808 Trap',
      subtitle: '👑 Heavy Sub-Bass Horns & Dark Street Vibe',
      bpm: 138,
    ),
    GameTrack(
      id: 'apex_overdrive',
      title: 'Apex Overdrive: Phrygian Highway',
      genre: 'Arcade Speed Metal Synth',
      subtitle: '🏁 Intense Nitro Racing Lead & Double-Kick Drums',
      bpm: 140,
    ),
    GameTrack(
      id: 'neon_nightdrive',
      title: 'Neon Nightdrive: Midnight Cruise',
      genre: 'Deep Cyberpunk Synthwave',
      subtitle: '🌌 Smooth Retro Pulsing Arpeggios',
      bpm: 124,
    ),
  ];
}

/// Advanced Procedural Audio Synthesizer for Apex Velocity
/// Generates 16-bit 44.1kHz Stereo PCM WAV tracks (Tamil Kuthu Fusion, PS2 SmackDown Rock, Synthwave)
class SoundtrackGenerator {
  static const int sampleRate = 44100;
  static const int numChannels = 2;
  static const int bitsPerSample = 16;

  /// Generate specific track audio buffer by track ID
  static Uint8List generateTrack(String trackId) {
    switch (trackId) {
      case 'ps2_smackdown_machi':
        return _synthesizeSmackdownMachi();
      case 'aaluma_doluma_overdrive':
        return _synthesizeAalumaDoluma();
      case 'danga_maari_night':
        return _synthesizeDangaMaari();
      case 'vaathi_raid_drill':
        return _synthesizeVaathiRaid();
      case 'apex_overdrive':
        return _synthesizeApexOverdrive();
      case 'neon_nightdrive':
      default:
        return _synthesizeNeonNightdrive();
    }
  }

  // ---------------------------------------------------------------------------
  // 1. 2007 PS2 SmackDown: Machi Open The Bottle (Heavy Rock Guitar + Dholak Kuthu)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeSmackdownMachi() {
    const double bpm = 146;
    const int bars = 8;
    final double beatDuration = 60.0 / bpm;
    final double barDuration = beatDuration * 4;
    final double totalSeconds = barDuration * bars;
    final int totalSamples = (totalSeconds * sampleRate).toInt();

    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    // E Minor Power Chords (E2, G2, A2, B2) & Machi hook (E4, G4, A4, B4, D5, B4, A4, G4)
    final bassFrequencies = [82.41, 82.41, 98.00, 110.00, 82.41, 82.41, 123.47, 110.00];
    final leadNotes = [
      329.63, 392.00, 440.00, 493.88, 587.33, 493.88, 440.00, 392.00,
      329.63, 329.63, 392.00, 440.00, 493.88, 440.00, 392.00, 329.63,
    ];

    final random = Random(2007);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double currentBeat = t / beatDuration;
      final int beatIndex = currentBeat.toInt();
      final double beatFraction = currentBeat - beatIndex;

      double sampleL = 0.0;
      double sampleR = 0.0;

      // 1. Heavy Rock Bass & Distorted Power Chord (PS2 WWE SmackDown style)
      final bassFreq = bassFrequencies[beatIndex % bassFrequencies.length];
      final double bassEnv = exp(-beatFraction * 3.5);
      // Hard clipping / distortion waveshaper
      double rawBass = sin(2 * pi * bassFreq * t) + 0.6 * sin(2 * pi * bassFreq * 2 * t) + 0.3 * sin(2 * pi * bassFreq * 3 * t);
      double distBass = (rawBass * 2.8).clamp(-1.0, 1.0) * 0.26 * bassEnv;
      sampleL += distBass;
      sampleR += distBass;

      // 2. Tamil Dholak / Kuthu Beat Pattern (Kick on 1 & 3, syncopated snaps on 1.75, 2.5, 3.5, 4.0)
      final double sixteenth = (currentBeat * 4) % 1.0;
      final int sixteenthIndex = (currentBeat * 4).toInt() % 16;

      // Heavy Kick (Thavil Bass)
      if (sixteenthIndex == 0 || sixteenthIndex == 6 || sixteenthIndex == 8 || sixteenthIndex == 14) {
        final double kickEnv = exp(-sixteenth * 12.0);
        final double kickFreq = 140.0 * exp(-sixteenth * 18.0) + 42.0;
        final double kick = sin(2 * pi * kickFreq * t) * kickEnv * 0.45;
        sampleL += kick;
        sampleR += kick;
      }

      // High Kuthu Snap / Rim (Dholak Treble Snap)
      if (sixteenthIndex == 4 || sixteenthIndex == 10 || sixteenthIndex == 12) {
        final double snapEnv = exp(-sixteenth * 18.0);
        final double snapNoise = (random.nextDouble() * 2 - 1) * snapEnv * 0.28;
        final double snapTone = sin(2 * pi * 880.0 * t) * snapEnv * 0.20;
        sampleL += (snapNoise + snapTone) * 0.9;
        sampleR += (snapNoise + snapTone) * 1.1;
      }

      // Kuthu rapid roll (dhin-tha-kku-dhin)
      if (sixteenthIndex == 3 || sixteenthIndex == 7 || sixteenthIndex == 11 || sixteenthIndex == 15) {
        final double rollEnv = exp(-sixteenth * 24.0);
        final double roll = ((random.nextDouble() * 2 - 1) * 0.12 + sin(2 * pi * 520.0 * t) * 0.15) * rollEnv;
        sampleL += roll;
        sampleR += roll;
      }

      // 3. Catchy Machi Lead Guitar Synth Hook
      final int leadIdx = (currentBeat * 2).toInt() % leadNotes.length;
      final double leadFreq = leadNotes[leadIdx];
      final double leadFrac = (currentBeat * 2) % 1.0;
      final double leadEnv = exp(-leadFrac * 2.8);
      // Lead with stereo chorus
      final double leadL = sin(2 * pi * leadFreq * t) * leadEnv * 0.22;
      final double leadR = sin(2 * pi * (leadFreq * 1.006) * t) * leadEnv * 0.22;
      sampleL += leadL;
      sampleR += leadR;

      _applyLoopFade(leftBuffer, rightBuffer, i, totalSamples, sampleL, sampleR);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  // ---------------------------------------------------------------------------
  // 2. Aaluma Doluma: Cyber Overdrive (150 BPM Ultra-Fast Chennai Kuthu EDM)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeAalumaDoluma() {
    const double bpm = 150;
    const int bars = 8;
    final double beatDuration = 60.0 / bpm;
    final double totalSeconds = beatDuration * 4 * bars;
    final int totalSamples = (totalSeconds * sampleRate).toInt();

    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    // Fast Phrygian dominant hook (C#4, D4, F4, G4, G#4, G4, F4, D4)
    final aalumaNotes = [
      277.18, 293.66, 349.23, 392.00, 415.30, 392.00, 349.23, 293.66,
      277.18, 277.18, 349.23, 415.30, 415.30, 392.00, 349.23, 277.18,
    ];

    final random = Random(45);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double currentBeat = t / beatDuration;
      final int beatIndex = currentBeat.toInt();
      final double beatFraction = currentBeat - beatIndex;

      double sampleL = 0.0;
      double sampleR = 0.0;

      // 1. High-Speed Chennai Kuthu Beat (150 BPM energetic dholak roll)
      final double sixteenth = (currentBeat * 4) % 1.0;
      final int sixteenthIndex = (currentBeat * 4).toInt() % 16;

      // Sub Kick on 0, 4, 8, 12 + syncopated 6 & 14
      if (sixteenthIndex == 0 || sixteenthIndex == 4 || sixteenthIndex == 6 || sixteenthIndex == 8 || sixteenthIndex == 12 || sixteenthIndex == 14) {
        final double kickEnv = exp(-sixteenth * 14.0);
        final double kick = sin(2 * pi * (160.0 * exp(-sixteenth * 22.0) + 48.0) * t) * kickEnv * 0.48;
        sampleL += kick;
        sampleR += kick;
      }

      // Sharp Kuthu Snare / Thaalam Claps (every off-beat)
      if (sixteenthIndex == 2 || sixteenthIndex == 6 || sixteenthIndex == 10 || sixteenthIndex == 14) {
        final double clpEnv = exp(-sixteenth * 20.0);
        final double clp = (random.nextDouble() * 2 - 1) * clpEnv * 0.25;
        sampleL += clp * 1.1;
        sampleR += clp * 0.9;
      }

      // Fast Hi-Hat triplet rolls
      final double hatEnv = exp(-((currentBeat * 8) % 1.0) * 30.0);
      final double hat = (random.nextDouble() * 2 - 1) * hatEnv * 0.10;
      sampleL += hat;
      sampleR += hat;

      // 2. Pulsing Sub Bass (C#2 / 69.30 Hz)
      final double bassEnv = exp(-beatFraction * 4.0);
      final double bass = sin(2 * pi * 69.30 * t) * bassEnv * 0.30;
      sampleL += bass;
      sampleR += bass;

      // 3. Fast Aaluma Synth Horn Lead
      final int noteIdx = (currentBeat * 2).toInt() % aalumaNotes.length;
      final double noteFreq = aalumaNotes[noteIdx];
      final double noteFrac = (currentBeat * 2) % 1.0;
      final double noteEnv = exp(-noteFrac * 3.0);
      final double hornL = (sin(2 * pi * noteFreq * t) + 0.4 * sin(2 * pi * noteFreq * 2 * t)) * noteEnv * 0.24;
      final double hornR = (sin(2 * pi * (noteFreq * 1.004) * t) + 0.4 * sin(2 * pi * (noteFreq * 2.008) * t)) * noteEnv * 0.24;
      sampleL += hornL;
      sampleR += hornR;

      _applyLoopFade(leftBuffer, rightBuffer, i, totalSamples, sampleL, sampleR);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  // ---------------------------------------------------------------------------
  // 3. Danga Maari: Retro Nightclub (142 BPM Groovy Tamil Street Gaana)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeDangaMaari() {
    const double bpm = 142;
    const int bars = 8;
    final double beatDuration = 60.0 / bpm;
    final double totalSeconds = beatDuration * 4 * bars;
    final int totalSamples = (totalSeconds * sampleRate).toInt();

    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    // Danga Maari playful hook (F4, G4, A4, C5, A4, G4, F4, D4)
    final dangaNotes = [
      349.23, 392.00, 440.00, 523.25, 440.00, 392.00, 349.23, 293.66,
      349.23, 349.23, 392.00, 440.00, 523.25, 440.00, 392.00, 349.23,
    ];

    final random = Random(99);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double currentBeat = t / beatDuration;
      final int beatIndex = currentBeat.toInt();
      final double beatFraction = currentBeat - beatIndex;

      double sampleL = 0.0;
      double sampleR = 0.0;

      // 1. Funky Slap Bass (F2 / 87.31 Hz -> D2 / 73.42 Hz)
      final double bassFreq = (beatIndex % 4 < 2) ? 87.31 : 73.42;
      final double bassEnv = exp(-beatFraction * 4.5);
      final double slap = (sin(2 * pi * bassFreq * t) + 0.5 * sin(2 * pi * bassFreq * 2 * t)) * bassEnv * 0.32;
      sampleL += slap;
      sampleR += slap;

      // 2. Groovy Kuthu Dholak Percussion
      final int sixteenthIndex = (currentBeat * 4).toInt() % 16;
      final double sixteenth = (currentBeat * 4) % 1.0;

      if (sixteenthIndex == 0 || sixteenthIndex == 7 || sixteenthIndex == 10 || sixteenthIndex == 12) {
        final double kickEnv = exp(-sixteenth * 13.0);
        final double kick = sin(2 * pi * (150.0 * exp(-sixteenth * 20.0) + 45.0) * t) * kickEnv * 0.44;
        sampleL += kick;
        sampleR += kick;
      }

      if (sixteenthIndex == 4 || sixteenthIndex == 12) {
        final double snareEnv = exp(-sixteenth * 16.0);
        final double snare = (random.nextDouble() * 2 - 1) * snareEnv * 0.24;
        sampleL += snare;
        sampleR += snare;
      }

      // 3. Catchy Retro Neon Lead
      final int noteIdx = (currentBeat * 2).toInt() % dangaNotes.length;
      final double noteFreq = dangaNotes[noteIdx];
      final double noteEnv = exp(-((currentBeat * 2) % 1.0) * 3.2);
      final double lead = sin(2 * pi * noteFreq * t) * noteEnv * 0.22;
      sampleL += lead * 0.9;
      sampleR += lead * 1.1;

      _applyLoopFade(leftBuffer, rightBuffer, i, totalSamples, sampleL, sampleR);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  // ---------------------------------------------------------------------------
  // 4. Vaathi Raid: Street King Anthem (138 BPM Tamil Cyber Drill & 808s)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeVaathiRaid() {
    const double bpm = 138;
    const int bars = 8;
    final double beatDuration = 60.0 / bpm;
    final double totalSeconds = beatDuration * 4 * bars;
    final int totalSamples = (totalSeconds * sampleRate).toInt();

    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    // Minor Phrygian brass riff (G3, G#3, C4, D4, C4, G#3, G3)
    final vaathiNotes = [
      196.00, 207.65, 261.63, 293.66, 261.63, 207.65, 196.00, 196.00,
      196.00, 261.63, 293.66, 311.13, 293.66, 261.63, 207.65, 196.00,
    ];

    final random = Random(2021);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double currentBeat = t / beatDuration;
      final int beatIndex = currentBeat.toInt();
      final double beatFraction = currentBeat - beatIndex;

      double sampleL = 0.0;
      double sampleR = 0.0;

      // 1. Heavy 808 Sub-Bass Slide
      final double subFreq = 48.99 * (1.0 + 0.2 * exp(-beatFraction * 6.0)); // G1 (48.99 Hz)
      final double subEnv = exp(-beatFraction * 2.0);
      final double sub808 = sin(2 * pi * subFreq * t) * subEnv * 0.38;
      sampleL += sub808;
      sampleR += sub808;

      // 2. Drill Snare & Hi-Hats
      final int sixteenthIndex = (currentBeat * 4).toInt() % 16;
      final double sixteenth = (currentBeat * 4) % 1.0;

      if (sixteenthIndex == 0 || sixteenthIndex == 6 || sixteenthIndex == 10) {
        final double kickEnv = exp(-sixteenth * 18.0);
        final double kick = sin(2 * pi * 130.0 * exp(-sixteenth * 25.0) * t) * kickEnv * 0.40;
        sampleL += kick;
        sampleR += kick;
      }

      if (sixteenthIndex == 8) {
        final double rimEnv = exp(-sixteenth * 18.0);
        final double rim = (random.nextDouble() * 2 - 1) * rimEnv * 0.28;
        sampleL += rim;
        sampleR += rim;
      }

      // Fast rolling hi-hats
      final double hatEnv = exp(-((currentBeat * 6) % 1.0) * 25.0);
      final double hat = (random.nextDouble() * 2 - 1) * hatEnv * 0.08;
      sampleL += hat;
      sampleR += hat;

      // 3. Dark Vaathi Brass Horn Stabs
      final int noteIdx = (currentBeat * 2).toInt() % vaathiNotes.length;
      final double noteFreq = vaathiNotes[noteIdx];
      final double noteFrac = (currentBeat * 2) % 1.0;
      final double hornEnv = exp(-noteFrac * 2.5);
      final double brassL = (sin(2 * pi * noteFreq * t) + 0.6 * sin(2 * pi * noteFreq * 2 * t) + 0.3 * sin(2 * pi * noteFreq * 3 * t)) * hornEnv * 0.22;
      final double brassR = (sin(2 * pi * (noteFreq * 1.005) * t) + 0.6 * sin(2 * pi * (noteFreq * 2.01) * t) + 0.3 * sin(2 * pi * (noteFreq * 3.015) * t)) * hornEnv * 0.22;
      sampleL += brassL;
      sampleR += brassR;

      _applyLoopFade(leftBuffer, rightBuffer, i, totalSamples, sampleL, sampleR);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  // ---------------------------------------------------------------------------
  // 5. Apex Overdrive: Phrygian Highway (140 BPM Speed Racing Metal Synth)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeApexOverdrive() {
    return _synthesizeTrack(bpm: 140, bars: 8, isRaceTheme: true);
  }

  // ---------------------------------------------------------------------------
  // 6. Neon Nightdrive: Midnight Cruise (124 BPM Retro Synthwave)
  // ---------------------------------------------------------------------------
  static Uint8List _synthesizeNeonNightdrive() {
    return _synthesizeTrack(bpm: 124, bars: 8, isRaceTheme: false);
  }

  static Uint8List _synthesizeTrack({
    required double bpm,
    required int bars,
    required bool isRaceTheme,
  }) {
    final double beatDuration = 60.0 / bpm;
    final double barDuration = beatDuration * 4;
    final double totalSeconds = barDuration * bars;
    final int totalSamples = (totalSeconds * sampleRate).toInt();

    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    final bassNotesMenu = [73.42, 73.42, 87.31, 98.00, 65.41, 65.41, 87.31, 110.00];
    final leadArpMenu = [293.66, 349.23, 440.00, 523.25, 587.33, 523.25, 440.00, 349.23];
    final bassNotesRace = [82.41, 82.41, 87.31, 98.00, 73.42, 73.42, 82.41, 110.00];
    final leadArpRace = [329.63, 392.00, 493.88, 587.33, 659.25, 587.33, 493.88, 392.00];

    final bassNotes = isRaceTheme ? bassNotesRace : bassNotesMenu;
    final arpNotes = isRaceTheme ? leadArpRace : leadArpMenu;
    final random = Random(42);

    for (int i = 0; i < totalSamples; i++) {
      final double t = i / sampleRate;
      final double currentBeat = t / beatDuration;
      final int beatIndex = currentBeat.toInt();
      final double beatFraction = currentBeat - beatIndex;

      double sampleL = 0.0;
      double sampleR = 0.0;

      // Bass Kick on 1, 2, 3, 4
      final double kickEnv = exp(-beatFraction * 14.0);
      final double kick = sin(2 * pi * (140.0 * exp(-beatFraction * 20.0) + 45.0) * t) * kickEnv * 0.42;
      sampleL += kick;
      sampleR += kick;

      // Snare on 2 & 4
      if (beatIndex % 2 == 1) {
        final double snareEnv = exp(-beatFraction * 12.0);
        final double snareNoise = (random.nextDouble() * 2 - 1) * snareEnv * 0.22;
        sampleL += snareNoise;
        sampleR += snareNoise;
      }

      // Synth Bass
      final bassFreq = bassNotes[beatIndex % bassNotes.length];
      final double bassEnv = exp(-beatFraction * 3.8);
      final double bass = sin(2 * pi * bassFreq * t) * bassEnv * 0.28;
      sampleL += bass;
      sampleR += bass;

      // Arpeggio Lead
      final int arpIdx = (currentBeat * 4).toInt() % arpNotes.length;
      final double arpFreq = arpNotes[arpIdx];
      final double arpEnv = exp(-((currentBeat * 4) % 1.0) * 4.0);
      final double arpL = sin(2 * pi * arpFreq * t) * arpEnv * 0.18;
      final double arpR = sin(2 * pi * (arpFreq * 1.005) * t) * arpEnv * 0.18;
      sampleL += arpL;
      sampleR += arpR;

      _applyLoopFade(leftBuffer, rightBuffer, i, totalSamples, sampleL, sampleR);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  static void _applyLoopFade(Float32List leftBuffer, Float32List rightBuffer, int i, int totalSamples, double sampleL, double sampleR) {
    double masterFade = 1.0;
    final double fadeSamples = sampleRate * 0.08;
    if (i < fadeSamples) {
      masterFade = i / fadeSamples;
    } else if (i > totalSamples - fadeSamples) {
      masterFade = (totalSamples - i) / fadeSamples;
    }
    leftBuffer[i] = (sampleL * masterFade).clamp(-1.0, 1.0);
    rightBuffer[i] = (sampleR * masterFade).clamp(-1.0, 1.0);
  }

  /// Encodes Float32 stereo audio buffers into standard RIFF/WAV Byte Array
  static Uint8List _encodeWav(Float32List left, Float32List right, int sampleRate) {
    final int numSamples = left.length;
    final int dataSize = numSamples * numChannels * 2;
    final int fileSize = 44 + dataSize;

    final Uint8List wavBytes = Uint8List(fileSize);
    final ByteData bd = ByteData.sublistView(wavBytes);

    bd.setUint8(0, 0x52); bd.setUint8(1, 0x49); bd.setUint8(2, 0x46); bd.setUint8(3, 0x46);
    bd.setUint32(4, fileSize - 8, Endian.little);
    bd.setUint8(8, 0x57); bd.setUint8(9, 0x41); bd.setUint8(10, 0x56); bd.setUint8(11, 0x45);
    bd.setUint8(12, 0x66); bd.setUint8(13, 0x6D); bd.setUint8(14, 0x74); bd.setUint8(15, 0x20);
    bd.setUint32(16, 16, Endian.little);
    bd.setUint16(20, 1, Endian.little);
    bd.setUint16(22, numChannels, Endian.little);
    bd.setUint32(24, sampleRate, Endian.little);
    bd.setUint32(28, sampleRate * numChannels * 2, Endian.little);
    bd.setUint16(32, numChannels * 2, Endian.little);
    bd.setUint16(34, bitsPerSample, Endian.little);
    bd.setUint8(36, 0x64); bd.setUint8(37, 0x61); bd.setUint8(38, 0x74); bd.setUint8(39, 0x61);
    bd.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      final int sampleL = (left[i] * 32767.0).round().clamp(-32768, 32767);
      bd.setInt16(offset, sampleL, Endian.little);
      offset += 2;
      final int sampleR = (right[i] * 32767.0).round().clamp(-32768, 32767);
      bd.setInt16(offset, sampleR, Endian.little);
      offset += 2;
    }

    return wavBytes;
  }
}
