import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Serviço singleton para gerenciar anúncios Intersticiais do AdMob.
///
/// Uso:
/// ```dart
/// AdMobService.instance.loadAd();
/// // ... mais tarde, quando um set ou partida terminar:
/// AdMobService.instance.showAdIfAvailable();
/// ```
class AdMobService {
  AdMobService._();

  static final AdMobService instance = AdMobService._();

  /// ID de teste de Intersticial do Google.
  static const String _adUnitId = 'ca-app-pub-3940256099942544/1033173712';

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  /// Carrega um anúncio intersticial.
  /// Chame este método logo após a inicialização ou após exibir um anúncio
  /// para manter o próximo pronto.
  void loadAd() {
    if (_isLoading || _interstitialAd != null) return;

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          // Prepara o próximo anúncio quando este for exibido
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadAd(); // Auto-reload: carrega o próximo anúncio
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _isLoading = false;
              loadAd(); // Tenta carregar outro
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Exibe o anúncio intersticial se disponível.
  ///
  /// Retorna `true` se o anúncio foi exibido com sucesso, `false` caso contrário.
  /// Chame este método quando um set ou uma partida terminar.
  bool showAdIfAvailable() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      return true;
    }
    return false;
  }

  /// Libera os recursos do anúncio.
  /// Chame no dispose do app ou quando não precisar mais de anúncios.
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoading = false;
  }
}
