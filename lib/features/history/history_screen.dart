import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_theme.dart';
import '../../models/match_record.dart';
import '../../providers/match_history_provider.dart';
import 'match_detail_screen.dart';

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
        error: (e, _) => const Center(
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
            itemBuilder: (context, index) => _MatchTile(
              record: records[index],
              onDelete: () => _confirmDelete(context, ref, records[index]),
              onTap: () => _openDetail(context, records[index]),
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, MatchRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchDetailScreen(record: record),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MatchRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        title: const Text(
          'Apagar partida?',
          style:
              TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${record.playerAName} vs ${record.playerBName}',
          style: const TextStyle(color: AppTheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(matchHistoryProvider.notifier).deleteRecord(record.id);
              Navigator.of(ctx).pop();
            },
            child:
                const Text('Apagar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
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
  const _MatchTile({
    required this.record,
    required this.onDelete,
    required this.onTap,
  });

  final MatchRecord record;
  final VoidCallback onDelete;
  final VoidCallback onTap;

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

  /// Reconstrói o placar final a partir da lista de pontos.
  _ScoreSummary get _summary {
    int setsA = 0;
    int setsB = 0;
    int setGamesA = 0;
    int setGamesB = 0;
    int setsToWin = record.configSnapshot.gamesToWinSet;
    int tiebreakAt = record.configSnapshot.tiebreakAt;
    int minDiff = record.configSnapshot.minGameDifference;

    for (final point in record.points) {
      if (point.scorerIsA) {
        setGamesA++;
      } else {
        setGamesB++;
      }

      final canWinSet = setGamesA >= setsToWin || setGamesB >= setsToWin;
      final hasDiff = (setGamesA - setGamesB).abs() >= minDiff;
      final maxSetsReached = setGamesA >= tiebreakAt && setGamesB >= tiebreakAt;

      if (canWinSet && hasDiff || maxSetsReached) {
        if (setGamesA > setGamesB) {
          setsA++;
        } else {
          setsB++;
        }
        setGamesA = 0;
        setGamesB = 0;

        if (setsA > record.configSnapshot.maxSets ~/ 2 ||
            setsB > record.configSnapshot.maxSets ~/ 2) break;
      }
    }

    return _ScoreSummary(setsA: setsA, setsB: setsB);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    final neonColor = AppTheme.primary;
    final aWon = summary.setsA > summary.setsB;

    return Card(
      color: AppTheme.surfaceVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: data e duração
              Row(
                children: [
                  const Icon(Icons.sports_tennis,
                      color: AppTheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.configName,
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(record.startedAt),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Placar: Jogador A  X  Jogador B
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.playerAName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: aWon ? neonColor : AppTheme.onSurface,
                        fontWeight: aWon ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text('${summary.setsA}',
                            style: TextStyle(
                                color: aWon ? neonColor : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28)),
                        const Text(' x ',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 18)),
                        Text('${summary.setsB}',
                            style: TextStyle(
                                color: !aWon ? neonColor : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      record.playerBName,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: !aWon ? neonColor : AppTheme.onSurface,
                        fontWeight: !aWon ? FontWeight.bold : FontWeight.normal,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share,
                        color: Colors.white38, size: 20),
                    tooltip: 'Compartilhar',
                    onPressed: () {
                      final winner = summary.setsA > summary.setsB
                          ? record.playerAName
                          : record.playerBName;
                      Share.share(
                          '${record.playerAName} ${summary.setsA} x ${summary.setsB} ${record.playerBName}\nVencedor: $winner\n${_formatDate(record.startedAt)}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.error, size: 20),
                    tooltip: 'Apagar',
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
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
