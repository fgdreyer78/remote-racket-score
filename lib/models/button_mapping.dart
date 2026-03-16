/// Mapeamento: qual KeyCode (physicalKey usbHidId) executa qual ação.
class ButtonMapping {
  const ButtonMapping({
    this.pointAKeyId,
    this.pointBKeyId,
    this.undoKeyId,
  });

  final int? pointAKeyId;
  final int? pointBKeyId;
  final int? undoKeyId;

  ButtonMapping copyWith({
    int? pointAKeyId,
    int? pointBKeyId,
    int? undoKeyId,
  }) {
    return ButtonMapping(
      pointAKeyId: pointAKeyId ?? this.pointAKeyId,
      pointBKeyId: pointBKeyId ?? this.pointBKeyId,
      undoKeyId: undoKeyId ?? this.undoKeyId,
    );
  }

  Map<String, dynamic> toJson() => {
        'pointAKeyId': pointAKeyId,
        'pointBKeyId': pointBKeyId,
        'undoKeyId': undoKeyId,
      };

  factory ButtonMapping.fromJson(Map<String, dynamic> json) {
    return ButtonMapping(
      pointAKeyId: json['pointAKeyId'] as int?,
      pointBKeyId: json['pointBKeyId'] as int?,
      undoKeyId: json['undoKeyId'] as int?,
    );
  }
}

enum MappedAction { pointA, pointB, undo }
