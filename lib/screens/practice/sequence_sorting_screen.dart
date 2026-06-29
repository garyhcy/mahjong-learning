import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/practice_data.dart';
import '../../providers/practice_state.dart';

class SequenceSortingScreen extends StatefulWidget {
  const SequenceSortingScreen({super.key});

  @override
  State<SequenceSortingScreen> createState() => _SequenceSortingScreenState();
}

class _SequenceSortingScreenState extends State<SequenceSortingScreen> {
  static const int totalQuestions = 10;
  final _random = Random();

  int _currentQuestion = 0;
  int _correctCount = 0;
  final List<String> _wrongTiles = [];
  final List<String> _wrongCategories = [];

  late List<String> _correctOrder; // the correct sequence
  late List<String> _shuffledTiles; // shuffled for display
  final List<String> _userOrder = []; // user's selected order
  bool _showResult = false;
  bool _isFinished = false;
  bool _answeredCorrectly = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    // Pick a random suit and starting number
    final suits = ['m', 'p', 's'];
    final suit = suits[_random.nextInt(suits.length)];

    // Generate a sequence of 3-5 tiles
    final seqLength = 3 + _random.nextInt(3); // 3, 4, or 5
    final maxStart = 10 - seqLength;
    final start = 1 + _random.nextInt(maxStart);

    _correctOrder = List.generate(seqLength, (i) => '$suit${start + i}');
    _shuffledTiles = List.from(_correctOrder)..shuffle(_random);
    _userOrder.clear();
    _showResult = false;
    _answeredCorrectly = false;
  }

  void _selectTile(String tile) {
    if (_showResult) return;
    if (_userOrder.contains(tile)) return;
    setState(() {
      _userOrder.add(tile);
      if (_userOrder.length == _correctOrder.length) {
        _checkAnswer();
      }
    });
  }

  void _undoLast() {
    if (_userOrder.isEmpty || _showResult) return;
    setState(() {
      _userOrder.removeLast();
    });
  }

  void _checkAnswer() {
    setState(() {
      _showResult = true;
      _answeredCorrectly = _listEquals(_userOrder, _correctOrder);
      if (_answeredCorrectly) {
        _correctCount++;
      } else {
        _wrongTiles.addAll(_correctOrder);
        final cat = getTileCategory(_correctOrder.first);
        _wrongCategories.add(cat.name);
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _currentQuestion++;
        if (_currentQuestion >= totalQuestions) {
          _isFinished = true;
          _saveResult();
        } else {
          _generateQuestion();
        }
      });
    });
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _saveResult() {
    final practiceState = context.read<PracticeState>();
    practiceState.recordResult(PracticeResult(
      drillType: 'sorting',
      totalQuestions: totalQuestions,
      correctAnswers: _correctCount,
      wrongTiles: _wrongTiles,
      wrongCategories: _wrongCategories,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sequence Sorting',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _currentQuestion / totalQuestions,
            backgroundColor: const Color(0xFFE8E8E8),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8B93E)),
          ),
        ),
      ),
      body: _isFinished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Question ${_currentQuestion + 1} of $totalQuestions',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap tiles in ascending order',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arrange from smallest to largest',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 28),
            // User's selected order (answer area)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _showResult
                      ? (_answeredCorrectly
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935))
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your order:',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                      if (_userOrder.isNotEmpty && !_showResult)
                        GestureDetector(
                          onTap: _undoLast,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.undo,
                                    size: 14, color: Color(0xFFE8B93E)),
                                const SizedBox(width: 4),
                                Text(
                                  'Undo',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE8B93E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: _userOrder.isEmpty
                        ? Center(
                            child: Text(
                              'Tap tiles below to arrange them',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: const Color(0xFFBDBDBD),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _userOrder.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final tile = entry.value;
                              final isCorrectPos = _showResult &&
                                  idx < _correctOrder.length &&
                                  tile == _correctOrder[idx];
                              final isWrongPos = _showResult && !isCorrectPos;

                              return Container(
                                width: 52,
                                height: 70,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isCorrectPos
                                        ? const Color(0xFF4CAF50)
                                        : isWrongPos
                                            ? const Color(0xFFE53935)
                                            : const Color(0xFFE8B93E),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Image.asset(
                                    'assets/tiles/$tile.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
            if (_showResult) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _answeredCorrectly ? Icons.check_circle : Icons.cancel,
                    color: _answeredCorrectly
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE53935),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _answeredCorrectly ? 'Correct!' : 'Wrong order',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _answeredCorrectly
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            // Available tiles to pick
            Text(
              'Available tiles:',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _shuffledTiles.map((tile) {
                    final isUsed = _userOrder.contains(tile);
                    return GestureDetector(
                      onTap: isUsed ? null : () => _selectTile(tile),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isUsed ? 0.3 : 1.0,
                        child: Container(
                          width: 64,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isUsed
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFE8B93E),
                              width: 2,
                            ),
                            boxShadow: isUsed
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFE8B93E)
                                          .withAlpha(30),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(
                              'assets/tiles/$tile.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final accuracy = _correctCount / totalQuestions;
    final percentage = (accuracy * 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 80
                  ? Icons.emoji_events_rounded
                  : percentage >= 50
                      ? Icons.thumb_up_rounded
                      : Icons.refresh_rounded,
              size: 72,
              color: percentage >= 80
                  ? const Color(0xFFE8B93E)
                  : percentage >= 50
                      ? const Color(0xFFE8B93E)
                      : const Color(0xFFE53935),
            ),
            const SizedBox(height: 24),
            Text(
              percentage >= 80
                  ? 'Excellent!'
                  : percentage >= 50
                      ? 'Good Job!'
                      : 'Keep Practicing!',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_correctCount / $totalQuestions correct ($percentage%)',
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE8B93E)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE8B93E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestion = 0;
                        _correctCount = 0;
                        _wrongTiles.clear();
                        _wrongCategories.clear();
                        _isFinished = false;
                        _generateQuestion();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B93E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
