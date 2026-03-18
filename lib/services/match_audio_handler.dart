import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

enum MediaCommand { next, previous, play, pause }

late MatchAudioHandler globalAudioHandler;

class MatchAudioHandler extends BaseAudioHandler with SeekHandler {
  final _commandController = StreamController<MediaCommand>.broadcast();
  
  final _player = AudioPlayer(); 

  Stream<MediaCommand> get commandStream => _commandController.stream;

  MatchAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());

    // A CORREÇÃO ESTÁ AQUI: "duration:" adicionado para agradar o compilador!
    await _player.setAudioSource(
      SilenceAudioSource(duration: const Duration(hours: 24)),
    );
    await _player.setLoopMode(LoopMode.all);
    _player.play();

    mediaItem.add(const MediaItem(
      id: 'placar_id',
      album: 'Remote Racket Score',
      title: 'Partida em Andamento',
      artist: 'Controle os pontos pelo fone/relógio',
    ));

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
    playbackState.add(playbackState.value.copyWith(playing: true));
  }

  @override
  Future<void> pause() async {
    _commandController.add(MediaCommand.pause);
    playbackState.add(playbackState.value.copyWith(playing: true)); 
  }
}