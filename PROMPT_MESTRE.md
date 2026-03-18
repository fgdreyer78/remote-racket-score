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
* **Motor de Áudio e Bluetooth (Universal):** Intercepta comandos AVRCP universais (`SKIP_NEXT` = Ponto A, `SKIP_PREVIOUS` = Ponto B, `PAUSE/PLAY` = Desfazer) usando `just_audio` (faixa munda 24h) e `audio_service`. Testado com sucesso em sistemas de som automotivo.
* **Lógica de Cliques e Pontuação Local:** O motor físico (via `KeyEventService`) traduz teclas locais (Cam Shutter/Teclado USB) para 1, 2 ou 3 cliques, respeitando a pontuação.
* **Telas:** `ScoreScreen` (Placar reativo e relógios), `ButtonMappingScreen`, `SettingsScreen`.
* **Modo Imersivo e Animações:** Placar ocupa a tela inteira (esconde bateria/Wi-Fi). Menu superior flutuante com animação de 700ms controlada por gestos (swipe). Relógios gigates posicionados estrategicamente em portrait/landscape.

## 4. Regras de Ouro para o Gemini (Diretrizes de IA)
* **NUNCA** altere o motor de áudio (`match_audio_handler.dart`) sem extrema necessidade.
* **NUNCA** reescreva arquivos inteiros ("apagar tudo e colar") a menos que seja arquivo novo. Use "Cirurgia a Laser".
* O usuário não é programador de ofício. Sempre peça o código-fonte atual da tela ANTES de sugerir modificações e indique a pasta correta.

## 5. Backlog de Pendências (O que falta fazer)

### Grandes (Mudanças de Arquitetura e Fluxo)
- [ ] **Nova Navegação (Main Menu):** O app não deve abrir direto no Placar. Deve abrir em um Menu Principal com NOVO JOGO, CONFIGURAÇÕES DE PARTIDAS, CONFIGURAÇÕES DO APP, USUÁRIO, ATIVIDADE (Histórico).

### Médias (Funcionalidades de Dados)
- [ ] **Exportação:** Ajustar layout e exportação dos dados do histórico de partidas.
- [ ] **Cloud Sync:** Planejar banco de dados em nuvem.
- [ ] **Modo Foco nas Configurações:** Adicionar opção nas configurações do app para abrir atalho das configurações do sistema operacional (Android/iOS) para o usuário ativar o modo "Não Perturbe".

### Pequenas (Refinamentos UI/UX)
- [ ] **Novos Relógios:** Criar temporizador específico de "Troca de lado rápida" (ex: 90s) para o intervalo entre o 1º e 2º games do set.