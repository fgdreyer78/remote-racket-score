enum MappedAction { pointA, pointB, undo, none }

MappedAction? _actionFromString(String? val) {
  if (val == null) return null;
  for (final action in MappedAction.values) {
    if (action.name == val) return action;
  }
  return null;
}

class ButtonMapping {
  const ButtonMapping({
    // --- VOLUME / SHUTTER ---
    this.enableVolume = false,
    this.volUpAction = MappedAction.pointA,
    this.volUpDouble = MappedAction.none,
    this.volUpTriple = MappedAction.none,
    this.volDownAction = MappedAction.pointB,
    this.volDownDouble = MappedAction.none,
    this.volDownTriple = MappedAction.none,
    this.volumeDelayMs = 400,
    this.volumeMinIntervalMs = 0,

    // --- MÍDIA ---
    this.enableMedia = true,
    this.mediaNextAction = MappedAction.pointA,
    this.mediaPrevAction = MappedAction.pointB,
    this.mediaPlayAction = MappedAction.undo,
    this.mediaMinIntervalMs = 0,

    // --- TECLADO ---
    this.enableKeyboard = true,
    this.keyA,
    this.keyB,
    this.keyUndo,
    this.keyDoubleA = MappedAction.none,
    this.keyDoubleB = MappedAction.none,
    this.keyDoubleUndo = MappedAction.none,
    this.keyTripleA = MappedAction.none,
    this.keyTripleB = MappedAction.none,
    this.keyTripleUndo = MappedAction.none,
    this.keyboardDelayMs = 400,
    this.keyboardMinIntervalMs = 0,
  });

  final bool enableVolume;
  final MappedAction volUpAction;
  final MappedAction volUpDouble;
  final MappedAction volUpTriple;
  final MappedAction volDownAction;
  final MappedAction volDownDouble;
  final MappedAction volDownTriple;
  final int volumeDelayMs;
  /// Tempo mínimo (ms) entre o disparo de um ponto e o próximo aceito (anti-duplicata)
  final int volumeMinIntervalMs;

  final bool enableMedia;
  final MappedAction mediaNextAction;
  final MappedAction mediaPrevAction;
  final MappedAction mediaPlayAction;
  /// Tempo mínimo (ms) entre o disparo de um ponto e o próximo aceito (anti-duplicata)
  final int mediaMinIntervalMs;

  final bool enableKeyboard;
  final int? keyA;
  final int? keyB;
  final int? keyUndo;
  final MappedAction keyDoubleA;
  final MappedAction keyDoubleB;
  final MappedAction keyDoubleUndo;
  final MappedAction keyTripleA;
  final MappedAction keyTripleB;
  final MappedAction keyTripleUndo;
  final int keyboardDelayMs;
  /// Tempo mínimo (ms) entre o disparo de um ponto e o próximo aceito (anti-duplicata)
  final int keyboardMinIntervalMs;

  ButtonMapping copyWith({
    bool? enableVolume, MappedAction? volUpAction, MappedAction? volUpDouble, MappedAction? volUpTriple, MappedAction? volDownAction, MappedAction? volDownDouble, MappedAction? volDownTriple, int? volumeDelayMs, int? volumeMinIntervalMs,
    bool? enableMedia, MappedAction? mediaNextAction, MappedAction? mediaPrevAction, MappedAction? mediaPlayAction, int? mediaMinIntervalMs,
    bool? enableKeyboard, int? keyA, int? keyB, int? keyUndo, MappedAction? keyDoubleA, MappedAction? keyDoubleB, MappedAction? keyDoubleUndo, MappedAction? keyTripleA, MappedAction? keyTripleB, MappedAction? keyTripleUndo, int? keyboardDelayMs, int? keyboardMinIntervalMs,
  }) {
    return ButtonMapping(
      enableVolume: enableVolume ?? this.enableVolume,
      volUpAction: volUpAction ?? this.volUpAction, volUpDouble: volUpDouble ?? this.volUpDouble, volUpTriple: volUpTriple ?? this.volUpTriple,
      volDownAction: volDownAction ?? this.volDownAction, volDownDouble: volDownDouble ?? this.volDownDouble, volDownTriple: volDownTriple ?? this.volDownTriple,
      volumeDelayMs: volumeDelayMs ?? this.volumeDelayMs,
      volumeMinIntervalMs: volumeMinIntervalMs ?? this.volumeMinIntervalMs,

      enableMedia: enableMedia ?? this.enableMedia,
      mediaNextAction: mediaNextAction ?? this.mediaNextAction, mediaPrevAction: mediaPrevAction ?? this.mediaPrevAction, mediaPlayAction: mediaPlayAction ?? this.mediaPlayAction,
      mediaMinIntervalMs: mediaMinIntervalMs ?? this.mediaMinIntervalMs,

      enableKeyboard: enableKeyboard ?? this.enableKeyboard,
      keyA: keyA ?? this.keyA, keyB: keyB ?? this.keyB, keyUndo: keyUndo ?? this.keyUndo,
      keyDoubleA: keyDoubleA ?? this.keyDoubleA, keyDoubleB: keyDoubleB ?? this.keyDoubleB, keyDoubleUndo: keyDoubleUndo ?? this.keyDoubleUndo,
      keyTripleA: keyTripleA ?? this.keyTripleA, keyTripleB: keyTripleB ?? this.keyTripleB, keyTripleUndo: keyTripleUndo ?? this.keyTripleUndo,
      keyboardDelayMs: keyboardDelayMs ?? this.keyboardDelayMs,
      keyboardMinIntervalMs: keyboardMinIntervalMs ?? this.keyboardMinIntervalMs,
    );
  }

  factory ButtonMapping.fromJson(Map<String, dynamic> json) {
    return ButtonMapping(
      enableVolume: json['enableVolume'] as bool? ?? false,
      volUpAction: _actionFromString(json['volUpAction'] as String?) ?? MappedAction.pointA,
      volUpDouble: _actionFromString(json['volUpDouble'] as String?) ?? MappedAction.none,
      volUpTriple: _actionFromString(json['volUpTriple'] as String?) ?? MappedAction.none,
      volDownAction: _actionFromString(json['volDownAction'] as String?) ?? MappedAction.pointB,
      volDownDouble: _actionFromString(json['volDownDouble'] as String?) ?? MappedAction.none,
      volDownTriple: _actionFromString(json['volDownTriple'] as String?) ?? MappedAction.none,
      volumeDelayMs: json['volumeDelayMs'] as int? ?? 400,
      volumeMinIntervalMs: json['volumeMinIntervalMs'] as int? ?? 0,

      enableMedia: json['enableMedia'] as bool? ?? true,
      mediaNextAction: _actionFromString(json['mediaNextAction'] as String?) ?? MappedAction.pointA,
      mediaPrevAction: _actionFromString(json['mediaPrevAction'] as String?) ?? MappedAction.pointB,
      mediaPlayAction: _actionFromString(json['mediaPlayAction'] as String?) ?? MappedAction.undo,
      mediaMinIntervalMs: json['mediaMinIntervalMs'] as int? ?? 0,

      enableKeyboard: json['enableKeyboard'] as bool? ?? true,
      keyA: json['keyA'] as int?, keyB: json['keyB'] as int?, keyUndo: json['keyUndo'] as int?,
      keyDoubleA: _actionFromString(json['keyDoubleA'] as String?) ?? MappedAction.none,
      keyDoubleB: _actionFromString(json['keyDoubleB'] as String?) ?? MappedAction.none,
      keyDoubleUndo: _actionFromString(json['keyDoubleUndo'] as String?) ?? MappedAction.none,
      keyTripleA: _actionFromString(json['keyTripleA'] as String?) ?? MappedAction.none,
      keyTripleB: _actionFromString(json['keyTripleB'] as String?) ?? MappedAction.none,
      keyTripleUndo: _actionFromString(json['keyTripleUndo'] as String?) ?? MappedAction.none,
      keyboardDelayMs: json['keyboardDelayMs'] as int? ?? 400,
      keyboardMinIntervalMs: json['keyboardMinIntervalMs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'enableVolume': enableVolume, 'volUpAction': volUpAction.name, 'volUpDouble': volUpDouble.name, 'volUpTriple': volUpTriple.name, 'volDownAction': volDownAction.name, 'volDownDouble': volDownDouble.name, 'volDownTriple': volDownTriple.name, 'volumeDelayMs': volumeDelayMs, 'volumeMinIntervalMs': volumeMinIntervalMs,
        'enableMedia': enableMedia, 'mediaNextAction': mediaNextAction.name, 'mediaPrevAction': mediaPrevAction.name, 'mediaPlayAction': mediaPlayAction.name, 'mediaMinIntervalMs': mediaMinIntervalMs,
        'enableKeyboard': enableKeyboard, 'keyA': keyA, 'keyB': keyB, 'keyUndo': keyUndo, 'keyDoubleA': keyDoubleA.name, 'keyDoubleB': keyDoubleB.name, 'keyDoubleUndo': keyDoubleUndo.name, 'keyTripleA': keyTripleA.name, 'keyTripleB': keyTripleB.name, 'keyTripleUndo': keyTripleUndo.name, 'keyboardDelayMs': keyboardDelayMs, 'keyboardMinIntervalMs': keyboardMinIntervalMs,
      };
}
