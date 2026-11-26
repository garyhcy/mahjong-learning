import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/placement_question.dart';
import '../models/placement_questions.dart';
import '../providers/game_state.dart';
import '../services/app_i18n.dart';
import '../widgets/quiz/tile_markers.dart';

/// One-time onboarding check. Four tiers of four questions; a tier needs 3/4
/// to be skipped. The result only unlocks a starting stage — nothing is marked
/// completed.
class PlacementScreen extends StatefulWidget {
  const PlacementScreen({super.key, required this.game, required this.onDone});

  final GameState game;
  final VoidCallback onDone;

  @override
  State<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends State<PlacementScreen> {
  static const _green = Color(0xFF4CAF50);
  static const _greenDark = Color(0xFF2E7D32);
  static const _ink = Color(0xFF2D2D2D);

  final _textController = TextEditingController();
  int _index = 0;
  bool _intro = true;
  bool _finished = false;
  int _resultStage = 0;
  final Set<int> _selected = {};
  final Map<int, int> _tierCorrect = {1: 0, 2: 0, 3: 0, 4: 0};

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  PlacementQuestion get _question => placementQuestions[_index];

  int get _tier => _question.tier;

  bool get _canContinue {
    if (_question.isFill) return _textController.text.trim().isNotEmpty;
    return _selected.isNotEmpty;
  }

  void _select(int option) {
    if (_question.isMulti) {
      setState(() {
        if (!_selected.add(option)) _selected.remove(option);
      });
    } else {
      setState(() {
        _selected
          ..clear()
          ..add(option);
      });
    }
  }

  bool _isCorrect() {
    if (_question.isFill) {
      final value = _textController.text.trim().toLowerCase();
      return _question.acceptedAnswers.any(
        (answer) => answer.trim().toLowerCase() == value,
      );
    }
    if (_question.isMulti) {
      final correct = _question.correctIndexes.toSet();
      return correct.length == _selected.length &&
          correct.containsAll(_selected);
    }
    return _selected.contains(_question.correctIndex);
  }

  void _next() {
    if (!_canContinue) return;
    if (_isCorrect()) {
      _tierCorrect[_tier] = (_tierCorrect[_tier] ?? 0) + 1;
    }

    final lastOfTier =
        _index == placementQuestions.length - 1 ||
        placementQuestions[_index + 1].tier != _tier;

    if (lastOfTier && (_tierCorrect[_tier] ?? 0) < 3) {
      _finishForTier(_tier);
      return;
    }
    if (_index == placementQuestions.length - 1) {
      _finishForTier(5);
      return;
    }

    setState(() {
      _index++;
      _selected.clear();
      _textController.clear();
    });
  }

  /// [failedTier] is 1..4, or 5 when every tier passed.
  void _finishForTier(int failedTier) {
    final stageIndex = switch (failedTier) {
      1 => 0, // Stage 1
      2 => 4, // Stage 5
      3 => 7, // Stage 8
      4 => 8, // Stage 9
      _ => 9, // Stage 10 cap
    };
    _finish(stageIndex);
  }

  Future<void> _finish(int stageIndex) async {
    setState(() {
      _finished = true;
      _resultStage = stageIndex;
    });
    await widget.game.applyPlacement(stageIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();
    if (_intro) return _buildIntro();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          AppI18n.t('placement.title'),
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: () => _finish(0),
            child: Text(
              AppI18n.t('placement.skip'),
              style: GoogleFonts.nunito(
                color: const Color(0xFF6D6D6D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _buildProgress(),
              const SizedBox(height: 18),
              _buildQuestionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE7EAE3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: _greenDark,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppI18n.t('placement.title'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppI18n.t('placement.subtitle'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      height: 1.45,
                      color: const Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => setState(() => _intro = false),
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppI18n.t('placement.start'),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => _finish(0),
                    child: Text(
                      AppI18n.t('placement.newHere'),
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF6D6D6D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    final number = _index + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppI18n.t('placement.question')
                  .replaceAll('{n}', '$number')
                  .replaceAll('{m}', '${placementQuestions.length}'),
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF6D6D6D),
              ),
            ),
            const Spacer(),
            Text(
              'Level $_tier / 4',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: number / placementQuestions.length,
            minHeight: 6,
            backgroundColor: const Color(0xFFEAEEE5),
            valueColor: const AlwaysStoppedAnimation<Color>(_green),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EAE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: parseTileMarkers(
                _question.prompt,
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w700,
                tileSize: 34,
              ),
            ),
          ),
          if (_question.isMulti) ...[
            const SizedBox(height: 6),
            Text(
              AppI18n.t('placement.chooseAll'),
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_question.isFill)
            TextField(
              controller: _textController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _next(),
              decoration: InputDecoration(
                hintText: AppI18n.t('placement.typeAnswer'),
                filled: true,
                fillColor: const Color(0xFFF7F8F4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            )
          else
            ...List.generate(_question.options.length, (i) {
              final selected = _selected.contains(i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _select(i),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFEFF7ED)
                          : const Color(0xFFF7F8F4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? _green : const Color(0xFFE7EAE3),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _question.isMulti
                              ? (selected
                                    ? Icons.check_box_rounded
                                    : Icons.check_box_outline_blank_rounded)
                              : (selected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded),
                          size: 20,
                          color: selected
                              ? _greenDark
                              : const Color(0xFF9E9E9E),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: parseTileMarkers(
                                _question.options[i],
                                fontSize: 14,
                                tileSize: 26,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _canContinue ? _next : null,
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _index == placementQuestions.length - 1
                    ? AppI18n.t('placement.check')
                    : AppI18n.t('placement.continue'),
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final stage = widget.game.stages[_resultStage];
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE7EAE3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: _greenDark,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppI18n.t(
                      'placement.resultTitle',
                    ).replaceAll('{n}', '${_resultStage + 1}'),
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stage.localizedTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: stage.color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppI18n.t('placement.resultBody'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFF6D6D6D),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onDone,
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppI18n.t('placement.startHere'),
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
