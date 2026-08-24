import 'game_config.dart';
import 'score_state.dart';

/// Registro de uma partida em andamento que foi salva ao sair do placar.
class OngoingMatch {
  const OngoingMatch({
    required this.id,
    required this.playerAName,
    required this.playerBName,
    required this.configSnapshot,
    required this.scoreState,
    required this.startedAt,
    required this.lastPointAt,
  });

  final String id;
  final String playerAName;
  final String playerBName;
  final GameConfig configSnapshot;
  final ScoreState scoreState;
  final DateTime startedAt;
  final DateTime lastPointAt;

  /// Resumo do placar para exibição na lista.
  String get scoreSummary {
    final sets = '$setsA-$setsB';
    if (scoreState.isTiebreak) {
      return 'Sets: $sets | Tiebreak: ${scoreState.tiebreakPointsA}-${scoreState.tiebreakPointsB}';
    }
    final games = '$gamesA-$gamesB';
    if (gamesA == 0 && gamesB == 0) {
      return 'Sets: $sets';
    }
    return 'Sets: $sets | Games: $games';
  }

  int get setsA => scoreState.setsA;
  int get setsB => scoreState.setsB;
  int get gamesA => scoreState.gamesA;
  int get gamesB => scoreState.gamesB;

  Map<String, dynamic> toJson() => {
        'id': id,
        'playerAName': playerAName,
        'playerBName': playerBName,
        'configSnapshot': configSnapshot.toJson(),
        'scoreState': scoreState.toJson(),
        'startedAt': startedAt.toIso8601String(),
        'lastPointAt': lastPointAt.toIso8601String(),
      };

  factory OngoingMatch.fromJson(Map<String, dynamic> json) {
    return OngoingMatch(
      id: json['id'] as String,
      playerAName: json['playerAName'] as String,
      playerBName: json['playerBName'] as String,
      configSnapshot:
          GameConfig.fromJson(json['configSnapshot'] as Map<String, dynamic>),
      scoreState:
          ScoreState.fromJson(json['scoreState'] as Map<String, dynamic>),
      startedAt: DateTime.parse(json['startedAt'] as String),
      lastPointAt: DateTime.parse(json['lastPointAt'] as String),
    );
  }
}
