import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart'; 

enum MediaCommand { next, previous, play, pause }

late MatchAudioHandler globalAudioHandler;

class MatchAudioHandler extends BaseAudioHandler with SeekHandler {
  final _commandController = StreamController<MediaCommand>.broadcast();

  Stream<MediaCommand> get commandStream => _commandController.stream;

  MatchAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 1. ROUBA O FOCO DE ÁUDIO DO ANDROID (Tira do Spotify/YouTube)
    final session = await AudioSession.instance;
    // CORREÇÃO: A palavra certa é music(), e tiramos o const pra não dar erro de versão!
    await session.configure(AudioSessionConfiguration.music());
    await session.setActive(true);

    // 2. Cria a notificação de mídia
    mediaItem.add(const MediaItem(
      id: 'placar_id',
      album: 'Remote Racket Score',
      title: 'Partida em Andamento',
      artist: 'Controle os pontos pelo fone/relógio',
    ));

    // 3. Avisa quais botões queremos sequestrar
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play, 
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      processingState: AudioProcessingState.ready,
      playing: true, 
    ));
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
    playbackState.add(playbackState.value.copyWith(playing: true));
  }

  @override
  Future<void> pause() async {
    _commandController.add(MediaCommand.pause);
    playbackState.add(playbackState.value.copyWith(playing: false));
  }
}