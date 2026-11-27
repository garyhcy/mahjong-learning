/// Pure tile helpers shared by the playable table and its tests.
class TileSet {
  TileSet._();

  static const List<String> suits = ['m', 's', 'p'];
  static const List<String> winds = ['east', 'south', 'west', 'north'];
  static const List<String> dragons = ['red', 'green', 'white'];
  static const List<String> flowers = [
    'f_plum',
    'f_orchid',
    'f_chrys',
    'f_bamboo',
    'f_spring',
    'f_summer',
    'f_autumn',
    'f_winter',
  ];

  static final List<String> allTileCodes = [
    for (final suit in suits)
      for (var rank = 1; rank <= 9; rank++) '$suit$rank',
    ...winds,
    ...dragons,
  ];

  static final List<String> allTilesWithFlowers = [
    ...allTileCodes,
    ...flowers,
  ];

  static bool isFlower(String code) => flowers.contains(code);

  static bool isHonor(String code) =>
      winds.contains(code) || dragons.contains(code);

  static bool isWind(String code) => winds.contains(code);

  static bool isDragon(String code) => dragons.contains(code);

  static bool isNumber(String code) =>
      code.length == 2 && suits.contains(code[0]);

  static String suitOf(String code) => code[0];

  static int rankOf(String code) => int.tryParse(code.substring(1)) ?? 0;

  static bool isTerminal(String code) =>
      isNumber(code) && (rankOf(code) == 1 || rankOf(code) == 9);

  static bool isTerminalOrHonor(String code) =>
      isTerminal(code) || isHonor(code);

  /// Seat flower mapping used by Gary's rules: East plum, South orchid,
  /// West chrysanthemum, North bamboo.
  static String seatFlowerFor(String seatWind) {
    switch (seatWind) {
      case 'east':
        return 'f_plum';
      case 'south':
        return 'f_orchid';
      case 'west':
        return 'f_chrys';
      default:
        return 'f_bamboo';
    }
  }

  static int compare(String a, String b) {
    final ai = allTilesWithFlowers.indexOf(a);
    final bi = allTilesWithFlowers.indexOf(b);
    if (ai == -1 && bi == -1) return a.compareTo(b);
    if (ai == -1) return 1;
    if (bi == -1) return -1;
    return ai.compareTo(bi);
  }

  static List<String> sortTiles(Iterable<String> tiles) {
    final out = tiles.toList();
    out.sort(compare);
    return out;
  }
}
