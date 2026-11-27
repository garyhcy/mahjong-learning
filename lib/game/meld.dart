/// A completed set on the table.
enum MeldKind { chow, pong, kong }

class Meld {
  final MeldKind kind;
  final List<String> tiles;
  final bool concealed;

  /// Seat index of the player whose discard was claimed; null for a
  /// concealed kong assembled from the player's own hand.
  final int? fromPlayer;

  const Meld({
    required this.kind,
    required this.tiles,
    this.concealed = false,
    this.fromPlayer,
  });

  int get structuralSize => 3;
}
