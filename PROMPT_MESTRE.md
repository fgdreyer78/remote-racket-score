RELATÓRIO MESTRE - REMOTE RACKET SCORE

Data da última atualização: Março de 2026
1. Visão Geral do Projeto

Aplicativo multi-idiomas (inglês e português) que visa dar um ar de profissionalismo a partidas amadoras de esportes de raquete (Tênis, Beach Tennis, Padel).
Facilita a contagem e registro de pontos de forma remota (fone Bluetooth, Smartwatch, Cam Shutter).
2. Índice e Estrutura de Pastas (Onde está o quê)

    android/app/src/main/kotlin/.../MainActivity.kt: O Buraco Negro Nativo. Código em Kotlin (AudioServiceActivity) que intercepta botões físicos do celular (Up/Down) antes da UI do Android, passando pelo MethodChannel.

    lib/features/: Telas visuais do usuário.

        /score/score_screen.dart: Tela principal do placar (gestos, modo imersivo, relógios gigantes). Sincroniza a exibição do menu com o bloqueio nativo de volume.

        /settings/settings_screen.dart: Menu de regras, tiebreak e temporizadores (agora limpo de variáveis legadas).

        /button_mapping/button_mapping_screen.dart: Tela para mapear cliques (1, 2, 3) a funções do placar.

        /history/history_screen.dart: Tela do histórico (Atividade).

    lib/services/: Lógica pesada, sistema e hardwares.

        match_audio_handler.dart: O "Laranja" de Áudio. Usa just_audio (silêncio 24h) para roubar comandos de fone/smartwatch.

        key_event_service.dart: O Cérebro Físico. Ouve o MethodChannel do Kotlin, ouve teclas normais e faz a matemática do timer de 1, 2 e 3 cliques (com debounce integrado).

        tts_service.dart: O Narrador (Text-to-Speech).

    lib/providers/: Gerenciadores de estado (Riverpod). Mantém a memória ativa do app.

    lib/models/: Regras de negócio, placar (score_state.dart), e configuração (game_config.dart).

3. Conquistas Atuais (O QUE JÁ FUNCIONA)

    Motor de Áudio e Bluetooth (Universal): Intercepta comandos AVRCP universais (Next/Prev/Pause).

    Bloqueio Nativo Volume Down (Cam Shutter): Integração Kotlin <-> Dart funcionando perfeitamente. Botão de diminuir volume pontua (1, 2 ou 3 cliques) sem exibir a barra de volume da Samsung na tela de placar, e volta ao normal nos menus.

    Lógica de Cliques e Pontuação Local: O motor físico (via KeyEventService) traduz teclas locais e comandos do Kotlin para 1, 2 ou 3 cliques, respeitando a pontuação.

    UI Imersiva e Gestos: Tela cheia absoluta. Menu superior flutuante que sobe e desce com gestos (_toggleMenu), ativando e desativando o "Buraco Negro" nativo de forma dinâmica. Relógios gigantes e independentes.

4. Regras de Ouro para o Gemini

    NUNCA altere o motor de áudio ou os serviços sem extrema necessidade.

    NUNCA reescreva arquivos inteiros. Use "Cirurgia a Laser".

    Sempre peça o código-fonte atual da tela ANTES de sugerir modificações e indique exatamente onde os novos códigos devem ser colados (pastas, arquivos e linhas de código).

    Respeite a integração nativa atual (MainActivity.kt + MethodChannel). Não sugira pacotes de controle de volume (perfect_volume_control, etc.) para substituir o que já construímos no Kotlin.

5. Backlog de Pendências (O que falta fazer)

    [ ] A Grande Batalha (Volume Up & Initial Load): 1. O botão Volume Up ainda exibe a barra da Samsung e exige um clique inútil inicial, diferente do Volume Down que está perfeito.
    2. Ao carregar o app pela PRIMEIRA VEZ (que cai direto no placar), o bloqueio não ativa automaticamente; só ativa após ir e voltar de um menu.

    [ ] Nova Navegação (Main Menu): O app não deve abrir direto no Placar.

    [ ] Exportação: Ajustar layout e exportação dos dados do histórico.

    [ ] Modo Foco nas Configurações: Atalho para ativar "Não Perturbe".

    [ ] Novos Relógios: Temporizador de "Troca de lado rápida" (ex: 90s) para o intervalo entre 1º e 2º games.