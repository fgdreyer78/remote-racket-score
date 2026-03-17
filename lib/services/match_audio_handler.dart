import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart'; // PACOTE NOVO: O nosso player "laranja"!

enum MediaCommand { next, previous, play, pause }

late MatchAudioHandler globalAudioHandler;

class MatchAudioHandler extends BaseAudioHandler with SeekHandler {
  final _commandController = StreamController<MediaCommand>.broadcast();
  
  // O NOSSO "LARANJA": Um player real, mas que fica mudo. 
  // Isso obriga o Android a respeitar o nosso sequestro de Bluetooth!
  final _player = AudioPlayer(); 

  Stream<MediaCommand> get commandStream => _commandController.stream;

  MatchAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 1. Configura a sessão de áudio para música
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // 2. Cria a notificação de mídia
    mediaItem.add(const MediaItem(
      id: 'placar_id',
      album: 'Remote Racket Score',
      title: 'Partida em Andamento',
      artist: 'Controle os pontos pelo fone/relógio',
    ));

    // 3. A CHAVE MESTRA DO BLUETOOTH: systemActions!
    // Sem isso, o Android bloqueia os cliques do fone.
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.play,
        MediaAction.pause,
      },
      processingState: AudioProcessingState.ready,
      playing: true,
    ));

    // Força o Android a nos dar o foco ativando a sessão
    await session.setActive(true);
  }

  @override
  Future<void> skipToNext() async {
    _commandController.add(MediaCommand.next);
  }

  @override
  Future<void> skipToPrevious() async {
    _commandController.add(MediaCommand.previous);
  }

  @override
  Future<void> play() async {
    _commandController.add(MediaCommand.play);
    // Mantemos como playing: true para o Android não matar o app
    playbackState.add(playbackState.value.copyWith(playing: true));
  }

  @override
  Future<void> pause() async {
    _commandController.add(MediaCommand.pause);
    playbackState.add(playbackState.value.copyWith(playing: true)); 
  }
}