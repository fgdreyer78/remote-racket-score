import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_theme.dart';
import '../../models/match_record.dart';

class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.record});

  final MatchRecord record;

  @override
  Widget build(BuildContext context) {
    final stats = _computeStats();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          '${record.playerAName} vs ${record.playerBName}',
          style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.primary),
            tooltip: 'Compartilhar',
            onPressed: () => _shareMatch(stats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cabeçalho
          _buildHeader(stats),
          const SizedBox(height: 24),

          // Placar final
          _buildFinalScore(stats),
          const SizedBox(height: 24),

          // Estatísticas gerais
          _buildGeneralStats(stats),
          const SizedBox(height: 24),

          // Break points
          _buildBreakPoints(stats),
          const SizedBox(height: 24),

          // Sequência de pontos por game
          _buildPointSequence(stats),
        ],
      ),
    );
  }

  _MatchStats _computeStats() {
    final points = record.points;

    int setsA = 0, setsB = 0;
    int gamesA = 0, gamesB = 0;
    int setGamesA = 0, setGamesB = 0;
    int totalPointsA = 0, totalPointsB = 0;

    // Break points
    int breakPointsFacedA = 0;
    int breakPointsFacedB = 0;

    // Games por set
    final List<int> setGamesListA = [];
    final List<int> setGamesListB = [];

    // Sequência de pontos por game
    final List<_GameResult> gameResults = [];

    int currentGamePointsA = 0;
    int currentGamePointsB = 0;
    bool currentServerIsA = true;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isTiebreak = p.isTiebreak;

      if (p.scorerIsA) {
        totalPointsA++;
        if (!isTiebreak) {
          currentGamePointsA++;
        }
      } else {
        totalPointsB++;
        if (!isTiebreak) {
          currentGamePointsB++;
        }
      }

      // Verificar se o game mudou (próximo evento é de set diferente ou game diferente)
      final nextPoint = i + 1 < points.length ? points[i + 1] : null;
      final gameChanged = nextPoint == null ||
          nextPoint.setNumber != p.setNumber ||
          nextPoint.gameNumber != p.gameNumber;

      if (gameChanged) {
        // Game acabou - registrar resultado
        final gameWinnerIsA = p.scorerIsA;
        final wasServiceGame = gameWinnerIsA == currentServerIsA;
        final wasBreak = !wasServiceGame;

        if (!isTiebreak) {
          gameResults.add(_GameResult(
            setNumber: p.setNumber,
            gameNumber: p.gameNumber,
            winnerIsA: gameWinnerIsA,
            wasBreak: wasBreak,
            serverIsA: currentServerIsA,
            pointsA: currentGamePointsA,
            pointsB: currentGamePointsB,
          ));

          // Break points: se o game foi de break, o servidor enfrentou break points
          if (wasBreak) {
            if (currentServerIsA) {
              breakPointsFacedA++;
            } else {
              breakPointsFacedB++;
            }
          }
        }

        currentGamePointsA = 0;
        currentGamePointsB = 0;

        // Detectar mudança de set
        if (nextPoint == null || nextPoint.setNumber != p.setNumber) {
          setGamesListA.add(setGamesA);
          setGamesListB.add(setGamesB);
          if (setGamesA > setGamesB) {
            setsA++;
          } else if (setGamesB > setGamesA) {
            setsB++;
          }
          setGamesA = 0;
          setGamesB = 0;
        }

        // Incrementar games
        if (gameWinnerIsA) {
          setGamesA++;
          gamesA++;
        } else {
          setGamesB++;
          gamesB++;
        }
      }
    }

    // Último set pode não ter sido contado
    if (setGamesA > 0 || setGamesB > 0) {
      setGamesListA.add(setGamesA);
      setGamesListB.add(setGamesB);
      if (setGamesA > setGamesB)
        setsA++;
      else if (setGamesB > setGamesA) setsB++;
    }

    return _MatchStats(
      record: record,
      setsA: setsA,
      setsB: setsB,
      gamesA: gamesA,
      gamesB: gamesB,
      totalPointsA: totalPointsA,
      totalPointsB: totalPointsB,
      breakPointsFacedA: breakPointsFacedA,
      breakPointsFacedB: breakPointsFacedB,
      setGamesA: setGamesListA,
      setGamesB: setGamesListB,
      gameResults: gameResults,
    );
  }

  Widget _buildHeader(_MatchStats stats) {
    final duration = stats.record.finishedAt.difference(stats.record.startedAt);
    final min = duration.inMinutes;
    final h = duration.inHours;
    final m = min.remainder(60);
    final durationStr = h > 0 ? '${h}h ${m}min' : '${min} min';

    final d = stats.record.startedAt.day.toString().padLeft(2, '0');
    final mo = stats.record.startedAt.month.toString().padLeft(2, '0');
    final y = stats.record.startedAt.year;
    final hh = stats.record.startedAt.hour.toString().padLeft(2, '0');
    final mm = stats.record.startedAt.minute.toString().padLeft(2, '0');

    return Card(
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$d/$mo/$y  $hh:$mm',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              stats.record.configName,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Duração: $durationStr',
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalScore(_MatchStats stats) {
    final neonColor = AppTheme.primary;
    final aWon = stats.setsA > stats.setsB;

    return Card(
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Jogador A
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats.record.playerAName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: aWon ? neonColor : AppTheme.onSurface,
                      fontWeight: aWon ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.setsA}',
                    style: TextStyle(
                      color: aWon ? neonColor : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
            ),

            // Separador
            const Text(' x ',
                style: TextStyle(color: Colors.white38, fontSize: 24)),

            // Jogador B
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats.record.playerBName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: !aWon ? neonColor : AppTheme.onSurface,
                      fontWeight: !aWon ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.setsB}',
                    style: TextStyle(
                      color: !aWon ? neonColor : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStats(_MatchStats stats) {
    final aPct = stats.totalPointsA + stats.totalPointsB > 0
        ? (stats.totalPointsA / (stats.totalPointsA + stats.totalPointsB) * 100)
            .round()
        : 0;
    final bPct = 100 - aPct;

    return Card(
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estatísticas Gerais',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _statRow('Games', '${stats.gamesA}', '${stats.gamesB}'),
            _statRow('Total de Pontos', '${stats.totalPointsA}',
                '${stats.totalPointsB}'),
            _statRow('Aproveitamento de Pontos', '$aPct%', '$bPct%'),
            // Sets detail
            if (stats.setGamesA.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Placar por Set:',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              for (int i = 0; i < stats.setGamesA.length; i++)
                _statRow('Set ${i + 1}', '${stats.setGamesA[i]}',
                    '${stats.setGamesB[i]}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakPoints(_MatchStats stats) {
    return Card(
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Break Points',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _statRow('Break Points Enfrentados', '${stats.breakPointsFacedA}',
                '${stats.breakPointsFacedB}'),
            _statRow(
                'Jogos de Break',
                '${stats.gameResults.where((g) => g.wasBreak && g.winnerIsA).length}',
                '${stats.gameResults.where((g) => g.wasBreak && !g.winnerIsA).length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPointSequence(_MatchStats stats) {
    if (stats.gameResults.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sequência de Games',
                style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (int i = 0; i < stats.setGamesA.length; i++) ...[
              Text('Set ${i + 1}',
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: stats.gameResults
                    .where((g) => g.setNumber == i + 1)
                    .map((g) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: g.wasBreak
                                ? AppTheme.error.withOpacity(0.3)
                                : Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${g.winnerIsA ? stats.record.playerAName.substring(0, 1) : stats.record.playerBName.substring(0, 1)}'
                            '${g.pointsA}-${g.pointsB}',
                            style: TextStyle(
                              color: g.wasBreak
                                  ? AppTheme.error
                                  : AppTheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String valueA, String valueB) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(valueA,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          SizedBox(
            width: 160,
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ),
          Expanded(
            child: Text(valueB,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _shareMatch(_MatchStats stats) {
    final winner = stats.setsA > stats.setsB
        ? stats.record.playerAName
        : stats.record.playerBName;
    final text = '''
🏆 ${stats.record.configName}
📅 ${stats.record.startedAt.day}/${stats.record.startedAt.month}/${stats.record.startedAt.year}

${stats.record.playerAName} ${stats.setsA} x ${stats.setsB} ${stats.record.playerBName}

Games: ${stats.gamesA} x ${stats.gamesB}
Pontos: ${stats.totalPointsA} x ${stats.totalPointsB}

Vencedor: $winner
''';
    Share.share(text);
  }
}

class _MatchStats {
  final MatchRecord record;
  final int setsA;
  final int setsB;
  final int gamesA;
  final int gamesB;
  final int totalPointsA;
  final int totalPointsB;
  final int breakPointsFacedA;
  final int breakPointsFacedB;
  final List<int> setGamesA;
  final List<int> setGamesB;
  final List<_GameResult> gameResults;

  _MatchStats({
    required this.record,
    required this.setsA,
    required this.setsB,
    required this.gamesA,
    required this.gamesB,
    required this.totalPointsA,
    required this.totalPointsB,
    required this.breakPointsFacedA,
    required this.breakPointsFacedB,
    required this.setGamesA,
    required this.setGamesB,
    required this.gameResults,
  });
}

class _GameResult {
  final int setNumber;
  final int gameNumber;
  final bool winnerIsA;
  final bool wasBreak;
  final bool serverIsA;
  final int pointsA;
  final int pointsB;

  _GameResult({
    required this.setNumber,
    required this.gameNumber,
    required this.winnerIsA,
    required this.wasBreak,
    required this.serverIsA,
    required this.pointsA,
    required this.pointsB,
  });
}
