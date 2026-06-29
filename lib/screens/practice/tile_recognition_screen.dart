import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/practice_data.dart';
import '../../providers/practice_state.dart';

class TileRecognitionScreen extends StatefulWidget {
  const TileRecognitionScreen({super.key});

  @override
  State<TileRecognitionScreen> createState() => _TileRecognitionScreenState();
}

class _TileRecognitionScreenState extends State<TileRecognitionScreen>
    with SingleTickerProviderStateMixin {
  static const int totalQuestions = 12;
  final _random = Random();

  int _currentQuestion = 0;
  int _correctCount = 0;
  final List<String> _wrongTiles = [];
  final List<String> _wrongCategories = [];

  late String _currentTile;
  late List<String> _options;
  int? _selectedIndex;
  bool _showResult = false;
  bool _isFinished = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _generateQuestion() {
    // Pick a random tile, prioritizing weak tiles
    final practiceState = context.read<PracticeState>();
    final weakTiles = practiceState.weaknessReport.weakestTiles;

    List<String> pool = List.from(allTileCodes);
    // 30% chance to pick from weak tiles if available
    if (weakTiles.isNotEmpty && _random.nextDouble() < 0.3) {
      _currentTile = weakTiles[_random.nextInt(weakTiles.length)];
    } else {
      _currentTile = pool[_random.nextInt(pool.length)];
    }

    // Generate 3 wrong options + 1 correct
    final correctName = tileNames[_currentTile] ?? _currentTile;
    final wrongOptions = <String>[];
    final allNames = tileNames.entries.where((e) => e.key != _currentTile).toList();
    allNames.shuffle(_random);
    wrongOptions.addAll(allNames.take(3).map((e) => e.value));

    _options = [...wrongOptions, correctName];
    _options.shuffle(_random);

    _selectedIndex = null;
    _showResult = false;
    _animController.forward(from: 0);
  }

  void _selectOption(int index) {
    if (_showResult) return;
    setState(() {
      _selectedIndex = index;
      _showResult = true;

      final correctName = tileNames[_currentTile] ?? _currentTile;
      if (_options[index] == correctName) {
        _correctCount++;
      } else {
        _wrongTiles.add(_currentTile);
        _wrongCategories.add(getTileCategory(_currentTile).name);
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
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
      drillType: 'recognition',
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
          'Tile Recognition',
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
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
        ),
      ),
      body: _isFinished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final correctName = tileNames[_currentTile] ?? _currentTile;

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
            const SizedBox(height: 16),
            Text(
              'What tile is this?',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 32),
            // Tile image
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/tiles/$_currentTile.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Options
            Expanded(
              child: ListView.separated(
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  final isCorrect = _options[index] == correctName;
                  Color bgColor = Colors.white;
                  Color borderColor = const Color(0xFFE0E0E0);
                  Color textColor = const Color(0xFF2D2D2D);

                  if (_showResult) {
                    if (isCorrect) {
                      bgColor = const Color(0xFFE8F5E9);
                      borderColor = const Color(0xFF4CAF50);
                      textColor = const Color(0xFF2E7D32);
                    } else if (isSelected && !isCorrect) {
                      bgColor = const Color(0xFFFFEBEE);
                      borderColor = const Color(0xFFE53935);
                      textColor = const Color(0xFFC62828);
                    }
                  } else if (isSelected) {
                    borderColor = const Color(0xFF4CAF50);
                  }

                  return GestureDetector(
                    onTap: () => _selectOption(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _options[index],
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_showResult && isCorrect)
                            const Icon(Icons.check_circle,
                                color: Color(0xFF4CAF50), size: 24),
                          if (_showResult && isSelected && !isCorrect)
                            const Icon(Icons.cancel,
                                color: Color(0xFFE53935), size: 24),
                        ],
                      ),
                    ),
                  );
                },
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
                      ? const Color(0xFF4CAF50)
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
            const SizedBox(height: 32),
            if (_wrongTiles.isNotEmpty) ...[
              Text(
                'Tiles to review:',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _wrongTiles.map((tile) {
                  return Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: const Color(0xFFE53935), width: 1.5),
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
              const SizedBox(height: 32),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
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
                      backgroundColor: const Color(0xFF4CAF50),
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
