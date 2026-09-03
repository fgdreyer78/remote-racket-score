import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/game_config.dart';
import '../../models/score_state.dart';
import '../../widgets/bottom_banner_ad.dart';

class LandscapeScoreLayout extends StatelessWidget {
  const LandscapeScoreLayout({
    super.key,
    required this.score,
    required this.config,
    required this.pointsA,
    required this.pointsB,
    required this.clockLabel,
    required this.clockRemaining,
    required this.flashingIsA,
    required this.flashState,
    required this.undoFlashActive,
    required this.gameJustEnded,
    required this.setJustEnded,
    required this.preGameEndPointsA,
    required this.preGameEndPointsB,
    required this.preGameEndTbPointsA,
    required this.preGameEndTbPointsB,
    required this.onPointA,
    required this.onPointB,
    required this.onUndo,
  });

  final ScoreState score;
  final GameConfig config;
  final String pointsA;
  final String pointsB;
  final String clockLabel;
  final int? clockRemaining;
  final bool? flashingIsA;
  final bool flashState;
  final bool undoFlashActive;
  final bool gameJustEnded;
  final bool setJustEnded;
  final int preGameEndPointsA;
  final int preGameEndPointsB;
  final int preGameEndTbPointsA;
  final int preGameEndTbPointsB;
  final VoidCallback onPointA;
  final VoidCallback onPointB;
  final VoidCallback onUndo;

  Color _bgColor(bool isA) {
    if (flashingIsA == null || !flashState) return Colors.transparent;
    final c = undoFlashActive ? const Color(0xFFFF4444) : AppTheme.primary;
    return (isA ? flashingIsA == true : flashingIsA == false) ? c : Colors.transparent;
  }

  Color _pointColor(bool isA) {
    if (flashingIsA == null || !flashState) return AppTheme.primary;
    return (isA ? flashingIsA == true : flashingIsA == false) ? AppTheme.surface : AppTheme.primary;
  }

  Color _textColor(bool isA) {
    if (flashingIsA == null || !flashState) return Colors.white;
    return (isA ? flashingIsA == true : flashingIsA == false) ? AppTheme.surface : Colors.white;
  }

  Color _grayColor(bool isA) {
    if (flashingIsA == null || !flashState) return const Color(0xFF9E9E9E);
    return (isA ? flashingIsA == true : flashingIsA == false) ? AppTheme.surface : const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxW = c.maxWidth;
      final maxH = c.maxHeight;
      final mTop = maxH * 0.10;
      final mBot = maxH * 0.15;
      final mSide = maxH * 0.05;
      final nameH = maxH * 0.30;
      final gapH = maxH * 0.15;
      final scoreH = maxH * 0.30;
      final infoW = maxW * 0.20;
      final nameFS = maxH * 0.10;
      final serveSz = nameFS * 0.5;
      final tLabelFS = maxH * 0.10;
      final tCountFS = maxH * 0.12;
      final tGap = maxW * 0.05;
      final sBase = maxH * 0.30;
      final sGap = maxW * 0.05;
      final isMT = score.isTiebreak && score.gamesA == 0 && score.gamesB == 0;
      final hasG = !score.matchOver && !isMT && (score.gamesA > 0 || score.gamesB > 0 || score.setsA > 0 || score.setsB > 0);
      final hasS = score.setsA > 0 || score.setsB > 0;
      final hasP = !score.matchOver && (pointsA != '0' || pointsB != '0' || (flashingIsA != null && (gameJustEnded || setJustEnded)));

      return Stack(children: [
        Padding(
          padding: EdgeInsets.only(top: mTop, bottom: mBot, left: mSide, right: mSide),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: infoW, child: Column(children: [
              SizedBox(height: nameH, child: _playerInfo(config.playerAName, score.serverIsA, serveSz, nameFS, infoW, mSide, true)),
              SizedBox(height: gapH, child: clockRemaining != null ? _timer(tLabelFS, tCountFS, tGap) : const SizedBox.shrink()),
              SizedBox(height: nameH, child: _playerInfo(config.playerBName, !score.serverIsA, serveSz, nameFS, infoW, mSide, false)),
            ])),
            Expanded(child: _scoreArea(maxW, maxH, nameH, gapH, scoreH, sBase, sGap, hasS, hasG, hasP)),
          ]),
        ),
        const Positioned(bottom: 0, left: 0, child: SafeArea(child: BottomBannerAd())),
        if (score.matchOver && score.winnerIsA != null)
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(color: AppTheme.surface.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(16)),
            child: Text('${score.winnerIsA! ? config.playerAName : config.playerBName} VENCEU!',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: maxH * 0.10)),
          )),
      ]);
    });
  }

  Widget _playerInfo(String name, bool isServer, double serveSz, double nameFS, double boxW, double mSide, bool isA) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isA ? onPointA : onPointB,
      onLongPress: onUndo,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        decoration: BoxDecoration(color: _bgColor(isA), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          SizedBox(width: mSide, child: Center(child: Opacity(opacity: isServer ? 1.0 : 0.0,
              child: Container(width: serveSz, height: serveSz,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle))))),
          Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
              child: Text(name, maxLines: 1, style: TextStyle(fontSize: nameFS, fontWeight: FontWeight.bold, color: _textColor(isA))))),
        ]),
      ),
    );
  }

  Widget _timer(double labelFS, double countFS, double gap) {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(clockLabel.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: labelFS, fontWeight: FontWeight.w500)),
      SizedBox(width: gap),
      Text('$clockRemaining', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: countFS)),
    ]);
  }

  Widget _scoreArea(double maxW, double maxH, double nameH, double gapH, double scoreH, double sBase, double sGap, bool hasS, bool hasG, bool hasP) {
    final totalH = nameH + gapH + scoreH;
    return SizedBox(width: maxW * 0.80, height: totalH,
      child: FittedBox(fit: BoxFit.contain, alignment: Alignment.centerRight,
        child: SizedBox(width: maxW * 0.80, height: totalH,
          child: Column(children: [
            SizedBox(height: nameH, child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: onPointA, onLongPress: onUndo,
                child: AnimatedContainer(duration: const Duration(milliseconds: 60),
                    decoration: BoxDecoration(color: _bgColor(true), borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.centerRight,
                    child: _scoreRow(true, sBase, sGap, hasS, hasG, hasP)))),
            SizedBox(height: gapH),
            SizedBox(height: scoreH, child: GestureDetector(behavior: HitTestBehavior.opaque,
                onTap: onPointB, onLongPress: onUndo,
                child: AnimatedContainer(duration: const Duration(milliseconds: 60),
                    decoration: BoxDecoration(color: _bgColor(false), borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.centerRight,
                    child: _scoreRow(false, sBase, sGap, hasS, hasG, hasP)))),
          ]),
        ),
      ),
    );
  }

  Widget _scoreRow(bool isA, double sBase, double sGap, bool hasS, bool hasG, bool hasP) {
    final g = isA ? score.gamesA : score.gamesB;
    final p = isA ? pointsA : pointsB;
    final psG = isA ? score.previousSetsGamesA : score.previousSetsGamesB;
    final psT = isA ? score.previousSetsTiebreakPointsA : score.previousSetsTiebreakPointsB;
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
      if (hasS) for (int i = 0; i < psG.length; i++) ...[
        _prevSet(psG[i], psT.length > i ? psT[i] : 0, sBase, isA),
        SizedBox(width: sGap),
      ],
      if (hasG) ...[
        Text('$g', style: TextStyle(fontSize: sBase, color: _textColor(isA), fontWeight: FontWeight.bold, height: 1.0)),
        if (hasP) SizedBox(width: sGap),
      ],
      if (hasP) Text(p, style: TextStyle(fontSize: sBase, color: _pointColor(isA), fontWeight: FontWeight.bold, height: 1.0)),
    ]);
  }

  Widget _prevSet(int gv, int tb, double fs, bool isA) {
    final gray = _grayColor(isA);
    if (tb > 0) {
      return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$gv', style: TextStyle(fontSize: fs, color: gray, fontWeight: FontWeight.bold, height: 1.0)),
        Padding(padding: EdgeInsets.only(top: fs * 0.13),
            child: Text('$tb', style: TextStyle(fontSize: fs * 0.47, color: gray, fontWeight: FontWeight.bold, height: 1.0))),
      ]);
    }
    return Text('$gv', style: TextStyle(fontSize: fs, color: gray, fontWeight: FontWeight.bold, height: 1.0));
  }
}
