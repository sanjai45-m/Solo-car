import 'dart:math';
import 'dart:typed_data';

/// Procedural Audio Synthesizer for Apex Velocity
/// Generates 16-bit 44.1kHz Stereo PCM WAV tracks (Synthwave & Cyberpunk Electro)
class SoundtrackGenerator {
  static const int sampleRate = 44100;
  static const int numChannels = 2;
  static const int bitsPerSample = 16;

  /// Generates a seamless looping Synthwave Menu Theme ("Neon Nightdrive")
  /// Tempo: 124 BPM, Key: D Minor, Length: ~15.5 seconds (32 bars looping)
  static Uint8List generateMenuSoundtrack() {
    return _synthesizeTrack(
      bpm: 124,
      bars: 8,
      isRaceTheme: false,
    );
  }

  /// Generates a high-octane Race Soundtrack ("Apex Overdrive")
  /// Tempo: 140 BPM, Key: E Minor / D Phrygian, Length: ~13.7 seconds (32 bars looping)
  static Uint8List generateRaceSoundtrack() {
    return _synthesizeTrack(
      bpm: 140,
      bars: 8,
      isRaceTheme: true,
    );
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

    // 16-bit stereo buffers (Left & Right channels)
    final Float32List leftBuffer = Float32List(totalSamples);
    final Float32List rightBuffer = Float32List(totalSamples);

    // Musical scale frequencies (D minor: D2, F2, G2, A2, C3, D3, F3, A3, D4)
    final bassNotesMenu = [
      73.42, 73.42, 87.31, 98.00, // D2, D2, F2, G2
      65.41, 65.41, 87.31, 110.00, // C2, C2, F2, A2
    ];

    final leadArpMenu = [
      293.66, 349.23, 440.00, 523.25, 587.33, 523.25, 440.00, 349.23, // D4, F4, A4, C5, D5, C5, A4, F4
      261.63, 329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 329.63, // C4, E4, G4, A4, C5, A4, G4, E4
    ];

    // Race Theme Notes (E Minor / Phrygian 140 BPM)
    final bassNotesRace = [
      82.41, 82.41, 87.31, 98.00, // E2, E2, F2, G2
      73.42, 73.42, 82.41, 110.00, // D2, D2, E2, A2
    ];

    final leadArpRace = [
      329.63, 392.00, 493.88, 587.33, 659.25, 587.33, 493.88, 392.00, // E4, G4, B4, D5, E5, D5, B4, G4
      293.66, 349.23, 440.00, 523.25, 587.33, 523.25, 440.00, 349.23, // D4, F4, A4, C5, D5, C5, A4, F4
    ];

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

      // 1. Kick Drum (Punchy 4-on-the-floor sine sweep)
      final double kickPhase = beatFraction;
      if (kickPhase < 0.25) {
        final double kickFreq = 150.0 * exp(-kickPhase * 24.0) + 45.0;
        final double kickEnv = exp(-kickPhase * 16.0);
        final double kick = sin(2 * pi * kickFreq * kickPhase) * kickEnv * 0.85;
        sampleL += kick;
        sampleR += kick;
      }

      // 2. Snare / Synth Clap on Beats 2 and 4
      if (beatIndex % 2 == 1 && beatFraction < 0.35) {
        final double snareEnv = exp(-beatFraction * 14.0);
        final double noise = (random.nextDouble() * 2.0 - 1.0) * snareEnv * 0.45;
        final double snapTone = sin(2 * pi * 220.0 * beatFraction) * exp(-beatFraction * 28.0) * 0.35;
        sampleL += (noise + snapTone);
        sampleR += (noise + snapTone);
      }

      // 3. Hi-Hat 16th Note Rhythm
      final double hat16thFraction = (currentBeat * 4) % 1.0;
      if (hat16thFraction < 0.12) {
        final double hatEnv = exp(-hat16thFraction * 35.0);
        final double hatNoise = (random.nextDouble() * 2.0 - 1.0) * hatEnv * (isRaceTheme ? 0.22 : 0.16);
        // Stereo panning alternating
        final bool hatPan = ((currentBeat * 4).toInt() % 2 == 0);
        sampleL += hatNoise * (hatPan ? 1.0 : 0.6);
        sampleR += hatNoise * (hatPan ? 0.6 : 1.0);
      }

      // 4. Rolling FM Synth Bassline (16th notes)
      final int bassNoteIdx = ((currentBeat * 2).toInt()) % bassNotes.length;
      final double baseBassFreq = bassNotes[bassNoteIdx];
      final double bass16thPhase = (currentBeat * 4) % 1.0;
      final double bassEnv = exp(-bass16thPhase * (isRaceTheme ? 6.0 : 4.5));
      // Sawtooth + Sub-sine FM modulation
      final double fmMod = sin(2 * pi * (baseBassFreq * 2) * t) * 0.5;
      final double saw = (2.0 * ((t * baseBassFreq + fmMod) % 1.0) - 1.0);
      final double subSine = sin(2 * pi * (baseBassFreq * 0.5) * t);
      final double bass = (saw * 0.5 + subSine * 0.5) * bassEnv * (isRaceTheme ? 0.48 : 0.40);
      sampleL += bass;
      sampleR += bass;

      // 5. Arpeggiated Cyber Synth Lead (8th/16th note pattern with stereo delay)
      final int arpIdx = ((currentBeat * 4).toInt()) % arpNotes.length;
      final double arpFreq = arpNotes[arpIdx];
      final double arpPhase = (currentBeat * 4) % 1.0;
      final double arpEnv = exp(-arpPhase * 5.0);
      final double leadSaw = (2.0 * ((t * arpFreq) % 1.0) - 1.0);
      final double leadSquare = (sin(2 * pi * arpFreq * t) > 0 ? 1.0 : -1.0) * 0.5;
      final double lead = (leadSaw * 0.6 + leadSquare * 0.4) * arpEnv * 0.28;

      // Stereo spread with chorus modulation
      final double chorusL = sin(2 * pi * 0.5 * t) * 0.15;
      final double chorusR = cos(2 * pi * 0.5 * t) * 0.15;
      sampleL += lead * (0.8 + chorusL);
      sampleR += lead * (0.8 + chorusR);

      // 6. Atmospheric Cyber Pad Chords
      final double padFreq1 = bassNotes[0] * 4;
      final double padFreq2 = bassNotes[0] * 6;
      final double padL = (sin(2 * pi * padFreq1 * t) + sin(2 * pi * (padFreq1 * 1.004) * t)) * 0.08;
      final double padR = (sin(2 * pi * padFreq2 * t) + sin(2 * pi * (padFreq2 * 0.996) * t)) * 0.08;
      sampleL += padL;
      sampleR += padR;

      // Smooth loop crossfade at start and end
      double masterFade = 1.0;
      final double fadeSamples = sampleRate * 0.08; // 80ms crossfade
      if (i < fadeSamples) {
        masterFade = i / fadeSamples;
      } else if (i > totalSamples - fadeSamples) {
        masterFade = (totalSamples - i) / fadeSamples;
      }

      leftBuffer[i] = (sampleL * masterFade).clamp(-1.0, 1.0);
      rightBuffer[i] = (sampleR * masterFade).clamp(-1.0, 1.0);
    }

    return _encodeWav(leftBuffer, rightBuffer, sampleRate);
  }

  /// Encodes Float32 stereo audio buffers into a standard RIFF/WAV Byte Array
  static Uint8List _encodeWav(Float32List left, Float32List right, int sampleRate) {
    final int numSamples = left.length;
    final int dataSize = numSamples * numChannels * 2; // 16-bit = 2 bytes per sample
    final int fileSize = 44 + dataSize;

    final Uint8List wavBytes = Uint8List(fileSize);
    final ByteData bd = ByteData.sublistView(wavBytes);

    // RIFF Chunk Descriptor
    bd.setUint8(0, 0x52); // 'R'
    bd.setUint8(1, 0x49); // 'I'
    bd.setUint8(2, 0x46); // 'F'
    bd.setUint8(3, 0x46); // 'F'
    bd.setUint32(4, fileSize - 8, Endian.little);
    bd.setUint8(8, 0x57);  // 'W'
    bd.setUint8(9, 0x41);  // 'A'
    bd.setUint8(10, 0x56); // 'V'
    bd.setUint8(11, 0x45); // 'E'

    // "fmt " Sub-chunk
    bd.setUint8(12, 0x66); // 'f'
    bd.setUint8(13, 0x6D); // 'm'
    bd.setUint8(14, 0x74); // 't'
    bd.setUint8(15, 0x20); // ' '
    bd.setUint32(16, 16, Endian.little); // Subchunk1Size for PCM
    bd.setUint16(20, 1, Endian.little);  // AudioFormat: 1 = PCM
    bd.setUint16(22, numChannels, Endian.little); // NumChannels = 2
    bd.setUint32(24, sampleRate, Endian.little);  // SampleRate = 44100
    bd.setUint32(28, sampleRate * numChannels * 2, Endian.little); // ByteRate
    bd.setUint16(32, numChannels * 2, Endian.little); // BlockAlign
    bd.setUint16(34, bitsPerSample, Endian.little);   // BitsPerSample = 16

    // "data" Sub-chunk
    bd.setUint8(36, 0x64); // 'd'
    bd.setUint8(37, 0x61); // 'a'
    bd.setUint8(38, 0x74); // 't'
    bd.setUint8(39, 0x61); // 'a'
    bd.setUint32(40, dataSize, Endian.little);

    // Write interleaved 16-bit PCM samples
    int offset = 44;
    for (int i = 0; i < numSamples; i++) {
      // Left channel sample (-32768 to 32767)
      final int sampleL = (left[i] * 32767.0).round().clamp(-32768, 32767);
      bd.setInt16(offset, sampleL, Endian.little);
      offset += 2;

      // Right channel sample
      final int sampleR = (right[i] * 32767.0).round().clamp(-32768, 32767);
      bd.setInt16(offset, sampleR, Endian.little);
      offset += 2;
    }

    return wavBytes;
  }
}
