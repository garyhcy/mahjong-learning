/// Short tile codes used in quiz data.
/// m = Characters (Wan), s = Bamboo (Tiao), p = Circles (Tong)
class MahjongTile {
  MahjongTile._();

  static const _data = <String, ({String emoji, String name})>{
    'm1': (emoji: '🀇', name: '1 Characters'),
    'm2': (emoji: '🀈', name: '2 Characters'),
    'm3': (emoji: '🀉', name: '3 Characters'),
    'm4': (emoji: '🀊', name: '4 Characters'),
    'm5': (emoji: '🀋', name: '5 Characters'),
    'm6': (emoji: '🀌', name: '6 Characters'),
    'm7': (emoji: '🀍', name: '7 Characters'),
    'm8': (emoji: '🀎', name: '8 Characters'),
    'm9': (emoji: '🀏', name: '9 Characters'),
    's1': (emoji: '🀙', name: '1 Bamboo'),
    's2': (emoji: '🀚', name: '2 Bamboo'),
    's3': (emoji: '🀛', name: '3 Bamboo'),
    's4': (emoji: '🀜', name: '4 Bamboo'),
    's5': (emoji: '🀝', name: '5 Bamboo'),
    's6': (emoji: '🀞', name: '6 Bamboo'),
    's7': (emoji: '🀟', name: '7 Bamboo'),
    's8': (emoji: '🀠', name: '8 Bamboo'),
    's9': (emoji: '🀡', name: '9 Bamboo'),
    'p1': (emoji: '🀐', name: '1 Circles'),
    'p2': (emoji: '🀑', name: '2 Circles'),
    'p3': (emoji: '🀒', name: '3 Circles'),
    'p4': (emoji: '🀓', name: '4 Circles'),
    'p5': (emoji: '🀔', name: '5 Circles'),
    'p6': (emoji: '🀕', name: '6 Circles'),
    'p7': (emoji: '🀖', name: '7 Circles'),
    'p8': (emoji: '🀗', name: '8 Circles'),
    'p9': (emoji: '🀘', name: '9 Circles'),
    'east': (emoji: '🀀', name: 'East Wind'),
    'south': (emoji: '🀁', name: 'South Wind'),
    'west': (emoji: '🀂', name: 'West Wind'),
    'north': (emoji: '🀃', name: 'North Wind'),
    'red': (emoji: '🀄', name: 'Red Dragon'),
    'green': (emoji: '🀅', name: 'Green Dragon'),
    'white': (emoji: '🀆', name: 'White Dragon'),
    'f_plum': (emoji: '🀢', name: 'Plum'),
    'f_orchid': (emoji: '🀣', name: 'Orchid'),
    'f_chrys': (emoji: '🀤', name: 'Chrysanthemum'),
    'f_bamboo': (emoji: '🀥', name: 'Bamboo'),
    'f_spring': (emoji: '🀦', name: 'Spring'),
    'f_summer': (emoji: '🀧', name: 'Summer'),
    'f_autumn': (emoji: '🀨', name: 'Autumn'),
    'f_winter': (emoji: '🀩', name: 'Winter'),
  };

  static String emoji(String code) => _data[code]?.emoji ?? code;

  static String name(String code) => _data[code]?.name ?? code;

  static String label(String code) => '${name(code)} ${emoji(code)}';
}
