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
          'Histórico',
          style:
              TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          historyAsync.valueOrNull != null &&
                  historyAsync.valueOrNull!.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep, color: AppTheme.error),
                  tooltip: 'Limpar histórico',
                  onPressed: () => _confirmClear(context, ref),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar histórico',
            style: TextStyle(color: AppTheme.error, fontSize: 16),
          ),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma partida registrada',
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Finalize uma partida para vê-la aqui',
                    style: TextStyle(color: Colors.white24, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: records.length,
            itemBuilder: (context, index) => _MatchTile(record: records[index]),
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text(
          'Limpar histórico',
          style:
              TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Deseja apagar todo o histórico de partidas?',
          style: TextStyle(color: AppTheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(matchHistoryProvider.notifier).clear();
              Navigator.of(ctx).pop();
            },
            child:
                const Text('Apagar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.record});

  final MatchRecord record;

  /// Reconstrói o placar final a partir da lista de pontos.
  _ScoreSummary get _summary {
    int setsA = 0;
    int setsB = 0;
    int gamesA = 0;
    int gamesB = 0;
    int currentSet = 1;
    int setsToWin = record.configSnapshot.gamesToWinSet;
    int maxSets = record.configSnapshot.maxSets;
    int tiebreakAt = record.configSnapshot.tiebreakAt;
    int minDiff = record.configSnapshot.minGameDifference;

    // Rastreamento de games por set
    int setGamesA = 0;
    int setGamesB = 0;

    for (final point in record.points) {
      if (point.scorerIsA) {
        gamesA++;
        setGamesA++;
      } else {
        gamesB++;
        setGamesB++;
      }

      // Verifica se alguém ganhou o set
      final canWinSet = setGamesA >= setsToWin || setGamesB >= setsToWin;
      final hasDiff = (setGamesA - setGamesB).abs() >= minDiff;
      final maxSetsReached = setGamesA >= tiebreakAt && setGamesB >= tiebreakAt;

      if (canWinSet && hasDiff || maxSetsReached) {
        if (setGamesA > setGamesB) {
          setsA++;
        } else {
          setsB++;
        }
        // Próximo set
        setGamesA = 0;
        setGamesB = 0;
        currentSet++;

        // Se alguém já ganhou mais da metade dos sets, para
        if (setsA > maxSets ~/ 2 || setsB > maxSets ~/ 2) break;
      }
    }

    return _ScoreSummary(setsA: setsA, setsB: setsB);
  }

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  String _formatDuration() {
    final diff = record.finishedAt.difference(record.startedAt);
    final min = diff.inMinutes;
    if (min < 60) return '${min}min';
    final h = diff.inHours;
    final m = min.remainder(60);
    return '${h}h${m > 0 ? ' ${m}min' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Card(
      color: AppTheme.surfaceVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: config name e data
            Row(
              children: [
                Icon(Icons.sports_tennis, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.configName,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  _formatDate(record.startedAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Placar final
            Row(
              children: [
                // Jogador A
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.playerAName,
                        style: TextStyle(
                          color: summary.setsA > summary.setsB
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                          fontWeight: summary.setsA > summary.setsB
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Placar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        '${summary.setsA}',
                        style: TextStyle(
                          color: summary.setsA > summary.setsB
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const Text(
                        ' x ',
                        style: TextStyle(color: Colors.white38, fontSize: 20),
                      ),
                      Text(
                        '${summary.setsB}',
                        style: TextStyle(
                          color: summary.setsB > summary.setsA
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),

                // Jogador B
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        record.playerBName,
                        style: TextStyle(
                          color: summary.setsB > summary.setsA
                              ? AppTheme.primary
                              : AppTheme.onSurface,
                          fontWeight: summary.setsB > summary.setsA
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rodapé: duração
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.white24, size: 14),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(),
                  style: const TextStyle(color: Colors.white24, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSummary {
  const _ScoreSummary({required this.setsA, required this.setsB});
  final int setsA;
  final int setsB;
}
