import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/practice_data.dart';
import '../../providers/practice_state.dart';

class TileMatchingScreen extends StatefulWidget {
  const TileMatchingScreen({super.key});

  @override
  State<TileMatchingScreen> createState() => _TileMatchingScreenState();
}

class _TileMatchingScreenState extends State<TileMatchingScreen> {
  static const int totalQuestions = 8;
  final _random = Random();

  int _currentQuestion = 0;
  int _correctCount = 0;
  final List<String> _wrongTiles = [];
  final List<String> _wrongCategories = [];

  late String _targetTile;
  late TileCategory _targetCategory;
  late List<String> _choices; // 6 tiles to pick from
  late Set<String> _correctChoices; // tiles that match
  final Set<int> _selectedIndices = {};
  bool _showResult = false;
  bool _isFinished = false;
  bool _answeredCorrectly = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    // Pick a random category
    final categories = [
      TileCategory.characters,
      TileCategory.circles,
      TileCategory.bamboo,
      TileCategory.winds,
      TileCategory.dragons,
    ];
    _targetCategory = categories[_random.nextInt(categories.length)];

    // Get tiles in this category
    final categoryTiles = allTileCodes
        .where((t) => getTileCategory(t) == _targetCategory)
        .toList();

    // Pick a target tile from this category
    _targetTile = categoryTiles[_random.nextInt(categoryTiles.length)];

    // Pick 2 more from same category (correct matches)
    final otherSameCategory =
        categoryTiles.where((t) => t != _targetTile).toList();
    otherSameCategory.shuffle(_random);
    final correctOthers = otherSameCategory.take(2).toList();

    // Pick 3 from different categories (wrong)
    final wrongTiles = allTileCodes
        .where((t) => getTileCategory(t) != _targetCategory)
        .toList();
    wrongTiles.shuffle(_random);
    final wrongChoices = wrongTiles.take(3).toList();

    _choices = [...correctOthers, ...wrongChoices];
    _choices.shuffle(_random);
    _correctChoices = correctOthers.toSet();

    _selectedIndices.clear();
    _showResult = false;
    _answeredCorrectly = false;
  }

  void _toggleSelection(int index) {
    if (_showResult) return;
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _submitAnswer() {
    if (_selectedIndices.isEmpty) return;
    setState(() {
      _showResult = true;
      // Check if selected tiles are all from the same category
      final selectedTiles =
          _selectedIndices.map((i) => _choices[i]).toSet();
      final correctSelected = selectedTiles.intersection(_correctChoices);
      final wrongSelected = selectedTiles.difference(_correctChoices);

      _answeredCorrectly =
          correctSelected.length == _correctChoices.length &&
              wrongSelected.isEmpty;

      if (_answeredCorrectly) {
        _correctCount++;
      } else {
        _wrongTiles.add(_targetTile);
        _wrongCategories.add(_targetCategory.name);
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

  void _saveResult() {
    final practiceState = context.read<PracticeState>();
    practiceState.recordResult(PracticeResult(
      drillType: 'matching',
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
          'Tile Matching',
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
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
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
              'Find tiles in the same suit',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                getCategoryName(_targetCategory),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B9BD5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Target tile
            Container(
              width: 80,
              height: 107,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF5B9BD5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B9BD5).withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  'assets/tiles/$_targetTile.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select all tiles from the same suit:',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 16),
            // Choices grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _choices.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndices.contains(index);
                  final isCorrectTile = _correctChoices.contains(_choices[index]);

                  Color borderColor = const Color(0xFFE0E0E0);
                  Color bgColor = Colors.white;

                  if (_showResult) {
                    if (isCorrectTile) {
                      borderColor = const Color(0xFF4CAF50);
                      bgColor = const Color(0xFFE8F5E9);
                    } else if (isSelected && !isCorrectTile) {
                      borderColor = const Color(0xFFE53935);
                      bgColor = const Color(0xFFFFEBEE);
                    }
                  } else if (isSelected) {
                    borderColor = const Color(0xFF5B9BD5);
                    bgColor = const Color(0xFFE3F2FD);
                  }

                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/tiles/${_choices[index]}.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            if (isSelected && !_showResult)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF5B9BD5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 14),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!_showResult)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _selectedIndices.isEmpty ? null : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B9BD5),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
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
                      ? const Color(0xFF5B9BD5)
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
                      side: const BorderSide(color: Color(0xFF5B9BD5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5B9BD5),
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
                      backgroundColor: const Color(0xFF5B9BD5),
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
