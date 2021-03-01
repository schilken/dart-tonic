part of tonic;

/// The canonical abbreviated names of pitch intervals (e.g. P1, P4), indexed by
/// their half-step counts minus one.
final List<String> intervalNames = [
  'P1',
  'm2',
  'M2',
  'm3',
  'M3',
  'P4',
  'TT',
  'P5',
  'm6',
  'M6',
  'm7',
  'M7',
  'P8'
];

/// The canonical long names of pitch intervals (e.g. Unicon, Perfect 4th),
/// indexed by one less than their half-step counts.
final List<String> longIntervalNames = [
  'Unison',
  'Minor 2nd',
  'Major 2nd',
  'Minor 3rd',
  'Major 3rd',
  'Perfect 4th',
  'Tritone',
  'Perfect 5th',
  'Minor 6th',
  'Major 6th',
  'Minor 7th',
  'Major 7th',
  'Octave'
];

/// The interval class (an integer 0 < x < 12) between two pitch class numbers.
int intervalClassDifference(int pca, int pcb) => normalizePitchClass(pcb - pca);

/// An Interval is the signed distance between two notes.
/// Intervals that represent the same semitone span *and* accidental are interned.
/// Thus, two instance of M3 are ===, but sharp P4 and flat P5 are distinct from
/// each other and from TT.
// FIXME these are interval classes, not intervals
class Interval {
  final int number;
  // final int semitones;
  final String qualityName;
  final int qualitySemitones;
  Interval _augmented;
  Interval _diminished;

  static final Map<String, Interval> _cache = <String, Interval>{};

  static final List<int> _semitonesByNumber = [0, 2, 4, 5, 7, 9, 11, 12];
  static bool _numberIsPerfect(int number) => [1, 4, 5, 8].indexOf(number) >= 0;

  factory Interval({int number, String qualityName}) {
    assert(number != null);
    assert(1 <= number && number <= 8);
    var semitones = _semitonesByNumber[number - 1];
    if (semitones == null)
      throw new ArgumentError("invalid interval number: $number");
    if (qualityName == null) qualityName = intervalNames[semitones][0];
    final key = "$qualityName$number";
    if (_cache.containsKey(key)) return _cache[key];
    final qualitySemitones = _numberIsPerfect(number)
        ? "dPA".indexOf(qualityName) - 1
        : "dmMA".indexOf(qualityName) - 2;
    if (qualitySemitones == null)
      throw new ArgumentError("invalid interval quality: $qualityName");
    semitones += qualitySemitones;
    return _cache[key] =
        new Interval._internal(number, qualityName, qualitySemitones);
  }

  Interval._internal(this.number, this.qualityName, this.qualitySemitones);

  factory Interval.fromSemitones(semitones, {int number}) {
    if (semitones < 0 || 12 < semitones) semitones %= 12;
    var interval = Interval.parse(intervalNames[semitones]);
    if (number != null) {
      interval = new Interval(number: number);
      final qs = _numberIsPerfect(number) ? "dPA" : "dmMA";
      final i = semitones - interval.semitones + (qs.length ~/ 2);
      if (!(0 <= i && i < qs.length))
        throw new ArgumentError(
            "can't qualify $interval to $semitones semitone(s)");
      final q = qs[i];
      interval = new Interval(number: number, qualityName: q);
    }
    return interval;
  }

  int get diatonicSemitones => _semitonesByNumber[number - 1];
  int get semitones => diatonicSemitones + qualitySemitones;

  Interval get augmented => _augmented != null
      ? _augmented
      : "mMP".indexOf(qualityName) >= 0
          ? _augmented = new Interval(number: number, qualityName: 'A')
          : throw new ArgumentError("can't augment $this");

  // TODO error if quality is not mMP
  Interval get diminished => _diminished != null
      ? _diminished
      : _diminished = new Interval(number: number, qualityName: 'd');

  static final Pattern _intervalNamePattern =
      new RegExp(r'^(([dmMA][2367])|([dPA][1458])|TT)$');
  static final Pattern _intervalNameParsePattern =
      new RegExp(r'^([dmMPA])(\d)$');

  static parse(String name) {
    if (!name.startsWith(_intervalNamePattern))
      throw new FormatException("No interval named $name");
    if (name == "TT") {
      name = "d5";
    }
    final match = _intervalNameParsePattern.matchAsPrefix(name);
    assert(match != null);
    return new Interval(number: int.parse(match[2]), qualityName: match[1]);
  }

  String toString() => "$qualityName$number";

  String get inspect => {
        'number': number,
        'semitones': semitones,
        'quality': {'name': qualityName, 'value': qualitySemitones}
      }.toString();

  Interval inversion() =>
      new Interval.fromSemitones(12 - semitones, number: 9 - number % 12);

  Interval operator +(Interval other) =>
      new Interval.fromSemitones(semitones + other.semitones,
          number: number + other.number - 1);

  Interval operator -(Interval other) =>
      new Interval.fromSemitones(semitones - other.semitones % 12,
          number: (number - other.number) % 7 + 1);

  /// The perfect unison interval
  static final Interval P1 = Interval.parse('P1');

  /// The minor 2nd interval
  static final Interval m2 = Interval.parse('m2');

  /// The major 2nd interval
  static final Interval M2 = Interval.parse('M2');

  /// The minor 3rd interval
  static final Interval m3 = Interval.parse('m3');

  /// The major 3rd interval
  static final Interval M3 = Interval.parse('M3');

  /// The perfect 4th interval
  static final Interval P4 = Interval.parse('P4');

  /// The tritone interval
  static final Interval TT = Interval.parse('TT');

  /// The perfect 4th interval
  static final Interval P5 = Interval.parse('P5');

  /// The minor 6th interval
  static final Interval m6 = Interval.parse('m6');

  /// The major 6th interval
  static final Interval M6 = Interval.parse('M6');

  /// The minor 7th interval
  static final Interval m7 = Interval.parse('m7');

  /// The major 7th interval
  static final Interval M7 = Interval.parse('M7');

  /// The perfect octave interval
  static final Interval P8 = Interval.parse('P8');

  /// The augmented unison interval
  static final Interval A1 = Interval.P1.augmented;

  /// The augmented 2nd interval
  static final Interval A2 = Interval.M2.augmented;

  /// The augmented 3rd interval
  static final Interval A3 = Interval.M3.augmented;

  /// The augmented 4th interval
  static final Interval A4 = Interval.P4.augmented;

  /// The augmented 5th interval
  static final Interval A5 = Interval.P5.augmented;

  /// The augmented 6th interval
  static final Interval A6 = Interval.M6.augmented;

  /// The augmented 7th interval
  static final Interval A7 = Interval.M7.augmented;

  /// The diminished 2nd interval
  static final Interval d2 = Interval.m2.diminished;

  /// The diminished 3rd interval
  static final Interval d3 = Interval.m3.diminished;

  /// The diminished 4th interval
  static final Interval d4 = Interval.P4.diminished;

  /// The diminished 5th interval
  static final Interval d5 = Interval.P5.diminished;

  /// The diminished 6th interval
  static final Interval d6 = Interval.m6.diminished;

  /// The diminished 7th interval
  static final Interval d7 = Interval.m7.diminished;

  /// The diminished octave interval
  static final Interval d8 = Interval.P8.diminished;
}

// final List Intervals = intervalNames.map((name, semitones) =>
//   new Interval.fromSemitones(semitones)) as List<Interval>;
