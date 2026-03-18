# RELATÓRIO MESTRE - REMOTE RACKET SCORE
**Data da última atualização:** Março de 2026

## 1. Visão Geral do Projeto
Aplicativo multi-idiomas (inglês e português) que visa dar um ar de profissionalismo a partidas amadoras de esportes de raquete (Tênis, Beach Tennis, Padel). 
Facilita a contagem e registro de pontos (15, 30, 40, games e sets) de forma remota (fone Bluetooth, Smartwatch, Cam Shutter) ou manual. Exibe um placar visualmente limpo em TVs ou dispositivos móveis, anuncia os pontos via áudio (TTS) e gera relatórios de partidas para integração futura com apps de ranking e torneios.

## 2. Stack Tecnológico e Arquitetura
* **Framework:** Flutter (Dart).
* **Gerência de Estado:** Riverpod (`flutter_riverpod`).
* **Estrutura de Pastas:** Padrão modular (`lib/features/`, `lib/providers/`, `lib/services/`, `lib/models/`).
* **Persistência Atual:** Local (preparando terreno para futura integração Cloud/Firebase).

## 3. Conquistas Atuais (O QUE JÁ FUNCIONA E NÃO PODE SER QUEBRADO)
* **Motor de Áudio e Bluetooth (Universal):** Intercepta comandos AVRCP universais (`SKIP_NEXT` = Ponto A, `SKIP_PREVIOUS` = Ponto B, `PAUSE/PLAY` = Desfazer) usando `just_audio` (faixa munda 24h) e `audio_service`.
* **Lógica de Cliques e Pontuação Local:** O motor físico (via `KeyEventService`) traduz teclas locais (Cam Shutter/Teclado USB) para 1, 2 ou 3 cliques, respeitando a pontuação.
* **Telas:** `ScoreScreen` (Placar reativo e relógios), `ButtonMappingScreen`, `SettingsScreen`.

## 4. Regras de Ouro para o Gemini (Diretrizes de IA)
* **NUNCA** altere o motor de áudio (`match_audio_handler.dart`) sem extrema necessidade.
* **NUNCA** reescreva arquivos inteiros ("apagar tudo e colar") a menos que seja arquivo novo. Use "Cirurgia a Laser".
* O usuário não é programador de ofício. Sempre peça o código-fonte atual da tela ANTES de sugerir modificações e indique a pasta correta.

## 5. Backlog de Pendências (O que falta fazer)

### Grandes (Mudanças de Arquitetura e Fluxo)
- [ ] **Nova Navegação (Main Menu):** O app não deve abrir direto no Placar. Deve abrir em um Menu Principal com:
  - **NOVO JOGO:** Escolher preset, definir nomes, iniciar partida (abre o Placar). Botão "Salvar e Sair" com proteção de "Undo" em caso de matchpoint acidental.
  - **CONFIGURAÇÕES DE PARTIDAS:** Ajustar presets de regras (sem atrelar nomes de jogadores).
  - **CONFIGURAÇÕES DO APP:** Mapeamento de botões, som, TTS, etc.
  - **USUÁRIO:** Dados do perfil para futura integração em nuvem/torneios.
  - **ATIVIDADE:** Histórico de partidas finalizadas (busca, compartilhamento, exclusão em lote/única).

### Médias (Funcionalidades de Dados)
- [ ] **Exportação:** Ajustar layout e exportação dos dados do histórico de partidas (Atividade).
- [ ] **Cloud Sync:** Planejar banco de dados em nuvem para evitar perda de dados na desinstalação.

### Pequenas (Refinamentos UI/UX)
- [ ] **UI do Placar:** O menu superior do placar (AppBar) deve subir e sumir com animação após o início, maximizando o placar.
- [ ] **Novos Relógios:** Criar temporizador específico de "Troca de lado rápida" (ex: 90s) para o intervalo entre o 1º e 2º games do set, diferenciando do relógio de saque de 25s.