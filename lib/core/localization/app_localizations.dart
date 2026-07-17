import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('pt'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Bet Out',
      'welcomeMessage': 'Welcome to Bet Out',
      'homeTitle': 'Home',
      'loginTitle': 'Login',
      'loginPlaceholder': 'Sign in coming soon',
      'retry': 'Retry',
      'loading': 'Loading…',
      'comingSoon': 'Coming soon',
      'navHome': 'Home',
      'navSimulator': 'Simulator',
      'navSupport': 'Support',
      'navProfile': 'Profile',
      'sos': 'SOS',
      'sosComingSoon': 'SOS support will be available soon.',
      'balanceLabel': 'BALANCE',
      'simulatorIntent':
          'This simulator intentionally removes dopamine triggers like neon lights and celebratory sounds to show the cold mathematical reality of house edges.',
      'outcomeGridTitle': 'RANDOMIZED MATHEMATICAL OUTCOME GRID',
      'spinButton': 'SPIN (VIRTUAL \$50)',
      'spinCostHint': 'Cost per spin: \$50.00 (Virtual)',
      'spinningMessage': 'Spinning… the outcome was already decided by the house edge.',
      'spinResultWin':
          'A rare win. Even when you win, the long-run math still favors the house.',
      'spinResultLoss':
          'The algorithm forced a loss. Your virtual balance decreased. In real life, the house edge is designed to drain your wallet.',
      'hotlineMessage':
          'Need immediate help? The recovery hotline is available 24/7.',
      'callNow': 'Call Now',
      'hotlineComingSoon': 'Hotline number will be configured soon.',
      'statisticalReality': 'Statistical Reality',
      'rtpLabel': 'Return to Player (RTP)',
      'houseMarginLabel': 'House Margin',
      'avgLossPerHourLabel': 'Avg. Loss Per Hour',
      'lastFiveSessions': 'Last 5 Sessions',
      'winLossRatio': 'Win/Loss Ratio: {rate}% Win rate (Non-Cumulative)',
      'insufficientBalance': 'Not enough virtual balance to spin.',
      'simulatorLoadError': 'Unable to load simulator.',
      'simulatorSpinError': 'Unable to complete spin.',
    },
    'pt': {
      'appTitle': 'ForaDaBet',
      'welcomeMessage': 'Bem-vindo ao ForaDaBet',
      'homeTitle': 'Início',
      'loginTitle': 'Entrar',
      'loginPlaceholder': 'Login em breve',
      'retry': 'Tentar de novo',
      'loading': 'Carregando…',
      'comingSoon': 'Em breve',
      'navHome': 'Início',
      'navSimulator': 'Simulador',
      'navSupport': 'Apoio',
      'navProfile': 'Perfil',
      'sos': 'SOS',
      'sosComingSoon': 'O suporte SOS estará disponível em breve.',
      'balanceLabel': 'SALDO',
      'simulatorIntent':
          'Este simulador remove de propósito gatilhos de dopamina como neon e sons de celebração para mostrar a realidade matemática fria da margem da casa.',
      'outcomeGridTitle': 'GRADE DE RESULTADO MATEMÁTICO ALEATÓRIO',
      'spinButton': 'GIRAR (VIRTUAL \$50)',
      'spinCostHint': 'Custo por giro: \$50.00 (Virtual)',
      'spinningMessage':
          'Girando… o resultado já foi decidido pela margem da casa.',
      'spinResultWin':
          'Uma vitória rara. Mesmo quando você ganha, a matemática de longo prazo favorece a casa.',
      'spinResultLoss':
          'O algoritmo forçou uma perda. Seu saldo virtual diminuiu. Na vida real, a margem da casa é desenhada para drenar sua carteira.',
      'hotlineMessage':
          'Precisa de ajuda imediata? A linha de recuperação está disponível 24/7.',
      'callNow': 'Ligar agora',
      'hotlineComingSoon': 'O número da linha será configurado em breve.',
      'statisticalReality': 'Realidade estatística',
      'rtpLabel': 'Retorno ao jogador (RTP)',
      'houseMarginLabel': 'Margem da casa',
      'avgLossPerHourLabel': 'Perda média por hora',
      'lastFiveSessions': 'Últimas 5 sessões',
      'winLossRatio':
          'Razão ganho/perda: {rate}% taxa de vitória (não cumulativa)',
      'insufficientBalance': 'Saldo virtual insuficiente para girar.',
      'simulatorLoadError': 'Não foi possível carregar o simulador.',
      'simulatorSpinError': 'Não foi possível concluir o giro.',
    },
  };

  String _text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key]!;
  }

  String get appTitle => _text('appTitle');
  String get welcomeMessage => _text('welcomeMessage');
  String get homeTitle => _text('homeTitle');
  String get loginTitle => _text('loginTitle');
  String get loginPlaceholder => _text('loginPlaceholder');
  String get retry => _text('retry');
  String get loading => _text('loading');
  String get comingSoon => _text('comingSoon');
  String get navHome => _text('navHome');
  String get navSimulator => _text('navSimulator');
  String get navSupport => _text('navSupport');
  String get navProfile => _text('navProfile');
  String get sos => _text('sos');
  String get sosComingSoon => _text('sosComingSoon');
  String get balanceLabel => _text('balanceLabel');
  String get simulatorIntent => _text('simulatorIntent');
  String get outcomeGridTitle => _text('outcomeGridTitle');
  String get spinButton => _text('spinButton');
  String get spinCostHint => _text('spinCostHint');
  String get spinningMessage => _text('spinningMessage');
  String get spinResultWin => _text('spinResultWin');
  String get spinResultLoss => _text('spinResultLoss');
  String get hotlineMessage => _text('hotlineMessage');
  String get callNow => _text('callNow');
  String get hotlineComingSoon => _text('hotlineComingSoon');
  String get statisticalReality => _text('statisticalReality');
  String get rtpLabel => _text('rtpLabel');
  String get houseMarginLabel => _text('houseMarginLabel');
  String get avgLossPerHourLabel => _text('avgLossPerHourLabel');
  String get lastFiveSessions => _text('lastFiveSessions');
  String winLossRatio(String rate) =>
      _text('winLossRatio').replaceAll('{rate}', rate);
  String get insufficientBalance => _text('insufficientBalance');
  String get simulatorLoadError => _text('simulatorLoadError');
  String get simulatorSpinError => _text('simulatorSpinError');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
