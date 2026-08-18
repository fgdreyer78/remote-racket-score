import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remote Racket Score'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Menu Principal'**
  String get home;

  /// No description provided for @newGame.
  ///
  /// In pt, this message translates to:
  /// **'NOVO JOGO'**
  String get newGame;

  /// No description provided for @presets.
  ///
  /// In pt, this message translates to:
  /// **'PRESETS'**
  String get presets;

  /// No description provided for @history.
  ///
  /// In pt, this message translates to:
  /// **'HISTÓRICO'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'CONFIGURAÇÕES'**
  String get settings;

  /// No description provided for @version.
  ///
  /// In pt, this message translates to:
  /// **'v1.0'**
  String get version;

  /// No description provided for @playerA.
  ///
  /// In pt, this message translates to:
  /// **'Jogador / Dupla A'**
  String get playerA;

  /// No description provided for @playerB.
  ///
  /// In pt, this message translates to:
  /// **'Jogador / Dupla B'**
  String get playerB;

  /// No description provided for @playerANameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome do jogador ou dupla A'**
  String get playerANameHint;

  /// No description provided for @playerBNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome do jogador ou dupla B'**
  String get playerBNameHint;

  /// No description provided for @presetLabel.
  ///
  /// In pt, this message translates to:
  /// **'Preset de Jogo'**
  String get presetLabel;

  /// No description provided for @presetDefault.
  ///
  /// In pt, this message translates to:
  /// **'Padrão (última configuração)'**
  String get presetDefault;

  /// No description provided for @presetNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum preset salvo. Será usado o padrão (Tênis).'**
  String get presetNone;

  /// No description provided for @play.
  ///
  /// In pt, this message translates to:
  /// **'JOGAR'**
  String get play;

  /// No description provided for @fillBothNames.
  ///
  /// In pt, this message translates to:
  /// **'Preencha os nomes dos dois jogadores/duplas.'**
  String get fillBothNames;

  /// No description provided for @differentNames.
  ///
  /// In pt, this message translates to:
  /// **'Os nomes dos jogadores devem ser diferentes.'**
  String get differentNames;

  /// No description provided for @startMatch.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar partida?'**
  String get startMatch;

  /// No description provided for @presetLabelShort.
  ///
  /// In pt, this message translates to:
  /// **'Preset'**
  String get presetLabelShort;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @coinToss.
  ///
  /// In pt, this message translates to:
  /// **'Coin Toss'**
  String get coinToss;

  /// No description provided for @coinTossWinner.
  ///
  /// In pt, this message translates to:
  /// **'{winner} ganhou o sorteio!\nEscolha:'**
  String coinTossWinner(String winner);

  /// No description provided for @receive.
  ///
  /// In pt, this message translates to:
  /// **'Receber'**
  String get receive;

  /// No description provided for @serve.
  ///
  /// In pt, this message translates to:
  /// **'Sacar'**
  String get serve;

  /// No description provided for @skip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get skip;

  /// No description provided for @score.
  ///
  /// In pt, this message translates to:
  /// **'Placar'**
  String get score;

  /// No description provided for @historyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get historyTitle;

  /// No description provided for @noMatches.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma partida registrada'**
  String get noMatches;

  /// No description provided for @noMatchesHint.
  ///
  /// In pt, this message translates to:
  /// **'Finalize uma partida para vê-la aqui'**
  String get noMatchesHint;

  /// No description provided for @clearHistory.
  ///
  /// In pt, this message translates to:
  /// **'Limpar histórico'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Deseja apagar todo o histórico de partidas?'**
  String get clearHistoryConfirm;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// No description provided for @deleteMatch.
  ///
  /// In pt, this message translates to:
  /// **'Apagar partida?'**
  String get deleteMatch;

  /// No description provided for @share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get share;

  /// No description provided for @matchDetail.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da Partida'**
  String get matchDetail;

  /// No description provided for @duration.
  ///
  /// In pt, this message translates to:
  /// **'Duração'**
  String get duration;

  /// No description provided for @matchStats.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas Gerais'**
  String get matchStats;

  /// No description provided for @games.
  ///
  /// In pt, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @totalPoints.
  ///
  /// In pt, this message translates to:
  /// **'Total de Pontos'**
  String get totalPoints;

  /// No description provided for @pointPercentage.
  ///
  /// In pt, this message translates to:
  /// **'Aproveitamento de Pontos'**
  String get pointPercentage;

  /// No description provided for @scoreBySet.
  ///
  /// In pt, this message translates to:
  /// **'Placar por Set'**
  String get scoreBySet;

  /// No description provided for @breakPoints.
  ///
  /// In pt, this message translates to:
  /// **'Break Points'**
  String get breakPoints;

  /// No description provided for @breakPointsFaced.
  ///
  /// In pt, this message translates to:
  /// **'Break Points Enfrentados'**
  String get breakPointsFaced;

  /// No description provided for @breakGames.
  ///
  /// In pt, this message translates to:
  /// **'Jogos de Break'**
  String get breakGames;

  /// No description provided for @gameSequence.
  ///
  /// In pt, this message translates to:
  /// **'Sequência de Games'**
  String get gameSequence;

  /// No description provided for @winner.
  ///
  /// In pt, this message translates to:
  /// **'Vencedor'**
  String winner(String name);

  /// No description provided for @winnerLabel.
  ///
  /// In pt, this message translates to:
  /// **'Vencedor: {name}'**
  String winnerLabel(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações da partida'**
  String get settingsTitle;

  /// No description provided for @sportName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do esporte / configuração'**
  String get sportName;

  /// No description provided for @gamesAndSets.
  ///
  /// In pt, this message translates to:
  /// **'Games e Sets'**
  String get gamesAndSets;

  /// No description provided for @gamesToWinSet.
  ///
  /// In pt, this message translates to:
  /// **'Games para ganhar o set'**
  String get gamesToWinSet;

  /// No description provided for @minGameDifference.
  ///
  /// In pt, this message translates to:
  /// **'Diferença mínima de games'**
  String get minGameDifference;

  /// No description provided for @numberOfSets.
  ///
  /// In pt, this message translates to:
  /// **'Número de sets (melhor de)'**
  String get numberOfSets;

  /// No description provided for @tiebreak.
  ///
  /// In pt, this message translates to:
  /// **'Tiebreak'**
  String get tiebreak;

  /// No description provided for @tiebreakAt.
  ///
  /// In pt, this message translates to:
  /// **'Tiebreak ao empatar em'**
  String get tiebreakAt;

  /// No description provided for @tiebreakPoints.
  ///
  /// In pt, this message translates to:
  /// **'Pontos para ganhar tiebreak'**
  String get tiebreakPoints;

  /// No description provided for @tiebreakDifference.
  ///
  /// In pt, this message translates to:
  /// **'Diferença no tiebreak'**
  String get tiebreakDifference;

  /// No description provided for @finalSetTiebreak.
  ///
  /// In pt, this message translates to:
  /// **'Tiebreak como set decisivo'**
  String get finalSetTiebreak;

  /// No description provided for @timerAndBreaks.
  ///
  /// In pt, this message translates to:
  /// **'Cronômetro e Tempos'**
  String get timerAndBreaks;

  /// No description provided for @serveClock.
  ///
  /// In pt, this message translates to:
  /// **'Relógio de saque (segundos)'**
  String get serveClock;

  /// No description provided for @oddGamesBreak.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo entre games ímpares (segundos)'**
  String get oddGamesBreak;

  /// No description provided for @evenGamesBreak.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo entre games pares (segundos)'**
  String get evenGamesBreak;

  /// No description provided for @setsBreak.
  ///
  /// In pt, this message translates to:
  /// **'Intervalo entre sets (segundos)'**
  String get setsBreak;

  /// No description provided for @timeWarning.
  ///
  /// In pt, this message translates to:
  /// **'Aviso sonoro \"Tempo\" (games ímpares e sets)'**
  String get timeWarning;

  /// No description provided for @pointFlash.
  ///
  /// In pt, this message translates to:
  /// **'Flash Visual ao Marcar Ponto'**
  String get pointFlash;

  /// No description provided for @enableFlash.
  ///
  /// In pt, this message translates to:
  /// **'Ativar flash visual'**
  String get enableFlash;

  /// No description provided for @flashFrequency.
  ///
  /// In pt, this message translates to:
  /// **'Frequência (vezes/seg)'**
  String get flashFrequency;

  /// No description provided for @flashDuration.
  ///
  /// In pt, this message translates to:
  /// **'Duração total (ms)'**
  String get flashDuration;

  /// No description provided for @speechLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma de Fala'**
  String get speechLanguage;

  /// No description provided for @saveToHistory.
  ///
  /// In pt, this message translates to:
  /// **'Salvar no Histórico'**
  String get saveToHistory;

  /// No description provided for @autoSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar automaticamente ao fim da partida'**
  String get autoSave;

  /// No description provided for @autoSaveDelay.
  ///
  /// In pt, this message translates to:
  /// **'Aguardar antes de salvar (segundos)'**
  String get autoSaveDelay;

  /// No description provided for @saveSettings.
  ///
  /// In pt, this message translates to:
  /// **'Salvar configurações'**
  String get saveSettings;

  /// No description provided for @layout.
  ///
  /// In pt, this message translates to:
  /// **'Layout do Placar'**
  String get layout;

  /// No description provided for @layoutDefault.
  ///
  /// In pt, this message translates to:
  /// **'Padrão (retrato / paisagem)'**
  String get layoutDefault;

  /// No description provided for @layoutSplit.
  ///
  /// In pt, this message translates to:
  /// **'Paisagem dividido (lado a lado)'**
  String get layoutSplit;

  /// No description provided for @newMatch.
  ///
  /// In pt, this message translates to:
  /// **'Nova partida'**
  String get newMatch;

  /// No description provided for @resetMatchConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja resetar o placar e iniciar uma nova partida?'**
  String get resetMatchConfirm;

  /// No description provided for @mapButtons.
  ///
  /// In pt, this message translates to:
  /// **'Mapear botões'**
  String get mapButtons;

  /// No description provided for @configurations.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get configurations;

  /// No description provided for @sportSettings.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivos de Pontuação'**
  String get sportSettings;

  /// No description provided for @sportSettingsHint.
  ///
  /// In pt, this message translates to:
  /// **'Botões de volume, mídia e teclado'**
  String get sportSettingsHint;

  /// No description provided for @scoreLayout.
  ///
  /// In pt, this message translates to:
  /// **'Layout do Placar'**
  String get scoreLayout;

  /// No description provided for @scoreLayoutHint.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get scoreLayoutHint;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageHint.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get languageHint;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'English (US)'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
