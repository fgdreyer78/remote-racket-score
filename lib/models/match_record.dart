import 'game_config.dart';

/// Evento de ponto individual, usado para reconstruir a sequência da partida.
class PointEvent {
  const PointEvent({
    required this.setNumber,
    required this.gameNumber,
    required this.scorerIsA,
    required this.isTiebreak,
  });

  final int setNumber;
  final int gameNumber;
  final bool scorerIsA;
  final bool isTiebreak;

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'gameNumber': gameNumber,
        'scorerIsA': scorerIsA,
        'isTiebreak': isTiebreak,
      };

  factory PointEvent.fromJson(Map<String, dynamic> json) {
    return PointEvent(
      setNumber: json['setNumber'] as int,
      gameNumber: json['gameNumber'] as int,
      scorerIsA: json['scorerIsA'] as bool,
      isTiebreak: json['isTiebreak'] as bool,
    );
  }
}

/// Registro de uma partida finalizada, incluindo preset e sequência de pontos.
class MatchRecord {
  const MatchRecord({
    required this.id,
    required this.startedAt,
    required this.finishedAt,
    required this.configName,
    required this.playerAName,
    required this.playerBName,
    required this.configSnapshot,
    required this.points,
  });

  final String id;
  final DateTime startedAt;
  final DateTime finishedAt;
  final String configName;
  final String playerAName;
  final String playerBName;
  final GameConfig configSnapshot;
  final List<PointEvent> points;

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'configName': configName,
        'playerAName': playerAName,
        'playerBName': playerBName,
        'configSnapshot': configSnapshot.toJson(),
        'points': points.map((e) => e.toJson()).toList(),
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: DateTime.parse(json['finishedAt'] as String),
      configName: json['configName'] as String,
      playerAName: json['playerAName'] as String,
      playerBName: json['playerBName'] as String,
      configSnapshot:
          GameConfig.fromJson(json['configSnapshot'] as Map<String, dynamic>),
      points: (json['points'] as List<dynamic>)
          .map(
            (e) => PointEvent.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

