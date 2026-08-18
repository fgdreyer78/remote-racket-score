// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Remote Racket Score';

  @override
  String get home => 'Main Menu';

  @override
  String get newGame => 'NEW GAME';

  @override
  String get presets => 'PRESETS';

  @override
  String get history => 'HISTORY';

  @override
  String get settings => 'SETTINGS';

  @override
  String get version => 'v1.0';

  @override
  String get playerA => 'Player / Team A';

  @override
  String get playerB => 'Player / Team B';

  @override
  String get playerANameHint => 'Player or team A name';

  @override
  String get playerBNameHint => 'Player or team B name';

  @override
  String get presetLabel => 'Game Preset';

  @override
  String get presetDefault => 'Default (last configuration)';

  @override
  String get presetNone => 'No saved presets. Default (Tennis) will be used.';

  @override
  String get play => 'PLAY';

  @override
  String get fillBothNames => 'Please fill in both player/team names.';

  @override
  String get differentNames => 'Player names must be different.';

  @override
  String get startMatch => 'Start match?';

  @override
  String get presetLabelShort => 'Preset';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get coinToss => 'Coin Toss';

  @override
  String coinTossWinner(String winner) {
    return '$winner won the toss!\nChoose:';
  }

  @override
  String get receive => 'Receive';

  @override
  String get serve => 'Serve';

  @override
  String get skip => 'Skip';

  @override
  String get score => 'Score';

  @override
  String get historyTitle => 'History';

  @override
  String get noMatches => 'No matches recorded';

  @override
  String get noMatchesHint => 'Finish a match to see it here';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get clearHistoryConfirm => 'Do you want to delete all match history?';

  @override
  String get delete => 'Delete';

  @override
  String get deleteMatch => 'Delete match?';

  @override
  String get share => 'Share';

  @override
  String get matchDetail => 'Match Details';

  @override
  String get duration => 'Duration';

  @override
  String get matchStats => 'General Stats';

  @override
  String get games => 'Games';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get pointPercentage => 'Point Percentage';

  @override
  String get scoreBySet => 'Score by Set';

  @override
  String get breakPoints => 'Break Points';

  @override
  String get breakPointsFaced => 'Break Points Faced';

  @override
  String get breakGames => 'Break Games';

  @override
  String get gameSequence => 'Game Sequence';

  @override
  String winner(String name) {
    return 'Winner';
  }

  @override
  String winnerLabel(String name) {
    return 'Winner: $name';
  }

  @override
  String get settingsTitle => 'Match Settings';

  @override
  String get sportName => 'Sport / configuration name';

  @override
  String get gamesAndSets => 'Games and Sets';

  @override
  String get gamesToWinSet => 'Games to win a set';

  @override
  String get minGameDifference => 'Minimum game difference';

  @override
  String get numberOfSets => 'Number of sets (best of)';

  @override
  String get tiebreak => 'Tiebreak';

  @override
  String get tiebreakAt => 'Tiebreak when tied at';

  @override
  String get tiebreakPoints => 'Points to win tiebreak';

  @override
  String get tiebreakDifference => 'Tiebreak difference';

  @override
  String get finalSetTiebreak => 'Tiebreak as deciding set';

  @override
  String get timerAndBreaks => 'Timer and Breaks';

  @override
  String get serveClock => 'Serve clock (seconds)';

  @override
  String get oddGamesBreak => 'Odd games break (seconds)';

  @override
  String get evenGamesBreak => 'Even games break (seconds)';

  @override
  String get setsBreak => 'Sets break (seconds)';

  @override
  String get timeWarning => '\"Time\" sound alert (odd games and sets)';

  @override
  String get pointFlash => 'Point Flash Visual';

  @override
  String get enableFlash => 'Enable point flash';

  @override
  String get flashFrequency => 'Frequency (times/sec)';

  @override
  String get flashDuration => 'Total duration (ms)';

  @override
  String get speechLanguage => 'Speech Language';

  @override
  String get saveToHistory => 'Save to History';

  @override
  String get autoSave => 'Auto-save at end of match';

  @override
  String get autoSaveDelay => 'Wait before saving (seconds)';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get layout => 'Score Layout';

  @override
  String get layoutDefault => 'Default (portrait / landscape)';

  @override
  String get layoutSplit => 'Split landscape (side by side)';

  @override
  String get newMatch => 'New match';

  @override
  String get resetMatchConfirm =>
      'Are you sure you want to reset the score and start a new match?';

  @override
  String get mapButtons => 'Map buttons';

  @override
  String get configurations => 'Settings';

  @override
  String get sportSettings => 'Scoring Devices';

  @override
  String get sportSettingsHint => 'Volume, media and keyboard buttons';

  @override
  String get scoreLayout => 'Score Layout';

  @override
  String get scoreLayoutHint => 'Coming soon';

  @override
  String get language => 'Language';

  @override
  String get languageHint => 'Coming soon';

  @override
  String get portuguese => 'Português (Brasil)';

  @override
  String get english => 'English (US)';
}
