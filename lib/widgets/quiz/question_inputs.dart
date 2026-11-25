import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/mahjong_data.dart';
import '../../services/app_i18n.dart';
import '../mahjong_tile.dart';
import 'tile_markers.dart';

const Color _green = Color(0xFF4CAF50);
const Color _greenDark = Color(0xFF2E7D32);
const Color _bgCorrect = Color(0xFFE8F5E9);
const Color _bgWrong = Color(0xFFFFEBEE);
const Color _borderIdle = Color(0xFFE0E0E0);
const Color _textDark = Color(0xFF2D2D2D);
const Color _textMuted = Color(0xFFBDBDBD);

/// Everything a question widget needs from the screen: the current answer
/// state plus the callbacks that change it. Widgets stay stateless (except
/// where a text controller is unavoidable) so one submit path serves every
/// question type.
class QuestionInputConfig {
  /// Selected option indices (choice and tile-selection questions).
  final Set<int> selected;

  /// Current drag order of tiles (tile-ordering questions).
  final List<String> orderingTiles;

  /// Free text typed so far (fill-in-the-blank questions).
  final String answerText;

  /// Left item -> right item connected so far (matching questions).
  final Map<String, String> matches;

  /// True once the answer has been submitted and feedback is on screen.
  final bool feedbackActive;

  /// Whether the submitted answer was correct. Null while unanswered.
  final bool? feedbackCorrect;

  /// Index of the option currently pressed, for the press animation.
  final int? pressedOption;

  final ValueChanged<int> onOptionTap;
  final ValueChanged<int?> onPressedOption;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<String> onTextChanged;
  final void Function(String left, String right) onMatch;
  final VoidCallback onSubmit;

  const QuestionInputConfig({
    required this.selected,
    required this.orderingTiles,
    required this.answerText,
    required this.matches,
    required this.feedbackActive,
    required this.feedbackCorrect,
    required this.pressedOption,
    required this.onOptionTap,
    required this.onPressedOption,
    required this.onReorder,
    required this.onTextChanged,
    required this.onMatch,
    required this.onSubmit,
  });
}

/// The shared contract of every question type's input area: it knows its
/// question, the answer state, and whether the answer is ready to submit.
abstract class QuestionInput {
  QuizQuestion get question;
  QuestionInputConfig get config;

  /// Whether the submit button should be enabled.
  bool get canSubmit;
}

/// Builds the input area for [question]'s type. The single place that maps a
/// [QuizType] to a widget, so adding a type means adding one line here.
Widget buildQuestionInput({
  required QuizQuestion question,
  required QuestionInputConfig config,
}) {
  switch (question.type) {
    case QuizType.tileOrdering:
      return TileOrderingInput(question: question, config: config);
    case QuizType.tileSelection:
      return ChoiceInput(question: question, config: config, showTiles: true);
    case QuizType.fillBlank:
      return FillBlankInput(question: question, config: config);
    case QuizType.matching:
      return MatchingInput(question: question, config: config);
    case QuizType.multiChoice:
      return ChoiceInput(question: question, config: config, multiSelect: true);
    case QuizType.singleChoice:
      return ChoiceInput(question: question, config: config);
  }
}

/// Options list shared by single choice, multi choice and tile selection.
class ChoiceInput extends StatelessWidget implements QuestionInput {
  @override
  final QuizQuestion question;
  @override
  final QuestionInputConfig config;

  /// Multi-select questions toggle options instead of replacing the choice.
  final bool multiSelect;

  /// Tile-selection questions render each option as a mahjong tile.
  final bool showTiles;

  const ChoiceInput({
    super.key,
    required this.question,
    required this.config,
    this.multiSelect = false,
    this.showTiles = false,
  });

  @override
  bool get canSubmit => config.selected.isNotEmpty && !config.feedbackActive;

  @override
  Widget build(BuildContext context) {
    final correctIndexes = question.allCorrectIndexes.toSet();

    return Column(
      children: [
        ...question.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isSelected = config.selected.contains(idx);
          final feedback = config.feedbackActive;
          final correct = config.feedbackCorrect;
          final isCorrectOption = correctIndexes.contains(idx);

          Color bgColor;
          Color borderColor;
          if (feedback) {
            if (isSelected && correct == true) {
              bgColor = _bgCorrect;
              borderColor = _greenDark;
            } else if (isSelected && correct == false) {
              bgColor = _bgWrong;
              borderColor = _green;
            } else if (isCorrectOption && correct == false) {
              bgColor = _bgCorrect;
              borderColor = _greenDark;
            } else {
              bgColor = Colors.white;
              borderColor = _borderIdle;
            }
          } else {
            bgColor = isSelected ? _bgCorrect : Colors.white;
            borderColor = isSelected ? _green : _borderIdle;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AnimatedScale(
              scale: config.pressedOption == idx ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: GestureDetector(
                onTapDown:
                    feedback ? null : (_) => config.onPressedOption(idx),
                onTapUp: feedback ? null : (_) => config.onPressedOption(null),
                onTapCancel: () => config.onPressedOption(null),
                onTap: feedback ? null : () => config.onOptionTap(idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected || feedback ? 2 : 1,
                    ),
                    boxShadow: isSelected && !feedback
                        ? [
                            BoxShadow(
                              color: _green.withAlpha(20),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: showTiles
                      ? Row(
                          children: [
                            MahjongTile(tileId: option, size: 48),
                            const Spacer(),
                            if (feedback && isCorrectOption)
                              const Icon(Icons.check_circle_rounded,
                                  color: _greenDark, size: 20),
                            if (feedback && isSelected && correct == false)
                              const Icon(Icons.cancel_rounded,
                                  color: _green, size: 20),
                          ],
                        )
                      : Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? _green.withAlpha(40)
                                      : _borderIdle,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                _SelectionMark(
                                    isSelected: isSelected,
                                    multiSelect: multiSelect),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: parseTileMarkers(
                                        option,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: feedback &&
                                                !isSelected &&
                                                !isCorrectOption
                                            ? _textMuted
                                            : _textDark,
                                      ),
                                    ),
                                  ),
                                ),
                                if (feedback && isCorrectOption)
                                  const Icon(Icons.check_circle_rounded,
                                      color: _greenDark, size: 20),
                                if (feedback && isSelected && correct == false)
                                  const Icon(Icons.cancel_rounded,
                                      color: _green, size: 20),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SubmitButton(
          label: 'Submit Answer',
          onPressed: canSubmit ? config.onSubmit : null,
        ),
      ],
    );
  }
}

/// Tick / radio circle shown before each option.
class _SelectionMark extends StatelessWidget {
  final bool isSelected;
  final bool multiSelect;

  const _SelectionMark({required this.isSelected, required this.multiSelect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: multiSelect ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: multiSelect ? BorderRadius.circular(6) : null,
        color: isSelected ? _green : Colors.transparent,
        border: Border.all(
          color: isSelected ? _green : _textMuted,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }
}

/// Green submit button used by every question type.
class SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: _borderIdle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Drag the tiles into the right order.
class TileOrderingInput extends StatelessWidget implements QuestionInput {
  @override
  final QuizQuestion question;
  @override
  final QuestionInputConfig config;

  const TileOrderingInput({
    super.key,
    required this.question,
    required this.config,
  });

  @override
  bool get canSubmit => !config.feedbackActive && config.orderingTiles.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final tiles = config.orderingTiles;
    final tileSize = tiles.length <= 3 ? 88.0 : tiles.length <= 4 ? 80.0 : 72.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8B93E).withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.drag_indicator_rounded,
                  color: Color(0xFFE8B93E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppI18n.t('quiz.tileOrdering.instruction'),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF8D6E00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5EC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8D5C0)),
          ),
          child: config.feedbackActive
              ? _OrderingResult(question: question, userOrder: tiles)
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tiles.length,
                  onReorderItem: config.onReorder,
                  proxyDecorator: (child, index, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final scale = 1.0 + (animation.value * 0.08);
                        return Transform.scale(
                          scale: scale,
                          child: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(8),
                            shadowColor: Colors.black38,
                            child: child,
                          ),
                        );
                      },
                      child: child,
                    );
                  },
                  buildDefaultDragHandles: true,
                  itemBuilder: (context, index) {
                    final tile = tiles[index];
                    return Container(
                      key: Key('tile_$tile'),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MahjongTile(tileId: tile, size: tileSize),
                        ],
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        SubmitButton(
          label: AppI18n.t('quiz.tileOrdering.submit'),
          onPressed: config.feedbackActive ? null : config.onSubmit,
        ),
      ],
    );
  }
}

/// Shows the user's order against the correct one after submitting.
class _OrderingResult extends StatelessWidget {
  final QuizQuestion question;
  final List<String> userOrder;

  const _OrderingResult({required this.question, required this.userOrder});

  @override
  Widget build(BuildContext context) {
    final correctOrder = question.tiles ?? const <String>[];

    return Column(
      children: List.generate(userOrder.length, (index) {
        final userTile = userOrder[index];
        final correctTile =
            correctOrder.length > index ? correctOrder[index] : '';
        final isCorrect = userTile == correctTile;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCorrect ? _bgCorrect : _bgWrong,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect ? _greenDark : _green,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect ? _greenDark : _green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              MahjongTile(tileId: userTile, size: 72, isCorrect: isCorrect),
              if (!isCorrect) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 8),
                MahjongTile(tileId: correctTile, size: 72, isCorrect: true),
              ],
              const SizedBox(width: 10),
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? _greenDark : _green,
                size: 22,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Type the answer into a text field; comparison ignores case and spacing.
class FillBlankInput extends StatefulWidget implements QuestionInput {
  @override
  final QuizQuestion question;
  @override
  final QuestionInputConfig config;

  const FillBlankInput({
    super.key,
    required this.question,
    required this.config,
  });

  @override
  bool get canSubmit =>
      !config.feedbackActive && config.answerText.trim().isNotEmpty;

  @override
  State<FillBlankInput> createState() => _FillBlankInputState();
}

class _FillBlankInputState extends State<FillBlankInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.config.answerText);
  }

  @override
  void didUpdateWidget(covariant FillBlankInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The screen clears the answer after each question; mirror that here
    // without fighting the user's cursor while they type.
    if (widget.config.answerText.isEmpty && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final feedback = config.feedbackActive;
    final correct = config.feedbackCorrect;
    final accepted = widget.question.acceptedAnswers;
    final correctText = (accepted != null && accepted.isNotEmpty)
        ? accepted.first
        : (widget.question.correctIndex >= 0 &&
                widget.question.correctIndex < widget.question.options.length)
            ? widget.question.options[widget.question.correctIndex]
            : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: !feedback,
          textInputAction: TextInputAction.done,
          onChanged: config.onTextChanged,
          onSubmitted: (_) {
            if (widget.canSubmit) config.onSubmit();
          },
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
          decoration: InputDecoration(
            hintText: 'Type your answer',
            hintStyle: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
            filled: true,
            fillColor: feedback
                ? (correct == true ? _bgCorrect : _bgWrong)
                : Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: feedback ? (correct == true ? _greenDark : _green) : _borderIdle,
                width: feedback ? 2 : 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: feedback ? (correct == true ? _greenDark : _green) : _borderIdle,
                width: feedback ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _green, width: 2),
            ),
          ),
        ),
        if (feedback && correct == false) ...[
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Correct answer: ',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _greenDark,
                  ),
                ),
                TextSpan(
                  text: correctText,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        SubmitButton(
          label: 'Submit Answer',
          onPressed: widget.canSubmit ? config.onSubmit : null,
        ),
      ],
    );
  }
}

/// Connect every left item with one right item.
class MatchingInput extends StatelessWidget implements QuestionInput {
  @override
  final QuizQuestion question;
  @override
  final QuestionInputConfig config;

  const MatchingInput({
    super.key,
    required this.question,
    required this.config,
  });

  List<String> get _rightItems {
    final seen = <String>[];
    for (final pair in question.pairs ?? const <QuestionPair>[]) {
      if (!seen.contains(pair.right)) seen.add(pair.right);
    }
    return seen;
  }

  @override
  bool get canSubmit {
    final pairs = question.pairs ?? const <QuestionPair>[];
    if (pairs.isEmpty || config.feedbackActive) return false;
    return pairs.every((p) => config.matches.containsKey(p.left));
  }

  @override
  Widget build(BuildContext context) {
    final pairs = question.pairs ?? const <QuestionPair>[];
    final rights = _rightItems;
    final feedback = config.feedbackActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE8B93E).withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.swap_horiz_rounded,
                  color: Color(0xFFE8B93E), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap the matching item on the right of each row.',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: const Color(0xFF8D6E00),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...pairs.map((pair) {
          final chosen = config.matches[pair.left];
          final isRight = chosen != null &&
              chosen.toLowerCase() == pair.right.toLowerCase();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: feedback
                    ? (isRight ? _greenDark : _green)
                    : (chosen != null ? _green : _borderIdle),
                width: feedback || chosen != null ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: parseTileMarkers(
                            pair.left,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    if (feedback)
                      Icon(
                        isRight ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 20,
                        color: isRight ? _greenDark : _green,
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: rights.map((right) {
                    final selected = chosen == right;
                    final showCorrect =
                        feedback && right.toLowerCase() == pair.right.toLowerCase();
                    return GestureDetector(
                      onTap: feedback
                          ? null
                          : () => config.onMatch(pair.left, right),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: showCorrect
                              ? _bgCorrect
                              : selected
                                  ? _bgCorrect
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: showCorrect || selected ? _greenDark : _borderIdle,
                            width: showCorrect || selected ? 2 : 1,
                          ),
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: parseTileMarkers(
                              right,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: showCorrect || selected
                                  ? _greenDark
                                  : _textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        SubmitButton(
          label: 'Submit Answer',
          onPressed: canSubmit ? config.onSubmit : null,
        ),
      ],
    );
  }
}
