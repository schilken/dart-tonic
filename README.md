# Dart

[![Build Status](https://travis-ci.org/osteele/dart-tonic.svg?branch=master)](https://travis-ci.org/osteele/dart-tonic)

Tonic is a [Dart](https://www.dartlang.org) package that models components of music theory.

It also computes chord diagrams; this functionality is in progress.
(I'm porting it from [schoen](https://github.com/osteele/schoen).)

## Installing via Pub

The current version of this package requires Dart 2.0. Use [version
0.1.1](https://github.com/osteele/dart-tonic/tree/v0.0.1) with Dart 1.x.

Add the following to your `pubspec.yaml`, and run `pub get`.

```yaml
dependencies:
  tonic: any
```

## Example Usage

```dart
  import 'package:tonic/tonic.dart';

  main() {
    // Hemholtz and Scientific pitch notation
    print(Pitch.parse('C4'));
    print(Pitch.parse('C♯4'));
    print(Pitch.parse('C♭4'));

    // Unicode and ASCII sharps and flats
    print(Pitch.parse('C#4') == Pitch.parse('C#4')); // => true
    print(Pitch.parse('Cb4') == Pitch.parse('Cb4')); // => true

    // Enharmonic equivalents
    print(Pitch.parse('E♯4').midiNumber == Pitch.parse('F4').midiNumber); // => true
    print(Pitch.parse('E4').midiNumber == Pitch.parse('F♭4').midiNumber); // => true
    print(Pitch.parse('E♯4') == Pitch.parse('F4')); // => false
    print(Pitch.parse('E4') == Pitch.parse('F♭4')); // => false

    print(Pitch.parse('C4').octave); // => 5
    print(Pitch.parse('C4').midiNumber); // => 60
    print(new Pitch.fromMidiNumber(60)); // => C4

    // Intervals
    print(Interval.M3);
    print(Interval.parse('M3'));
    print(Interval.m3.semitones); // => 3
    print(Interval.M3.semitones); // => 4
    print(Interval.A3.semitones); // => 5
    print(Interval.d4.semitones); // => 4
    print(Interval.P4.semitones); // => 5
    print(Interval.A4.semitones); // => 6
    print(Interval.M3.number); // => 3
    print(Interval.M3.qualityName); // => "M"

    // Interval arithmetic
    print(Interval.M3 + Interval.m3); // => P5
    print(Interval.m3 + Interval.M3); // => P5
    print(Interval.m3 + Interval.m3); // => d5
    print(Interval.M3 + Interval.M3); // => A5

    print(Pitch.parse('C4') + Interval.M3); // => E4
    print(Pitch.parse('C4') + Interval.A3); // => E♯4
    print(Pitch.parse('C4') + Interval.d4); // => F♭4
    print(Pitch.parse('C4') + Interval.P4); // => F4

    print(Pitch.parse('C4') - Pitch.parse('C4'));   // => P1
    print(Pitch.parse('D4') - Pitch.parse('C4'));   // => M2
    print(Pitch.parse('E4') - Pitch.parse('C4'));   // => M3
    print(Pitch.parse('E♯4') - Pitch.parse('C4')); // => A3
    print(Pitch.parse('F♭4') - Pitch.parse('C4')); // => d4
    print(Pitch.parse('F4') - Pitch.parse('C4'));  // => P4

    // Chords
    print(Chord.parse('E Major'));
    print(ChordPattern.parse('Dominant 7th')); // => Dom 7th
    print(ChordPattern.fromIntervals([Interval.P1, Interval.M3, Interval.P5])); // => Major
    print(ChordPattern.fromIntervals([Interval.P1, Interval.m3, Interval.P5])); // => Minor
    print(ChordPattern.fromIntervals([Interval.P1, Interval.m3, Interval.P5, Interval.m7])); // => Min 7th

    // Scales
    final scalePattern = ScalePattern.findByName('Diatonic Major');
    print(scalePattern.intervals); // => [P1, M2, M3, P4, P5, M6, M7]
    print(scalePattern.modes);
    print(scalePattern.modes['Dorian'].intervals); // => [P1, M2, m3, P4, P5, M6, m7]

    final scale = scalePattern.at(Pitch.parse('E4'));
    print(scale.intervals); // => [P1, M2, M3, P4, P5, M6, M7]
    print(scale.pitchClasses); // => [E4, F♯4, G♯4, A4, B4, C♯5, D♯5]

    // Instruments and fret fingerings
    final chord = Chord.parse('E Major');
    final instrument = Instrument.Guitar;
    print(bestFrettingFor(chord, instrument)); // => 022100
  }
```

More examples can be found in the tests in `test/*_test.dart`.

## License

MIT
