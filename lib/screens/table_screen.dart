import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/faan_calculator.dart';
import '../game/meld.dart';
import '../game/table_ai.dart';
import '../game/table_controller.dart';
import '../game/table_engine.dart';
import '../services/app_i18n.dart';
import '../services/audio_service.dart';
import '../widgets/mahjong_tile.dart';

String _t(String key, [Map<String, String>? params]) {
  var value = AppI18n.t(key);
  params?.forEach((k, v) => value = value.replaceAll('{$k}', v));
  return value;
}

class TableScreen extends StatefulWidget {
  const TableScreen({super.key, this.seed});

  final int? seed;

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  late final TableController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TableController(seed: widget.seed);
    _controller.addListener(_onChanged);
    _controller.startNewHand();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = _controller.engine;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E5),
      body: SafeArea(
        child: engine.phase == TablePhase.finished
            ? _ResultView(
                engine: engine,
                onPlayAgain: _controller.startNewHand,
                onBack: () => Navigator.of(context).pop(),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 700;
                  return Column(
                    children: [
                      _Header(
                        wall: engine.wall.length,
                        compact: compact,
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      _OpponentRow(engine: engine, compact: compact),
                      Expanded(child: _TableBoard(engine: engine, compact: compact)),
                      if (_controller.hasHumanClaim)
                        _ClaimBar(controller: _controller),
                      _HandArea(controller: _controller, compact: compact),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.wall,
    required this.compact,
    required this.onBack,
  });

  final int wall;
  final bool compact;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.close_rounded),
            tooltip: AppI18n.t('table.back'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppI18n.t('table.title'),
                  style: GoogleFonts.nunito(
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF244A36),
                  ),
                ),
                if (!compact)
                  Text(
                    AppI18n.t('table.subtitle'),
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: const Color(0xFF6E7E72),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5DAC5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.grid_view_rounded,
                    size: 15, color: Color(0xFF56A85C)),
                const SizedBox(width: 6),
                Text(
                  '${AppI18n.t('table.wall')} $wall',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A5A4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpponentRow extends StatelessWidget {
  const _OpponentRow({required this.engine, required this.compact});

  final TableEngine engine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 20),
      child: Row(
        children: [
          for (final seat in [1, 2, 3])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _OpponentPanel(
                  player: engine.players[seat],
                  active: engine.currentPlayer == seat,
                  compact: compact,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OpponentPanel extends StatelessWidget {
  const _OpponentPanel({
    required this.player,
    required this.active,
    required this.compact,
  });

  final TablePlayer player;
  final bool active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = active ? const Color(0xFF56A85C) : const Color(0xFF9E8F7A);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 9,
      ),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF0F8EF) : const Color(0xFFFBF8F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? accent : const Color(0xFFE8DFCE),
          width: active ? 1.8 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            active ? Icons.psychology_alt_rounded : Icons.smart_toy_outlined,
            size: compact ? 16 : 20,
            color: accent,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.seatWind.toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: compact ? 10 : 12,
                    fontWeight: FontWeight.w800,
                    color: accent,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  '${player.hand.length} tiles · ${player.melds.length} ${player.melds.length == 1 ? 'meld' : 'melds'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: compact ? 9 : 11,
                    color: const Color(0xFF7E8B80),
                  ),
                ),
              ],
            ),
          ),
          if (player.flowers.isNotEmpty)
            Text(
              '🌸${player.flowers.length}',
              style: TextStyle(fontSize: compact ? 9 : 11),
            ),
        ],
      ),
    );
  }
}

class _TableBoard extends StatelessWidget {
  const _TableBoard({required this.engine, required this.compact});

  final TableEngine engine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 8 : 28, 6, compact ? 8 : 28, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2E6B50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF24553F), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          return Stack(
            children: [
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: _RiverRow(
                  player: engine.players[3],
                  engine: engine,
                  align: WrapAlignment.center,
                  compact: compact,
                ),
              ),
              Positioned(
                top: c.maxHeight * 0.28,
                left: 6,
                child: _RiverColumn(
                  player: engine.players[2],
                  compact: compact,
                ),
              ),
              Positioned(
                top: c.maxHeight * 0.28,
                right: 6,
                child: _RiverColumn(
                  player: engine.players[1],
                  compact: compact,
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: _RiverRow(
                  player: engine.players[0],
                  engine: engine,
                  align: WrapAlignment.center,
                  compact: compact,
                ),
              ),
              Center(
                child: _CenterTable(engine: engine, compact: compact),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RiverRow extends StatelessWidget {
  const _RiverRow({
    required this.player,
    required this.engine,
    required this.align,
    required this.compact,
  });

  final TablePlayer player;
  final TableEngine engine;
  final WrapAlignment align;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final shown = player.discards.length > 8
        ? player.discards.sublist(player.discards.length - 8)
        : player.discards;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.seatWind.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: compact ? 8 : 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withAlpha(150),
            letterSpacing: 1,
          ),
        ),
        SizedBox(
          height: compact ? 24 : 27,
          child: Wrap(
            alignment: align,
            spacing: 1,
            runSpacing: 1,
            children: [
              for (final tile in shown)
                MahjongTile(tileId: tile, size: compact ? 16 : 19),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiverColumn extends StatelessWidget {
  const _RiverColumn({required this.player, required this.compact});

  final TablePlayer player;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final shown = player.discards.length > 6
        ? player.discards.sublist(player.discards.length - 6)
        : player.discards;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          player.seatWind[0].toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white.withAlpha(150),
          ),
        ),
        for (var i = 0; i < shown.length; i += 2)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var j = i; j < i + 2 && j < shown.length; j++)
                MahjongTile(tileId: shown[j], size: compact ? 15 : 17),
            ],
          ),
      ],
    );
  }
}

class _CenterTable extends StatelessWidget {
  const _CenterTable({required this.engine, required this.compact});

  final TableEngine engine;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isHuman = engine.currentPlayer == 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isHuman && engine.phase == TablePhase.playing
              ? AppI18n.t('table.yourTurn')
              : _t('table.thinking', {'seat': engine.current.seatWind}),
          style: GoogleFonts.nunito(
            fontSize: compact ? 10 : 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withAlpha(210),
          ),
        ),
        const SizedBox(height: 4),
        if (engine.lastDiscard != null)
          MahjongTile(tileId: engine.lastDiscard!, size: compact ? 34 : 44)
        else
          const Icon(Icons.casino_outlined, size: 40, color: Colors.white38),
      ],
    );
  }
}

class _HandArea extends StatelessWidget {
  const _HandArea({required this.controller, required this.compact});

  final TableController controller;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final engine = controller.engine;
    final player = engine.players[0];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBF8F1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(top: BorderSide(color: Color(0xFFE8DFCE))),
      ),
      padding: EdgeInsets.fromLTRB(compact ? 8 : 20, 6, compact ? 8 : 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${AppI18n.t('table.hand')} · ${player.seatWind.toUpperCase()}',
                style: GoogleFonts.nunito(
                  fontSize: compact ? 11 : 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E4A3A),
                ),
              ),
              const Spacer(),
              if (player.flowers.isNotEmpty)
                Text(
                  '${AppI18n.t('table.flowers')}: ${player.flowers.length}',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: const Color(0xFF7E8B80),
                  ),
                ),
            ],
          ),
          if (player.melds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 3,
                children: [
                  for (final meld in player.melds)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          switch (meld.kind) {
                            MeldKind.chow => 'CHOW',
                            MeldKind.pong => 'PONG',
                            MeldKind.kong => 'KONG',
                          },
                          style: GoogleFonts.nunito(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF7E8B80),
                          ),
                        ),
                        const SizedBox(width: 3),
                        for (final tile in meld.tiles)
                          MahjongTile(tileId: tile, size: compact ? 20 : 25),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 0,
              runSpacing: 2,
              children: [
                for (final tile in player.hand)
                  GestureDetector(
                    onTap: controller.canDiscard
                        ? () {
                            AudioService().playTileClick();
                            controller.selectTile(tile);
                          }
                        : null,
                    child: MahjongTile(
                      tileId: tile,
                      size: compact ? 28 : 38,
                      highlighted: controller.selectedTile == tile,
                    ),
                  ),
              ],
            ),
          ),
          if (controller.canDeclareWin || controller.canDiscard)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (controller.canDeclareWin)
                    FilledButton.icon(
                      onPressed: () {
                        AudioService().playCorrect();
                        controller.declareSelfDraw();
                      },
                      icon: const Icon(Icons.emoji_events_rounded, size: 17),
                      label: Text(AppI18n.t('table.declareWin')),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFD49B22),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (controller.canDeclareWin && controller.canDiscard)
                    const SizedBox(width: 10),
                  if (controller.canDiscard)
                    FilledButton(
                      onPressed: controller.selectedTile == null
                          ? null
                          : () {
                              AudioService().playTileClick();
                              controller.discardSelected();
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF56A85C),
                      ),
                      child: Text(
                        controller.selectedTile == null
                            ? AppI18n.t('table.discard')
                            : '${AppI18n.t('table.discard')} ${controller.selectedTile}',
                      ),
                    ),
                ],
              ),
            ),
          if (!controller.canDiscard && !controller.canDeclareWin)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _t('table.thinking', {'seat': engine.current.seatWind}),
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: const Color(0xFF7E8B80),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClaimBar extends StatelessWidget {
  const _ClaimBar({required this.controller});

  final TableController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF6DF),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppI18n.t('table.claim'),
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF6B4E16),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in controller.humanClaims)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilledButton(
                      onPressed: () {
                        AudioService().playTileClick();
                        controller.claim(option);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: option.isWin
                            ? const Color(0xFFD49B22)
                            : const Color(0xFF56A85C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      child: Text(_claimLabel(option)),
                    ),
                  ),
                OutlinedButton(
                  onPressed: controller.passClaim,
                  child: Text(AppI18n.t('table.pass')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _claimLabel(ClaimOption option) {
    if (option.isWin) {
      return '${AppI18n.t('table.win')} ${option.score?.faan ?? 0} '
          '${AppI18n.t('table.faan').replaceAll('{n} ', '')}';
    }
    final name = switch (option.meld) {
      MeldKind.pong => AppI18n.t('table.pong'),
      MeldKind.kong => AppI18n.t('table.kong'),
      MeldKind.chow => AppI18n.t('table.chow'),
      null => '',
    };
    return '$name ${option.tiles.join(' ')}';
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.engine,
    required this.onPlayAgain,
    required this.onBack,
  });

  final TableEngine engine;
  final VoidCallback onPlayAgain;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final draw = engine.isDraw;
    final won = engine.winnerIndex == 0;
    final winner = engine.winnerIndex == null
        ? null
        : engine.players[engine.winnerIndex!];
    final score = engine.winScore;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                draw
                    ? Icons.waves_rounded
                    : won
                        ? Icons.emoji_events_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                size: 52,
                color: won
                    ? const Color(0xFFD49B22)
                    : const Color(0xFF6D8E76),
              ),
              const SizedBox(height: 8),
              Text(
                draw
                    ? AppI18n.t('table.draw')
                    : won
                        ? AppI18n.t('table.youWin')
                        : _t('table.aiWins', {'seat': winner?.seatWind.toUpperCase() ?? ''}),
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF244A36),
                ),
                textAlign: TextAlign.center,
              ),
              if (draw)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    AppI18n.t('table.drawDesc'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF6E7E72),
                    ),
                  ),
                ),
              if (!draw && score != null) ...[
                const SizedBox(height: 8),
                Text(
                  _t('table.faan', {'n': '${score.faan}'}),
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF56A85C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  engine.selfDraw
                      ? _t('table.selfDraw', {'n': '${score.selfDrawEach}'})
                      : _t('table.discardWin', {'seat': engine.players[engine.lastDiscarder ?? 0].seatWind.toUpperCase(), 'n': '${score.discardPayout}'}),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF526357),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final pattern in score.patterns)
                      Chip(
                        label: Text(
                          '${AppI18n.current == DisplayLang.zh ? pattern.zh : pattern.en} '
                          '+${pattern.faan}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (engine.winningTile != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        engine.selfDraw
                            ? AppI18n.t('table.win')
                            : AppI18n.t('table.lastDiscard'),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF6E7E72),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MahjongTile(tileId: engine.winningTile!, size: 38),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 22),
              FilledButton(
                onPressed: onPlayAgain,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF56A85C),
                ),
                child: Text(AppI18n.t('table.playAgain')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onBack,
                child: Text(AppI18n.t('table.back')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
