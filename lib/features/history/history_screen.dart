import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../models/match_record.dart';
import '../../providers/match_history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(matchHistoryProvider);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'Histórico de partidas',
          style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar histórico',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppTheme.error),
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma partida registrada ainda.',
                style: TextStyle(color: AppTheme.onSurface),
              ),
            );
          }
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final summary = _buildSummary(record);
              final dateStr =
                  '${record.startedAt.day.toString().padLeft(2, '0')}/${record.startedAt.month.toString().padLeft(2, '0')} '
                  '${record.startedAt.hour.toString().padLeft(2, '0')}:${record.startedAt.minute.toString().padLeft(2, '0')}';
              return Card(
                color: AppTheme.surfaceVariant,
                child: ListTile(
                  title: Text(
                    '${record.playerAName} vs ${record.playerBName}',
                    style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$dateStr · ${record.configName}\n$summary',
                    style: TextStyle(
                      color: AppTheme.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () async {
                    await _showExportDialog(context, record);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _buildSummary(MatchRecord record) {
    final setGames = <int, _SetScore>{};
    for (final point in record.points) {
      final key = point.setNumber;
      setGames.putIfAbsent(key, () => _SetScore());
      final score = setGames[key]!;
      score.registerPoint(point);
    }
    int setsA = 0;
    int setsB = 0;
    final setStrings = <String>[];
    final sortedKeys = setGames.keys.toList()..sort();
    for (final setNumber in sortedKeys) {
      final score = setGames[setNumber]!;
      setStrings.add('${score.gamesA}-${score.gamesB}');
      if (score.gamesA > score.gamesB) {
        setsA++;
      } else if (score.gamesB > score.gamesA) {
        setsB++;
      }
    }
    final setsScore = '$setsA–$setsB';
    final setsDetail = setStrings.join(', ');
    return 'Resultado: $setsScore ($setsDetail)';
  }

  Future<void> _showExportDialog(
    BuildContext context,
    MatchRecord record,
  ) async {
    final summary = _buildSummary(record);
    final detailed = _buildDetailed(record);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          title: const Text(
            'Exportar partida',
            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  _summaryText(record, summary),
                  style: const TextStyle(color: AppTheme.onSurface),
                ),
                const SizedBox(height: 16),
                Text(
                  'Detalhado:',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  detailed,
                  style: const TextStyle(color: AppTheme.onSurface),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar', style: TextStyle(color: AppTheme.primary)),
            ),
          ],
        );
      },
    );
  }

  String _summaryText(MatchRecord record, String summary) {
    return 'Configuração da partida: ${record.configName}\n'
        '${record.playerAName} vs ${record.playerBName}\n'
        '$summary';
  }

  String _buildDetailed(MatchRecord record) {
    final buffer = StringBuffer();
    buffer.writeln(_summaryText(record, _buildSummary(record)));
    buffer.writeln();
    final map = <int, Map<int, List<PointEvent>>>{};
    for (final p in record.points) {
      map.putIfAbsent(p.setNumber, () => <int, List<PointEvent>>{});
      final byGame = map[p.setNumber]!;
      byGame.putIfAbsent(p.gameNumber, () => <PointEvent>[]);
      byGame[p.gameNumber]!.add(p);
    }
    final setNumbers = map.keys.toList()..sort();
    for (final setNumber in setNumbers) {
      buffer.writeln('Set $setNumber:');
      final games = map[setNumber]!;
      final gameNumbers = games.keys.toList()..sort();
      for (final gameNumber in gameNumbers) {
        final points = games[gameNumber]!;
        final isTiebreak = points.any((p) => p.isTiebreak);
        final label = isTiebreak ? 'Tiebreak' : 'Game $gameNumber';
        final seq = points
            .map((p) => p.scorerIsA ? 'A' : 'B')
            .join(', ');
        buffer.writeln('  $label: $seq');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}

class _SetScore {
  int gamesA = 0;
  int gamesB = 0;

  int _currentGameNumber = 1;
  bool _lastWinnerIsA = false;

  void registerPoint(PointEvent point) {
    if (point.gameNumber != _currentGameNumber) {
      if (_lastWinnerIsA) {
        gamesA++;
      } else {
        gamesB++;
      }
      _currentGameNumber = point.gameNumber;
    }
    _lastWinnerIsA = point.scorerIsA;
  }
}