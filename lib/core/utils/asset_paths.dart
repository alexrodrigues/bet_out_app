/// Typed paths for bundled assets under `lib/assets/`.
class AssetPaths {
  AssetPaths._();

  static const String paw = 'lib/assets/ic_paw.png';
  static const String bone = 'lib/assets/ic_bone.png';
  static const String goldBowl = 'lib/assets/ic_gold_bowl.png';
  static const String logoDog = 'lib/assets/ic_logo_dog.png';
  static const String gameBoard = 'lib/assets/il_game_board.png';

  /// Ordered reel symbol strip used by the simulator.
  static const List<String> reelSymbols = [
    paw,
    bone,
    goldBowl,
    logoDog,
  ];
}
