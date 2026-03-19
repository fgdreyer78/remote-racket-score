# RELATÓRIO MESTRE - REMOTE RACKET SCORE
**Data da última atualização:** Março de 2026

## 1. Visão Geral do Projeto
Aplicativo multi-idiomas (inglês e português) que visa dar um ar de profissionalismo a partidas amadoras de esportes de raquete (Tênis, Beach Tennis, Padel). 
Facilita a contagem e registro de pontos de forma remota (fone Bluetooth, Smartwatch, Cam Shutter).

## 2. Índice e Estrutura de Pastas (Onde está o quê)
* `lib/features/`: Telas visuais do usuário.
  * `/score/score_screen.dart`: Tela principal do placar (gestos, modo imersivo, relógios gigantes).
  * `/settings/settings_screen.dart`: Menu de regras, tiebreak e temporizadores.
  * `/button_mapping/button_mapping_screen.dart`: Tela para mapear cliques (1, 2, 3) a funções do placar.
  * `/history/history_screen.dart`: Tela do histórico (Atividade).
* `lib/services/`: Lógica pesada, sistema e hardwares.
  * `match_audio_handler.dart`: O "Laranja" de Áudio. Usa `just_audio` (silêncio 24h) para roubar comandos de fone/smartwatch.
  * `key_event_service.dart`: O Cérebro Físico. Ouve teclas, gerencia botões de volume (`perfect_volume_control`) para Shutters e faz a matemática do timer de 1, 2 e 3 cliques.
  * `tts_service.dart`: O Narrador (Text-to-Speech).
* `lib/providers/`: Gerenciadores de estado (Riverpod). Mantém a memória ativa do app.
* `lib/models/`: Regras de negócio, placar (`score_state.dart`), e configuração (`game_config.dart`).

## 3. Conquistas Atuais (O QUE JÁ FUNCIONA)
* **Motor de Áudio e Bluetooth (Universal):** Intercepta comandos AVRCP universais (Next/Prev/Pause).
* **Controle Cam Shutter:** Interceptação de botões de Volume Up/Down via `perfect_volume_control` com auto-reset de volume para evitar limites (0% ou 100%).
* **Lógica de Cliques e Pontuação Local:** O motor físico (via `KeyEventService`) traduz teclas locais para 1, 2 ou 3 cliques, respeitando a pontuação.
* **UI Imersiva e Gestos:** Tela cheia absoluta. Menu superior flutuante que sobe sozinho ao marcar pontos para despoluir a tela. Relógios gigantes e independentes (Stack/FittedBox).

## 4. Regras de Ouro para o Gemini
* **NUNCA** altere o motor de áudio ou os serviços sem extrema necessidade.
* **NUNCA** reescreva arquivos inteiros. Use "Cirurgia a Laser".
* Sempre peça o código-fonte atual da tela ANTES de sugerir modificações.

## 5. Backlog de Pendências (O que falta fazer)
- [ ] **Nova Navegação (Main Menu):** O app não deve abrir direto no Placar.
- [ ] **Exportação:** Ajustar layout e exportação dos dados do histórico.
- [ ] **Modo Foco nas Configurações:** Atalho para ativar "Não Perturbe".
- [ ] **Novos Relógios:** Temporizador de "Troca de lado rápida" (ex: 90s) para o intervalo entre 1º e 2º games.