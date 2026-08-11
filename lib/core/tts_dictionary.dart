/// Dicionário centralizado de todas as frases usadas na locução (TTS).
/// Cada idioma tem um Map<String, String> com chaves fixas.
/// O usuário pode customizar qualquer frase.
class TtsDictionary {
  /// Idiomas suportados com suas frases padrão.
  static const Map<String, Map<String, String>> defaults = {
    'pt-BR': {
      // Anúncios de game/set/match
      'game': 'Game',
      'advantage': 'Vantagem',
      'deuce': 'iguais',
      'tiebreak': 'Taibrêik',
      'matchWinner': 'Game, set, match',
      'setWinnerPrefix': 'Game e',
      'setTied': 'set empatado em',
      'leads': 'lidera por',
      'gamesUnit': 'games a',
      'timeWarning': 'Táim',
      // Ordinais de set
      'ordinal1': 'primeiro',
      'ordinal2': 'segundo',
      'ordinal3': 'terceiro',
      'ordinal4': 'quarto',
      'ordinal5': 'quinto',
      // Pontuação
      'love': 'zero',
      'fifteen': '15',
      'thirty': '30',
      'forty': '40',
      // Tiebreak
      'tiebreakScore': 'a',
      'tiebreakSuffix': 'no taibrêik',
    },
    'en-US': {
      // Anúncios de game/set/match
      'game': 'Game',
      'advantage': 'Advantage',
      'deuce': 'all',
      'tiebreak': 'Tiebreak',
      'matchWinner': 'Game, set and match',
      'setWinnerPrefix': 'Game and',
      'setTied': 'set tied at',
      'leads': 'leads',
      'gamesUnit': 'games to',
      'timeWarning': 'Time',
      // Ordinais de set
      'ordinal1': 'first',
      'ordinal2': 'second',
      'ordinal3': 'third',
      'ordinal4': 'fourth',
      'ordinal5': 'fifth',
      // Pontuação
      'love': 'love',
      'fifteen': 'fifteen',
      'thirty': 'thirty',
      'forty': 'forty',
      // Tiebreak
      'tiebreakScore': 'to',
      'tiebreakSuffix': 'in the tiebreak',
    },
  };

  /// Retorna a frase para uma chave e idioma, com fallback para pt-BR.
  static String get(String key, String languageCode,
      {Map<String, String>? custom}) {
    // Verifica customizações primeiro
    if (custom != null && custom.containsKey(key)) {
      return custom[key]!;
    }
    // Busca no dicionário do idioma
    final langMap = defaults[languageCode];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    // Fallback para pt-BR
    return defaults['pt-BR']![key] ?? key;
  }

  /// Retorna o ordinal do set para o idioma.
  static String ordinal(int setNumber, String languageCode,
      {Map<String, String>? custom}) {
    switch (setNumber) {
      case 1:
        return get('ordinal1', languageCode, custom: custom);
      case 2:
        return get('ordinal2', languageCode, custom: custom);
      case 3:
        return get('ordinal3', languageCode, custom: custom);
      case 4:
        return get('ordinal4', languageCode, custom: custom);
      case 5:
        return get('ordinal5', languageCode, custom: custom);
      default:
        return '$setNumberº';
    }
  }

  /// Retorna a palavra da pontuação para o valor numérico.
  static String pointWord(int points, String languageCode,
      {Map<String, String>? custom}) {
    switch (points) {
      case 0:
        return get('love', languageCode, custom: custom);
      case 1:
        return get('fifteen', languageCode, custom: custom);
      case 2:
        return get('thirty', languageCode, custom: custom);
      case 3:
        return get('forty', languageCode, custom: custom);
      default:
        return get('forty', languageCode, custom: custom);
    }
  }

  /// Lista de todas as chaves disponíveis para customização.
  static const List<String> customizableKeys = [
    'game',
    'advantage',
    'deuce',
    'tiebreak',
    'matchWinner',
    'setWinnerPrefix',
    'setTied',
    'leads',
    'gamesUnit',
    'timeWarning',
    'love',
    'fifteen',
    'thirty',
    'forty',
    'tiebreakScore',
    'tiebreakSuffix',
  ];

  /// Labels legíveis para cada chave (para exibição na tela de configuração).
  static const Map<String, String> keyLabels = {
    'game': 'Game',
    'advantage': 'Vantagem / Advantage',
    'deuce': '40 iguais / deuce',
    'tiebreak': 'Taibrêik / Tiebreak',
    'matchWinner': 'Game, set, match',
    'setWinnerPrefix': 'Prefixo Game e set',
    'setTied': 'Set empatado / tied',
    'leads': 'Lidera / leads',
    'gamesUnit': 'Unidade games a / to',
    'timeWarning': 'Aviso de tempo',
    'love': 'Love / zero (0)',
    'fifteen': 'Fifteen / 15',
    'thirty': 'Thirty / 30',
    'forty': 'Forty / 40',
    'tiebreakScore': 'Separador tiebreak (a / to)',
    'tiebreakSuffix': 'Sufixo tiebreak',
  };
}
