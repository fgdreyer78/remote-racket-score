import 'dart:async';
import 'package:audio_service/audio_service.dart';

// Este enum vai traduzir os botões do fone/relógio para o nosso app
enum MediaCommand { next, previous, play, pause }

// Nossa variável global para acessarmos o controle de qualquer lugar
late MatchAudioHandler globalAudioHandler;

class MatchAudioHandler extends BaseAudioHandler with SeekHandler {
  final _commandController = StreamController<MediaCommand>.broadcast();

  // O nosso app vai escutar esse stream para saber quando o usuário apertou um botão
  Stream<MediaCommand> get commandStream => _commandController.stream;

  MatchAudioHandler() {
    // Avisa o sistema (Android/iOS) que estamos "tocando" algo
    // Isso vai aparecer na tela de bloqueio do celular e no Smartwatch!
    mediaItem.add(const MediaItem(
      id: 'placar_id',
      album: 'Placar Esportivo',
      title: 'Partida em Andamento',
      artist: 'Controle os pontos pelo relógio',
    ));

    // Avisa ao sistema quais botões nós queremos sequestrar (Avançar e Retroceder)
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play, 
        MediaControl.pause,
        MediaControl.skipToNext,
      ],
      processingState: AudioProcessingState.ready,
      playing: true, // Finge que está tocando para o sistema não matar o app
    ));
  }

  // Quando o usuário aperta "Avançar Trilha" (ex: duplo toque no fone ou botão do smartwatch)
  @override
  Future<void> skipToNext() async {
    _commandController.add(MediaCommand.next);
  }

  // Quando o usuário aperta "Voltar Trilha"
  @override
  Future<void> skipToPrevious() async {
    _commandController.add(MediaCommand.previous);
  }

  // Quando o usuário aperta "Play"
  @override
  Future<void> play() async {
    _commandController.add(MediaCommand.play);
    playbackState.add(playbackState.value.copyWith(playing: true));
  }

  // Quando o usuário aperta "Pause"
  @override
  Future<void> pause() async {
    _commandController.add(MediaCommand.pause);
    playbackState.add(playbackState.value.copyWith(playing: false));
  }
}