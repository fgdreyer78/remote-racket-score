enum MappedAction { pointA, pointB, undo }

MappedAction? _actionFromString(String? val) {
  if (val == null) return null;
  for (final action in MappedAction.values) {
    if (action.name == val) return action;
  }
  return null;
}

class ButtonMapping {
  const ButtonMapping({
    this.pointAKeyId,
    this.pointBKeyId,
    this.undoKeyId,
    this.doubleClickActionA,
    this.doubleClickActionB,
    this.doubleClickActionUndo,
    this.tripleClickActionA,
    this.tripleClickActionB,
    this.tripleClickActionUndo,
  });

  final int? pointAKeyId;
  final int? pointBKeyId;
  final int? undoKeyId;

  final MappedAction? doubleClickActionA;
  final MappedAction? doubleClickActionB;
  final MappedAction? doubleClickActionUndo;

  final MappedAction? tripleClickActionA;
  final MappedAction? tripleClickActionB;
  final MappedAction? tripleClickActionUndo;

  ButtonMapping copyWith({
    int? pointAKeyId,
    int? pointBKeyId,
    int? undoKeyId,
    MappedAction? doubleClickActionA,
    MappedAction? doubleClickActionB,
    MappedAction? doubleClickActionUndo,
    MappedAction? tripleClickActionA,
    MappedAction? tripleClickActionB,
    MappedAction? tripleClickActionUndo,
  }) {
    return ButtonMapping(
      pointAKeyId: pointAKeyId ?? this.pointAKeyId,
      pointBKeyId: pointBKeyId ?? this.pointBKeyId,
      undoKeyId: undoKeyId ?? this.undoKeyId,
      doubleClickActionA: doubleClickActionA ?? this.doubleClickActionA,
      doubleClickActionB: doubleClickActionB ?? this.doubleClickActionB,
      doubleClickActionUndo: doubleClickActionUndo ?? this.doubleClickActionUndo,
      tripleClickActionA: tripleClickActionA ?? this.tripleClickActionA,
      tripleClickActionB: tripleClickActionB ?? this.tripleClickActionB,
      tripleClickActionUndo: tripleClickActionUndo ?? this.tripleClickActionUndo,
    );
  }

  factory ButtonMapping.fromJson(Map<String, dynamic> json) {
    return ButtonMapping(
      pointAKeyId: json['pointAKeyId'] as int?,
      pointBKeyId: json['pointBKeyId'] as int?,
      undoKeyId: json['undoKeyId'] as int?,
      doubleClickActionA: _actionFromString(json['doubleClickActionA'] as String?),
      doubleClickActionB: _actionFromString(json['doubleClickActionB'] as String?),
      doubleClickActionUndo: _actionFromString(json['doubleClickActionUndo'] as String?),
      tripleClickActionA: _actionFromString(json['tripleClickActionA'] as String?),
      tripleClickActionB: _actionFromString(json['tripleClickActionB'] as String?),
      tripleClickActionUndo: _actionFromString(json['tripleClickActionUndo'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
        'pointAKeyId': pointAKeyId,
        'pointBKeyId': pointBKeyId,
        'undoKeyId': undoKeyId,
        'doubleClickActionA': doubleClickActionA?.name,
        'doubleClickActionB': doubleClickActionB?.name,
        'doubleClickActionUndo': doubleClickActionUndo?.name,
        'tripleClickActionA': tripleClickActionA?.name,
        'tripleClickActionB': tripleClickActionB?.name,
        'tripleClickActionUndo': tripleClickActionUndo?.name,
      };
}