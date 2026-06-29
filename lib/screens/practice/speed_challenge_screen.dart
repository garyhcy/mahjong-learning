import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/practice_data.dart';
import '../../providers/practice_state.dart';

class SpeedChallengeScreen extends StatefulWidget {
  const SpeedChallengeScreen({super.key});

  @override
  State<SpeedChallengeScreen> createState() => _SpeedChallengeScreenState();
}

class _SpeedChallengeScreenState extends State<SpeedChallengeScreen> {
  static const int totalSeconds = 60;
  final _random = Random();

  int _timeLeft = totalSeconds;
  int _score = 0;
  int _totalAttempts = 0;
  Timer? _timer;
  bool _isStarted = false;
  bool _isFinished = false;
  final List<String> _wrongTiles = [];

  late String _currentTile;
  late List<String> _options; // 4 tile names
  bool _showFeedback = false;
  bool _lastCorrect = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _isStarted = true;
      _score = 0;
      _totalAttempts = 0;
      _timeLeft = totalSeconds;
      _wrongTiles.clear();
      _isFinished = false;
    });
    _generateQuestion();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timer?.cancel();
          _isFinished = true;
          _saveResult();
        }
      });
    });
  }

  void _generateQuestion() {
    _currentTile = allTileCodes[_random.nextInt(allTileCodes.length)];
    final correctName = tileNames[_currentTile] ?? _currentTile;

    final wrongOptions = <String>[];
    final allNames =
        tileNames.entries.where((e) => e.key != _currentTile).toList();
    allNames.shuffle(_random);
    wrongOptions.addAll(allNames.take(3).map((e) => e.value));

    _options = [...wrongOptions, correctName];
    _options.shuffle(_random);
    _showFeedback = false;
  }

  void _selectOption(int index) {
    if (_showFeedback || _isFinished) return;

    final correctName = tileNames[_currentTile] ?? _currentTile;
    final isCorrect = _options[index] == correctName;

    setState(() {
      _totalAttempts++;
      _showFeedback = true;
      _lastCorrect = isCorrect;
      if (isCorrect) {
        _score++;
      } else {
        _wrongTiles.add(_currentTile);
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _isFinished) return;
      setState(() {
        _generateQuestion();
      });
    });
  }

  void _saveResult() {
    final practiceState = context.read<PracticeState>();
    practiceState.recordResult(PracticeResult(
      drillType: 'speed',
      totalQuestions: _totalAttempts,
      correctAnswers: _score,
      wrongTiles: _wrongTiles,
      wrongCategories: [],
      timeTaken: totalSeconds,
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
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Speed Challenge',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        actions: [
          if (_isStarted && !_isFinished)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 10
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 18,
                        color: _timeLeft <= 10
                            ? const Color(0xFFE53935)
                            : const Color(0xFF757575),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_timeLeft}s',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _timeLeft <= 10
                              ? const Color(0xFFE53935)
                              : const Color(0xFF2D2D2D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: !_isStarted
          ? _buildStartScreen()
          : _isFinished
              ? _buildResults()
              : _buildGame(),
    );
  }

  Widget _buildStartScreen() {
    final practiceState = context.watch<PracticeState>();
    final best = practiceState.speedBest;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 56,
                color: Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Speed Challenge',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Identify as many tiles as possible in 60 seconds!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            if (best > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Color(0xFFE8B93E), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Personal Best: $best',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Start!',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Score
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Score: ',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: const Color(0xFF757575),
                  ),
                ),
                Text(
                  '$_score',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tile
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 100,
              height: 133,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _showFeedback
                      ? (_lastCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935))
                      : const Color(0xFFE0E0E0),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/tiles/$_currentTile.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Options
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _selectOption(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            _options[index],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D2D2D),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Timer bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _timeLeft / totalSeconds,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8E8E8),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timeLeft <= 10
                      ? const Color(0xFFE53935)
                      : const Color(0xFFFF6B35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final practiceState = context.watch<PracticeState>();
    final best = practiceState.speedBest;
    final isNewBest = _score >= best && _score > 0;
    final accuracy =
        _totalAttempts > 0 ? (_score / _totalAttempts * 100).round() : 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isNewBest) ...[
              const Icon(Icons.celebration_rounded,
                  size: 48, color: Color(0xFFE8B93E)),
              const SizedBox(height: 8),
              Text(
                'New Personal Best!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE8B93E),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              '$_score',
              style: GoogleFonts.nunito(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFF6B35),
              ),
            ),
            Text(
              'tiles identified',
              style: GoogleFonts.nunito(
                fontSize: 18,
                color: const Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statChip('Accuracy', '$accuracy%'),
                const SizedBox(width: 16),
                _statChip('Attempts', '$_totalAttempts'),
                const SizedBox(width: 16),
                _statChip('Best', '$best'),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFFF6B35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
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

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              color: const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}
