# Remote Racket Score

Aplicativo mobile (iOS e Android) que funciona como **placar automatizado** e **Juiz de Cadeira virtual** para partidas de Tênis, Padel, Beach Tennis e afins. Narra os pontos em voz alta via TTS e pode ser operado por controle Bluetooth.

## Funcionalidades

- **Controle remoto**: Mapeamento de botões Bluetooth (ex.: controle de volante) para: Ponto Time A, Ponto Time B, Desfazer.
- **Motor de regras configurável**: Sets, games, tiebreak, vantagem/no-ad, mini partidas, melhor de 3/5 sets, etc.
- **TTS**: Anúncio da pontuação do sacador primeiro, "Game [vencedor]", placar do set ("X iguais" ou "[Nome] lidera por X a Y").
- **UI alto contraste**: Números gigantes e indicador de saque para visibilidade sob sol.

## Configuração

1. Instale o [Flutter](https://flutter.dev).
2. Se a pasta ainda não tiver os diretórios `android/` e `ios/`, crie o projeto base:  
   `flutter create . --project-name remote_racket_score`
3. Na pasta do projeto: `flutter pub get`
4. Execute: `flutter run` (dispositivo ou emulador).

**Nota (Android):** Em alguns dispositivos, os botões de hardware/Bluetooth só passam a ser detectados após o app ganhar foco (por exemplo, após abrir o teclado uma vez). É uma limitação conhecida do Flutter.

## Estrutura do projeto

- `lib/core/` – Tema, constantes
- `lib/features/` – Score, settings, button_mapping
- `lib/models/` – GameConfig, ScoreState, etc.
- `lib/providers/` – Riverpod providers
- `lib/services/` – TTS, KeyEvent

## Mapeamento de botões

Em **Ajustes > Mapeamento de Botões**, pressione um botão físico e o app registra o KeyCode para cada ação (Ponto A, Ponto B, Desfazer).
