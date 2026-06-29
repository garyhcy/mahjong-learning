import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/practice_data.dart';
import '../../providers/practice_state.dart';

class RulesQuizScreen extends StatefulWidget {
  const RulesQuizScreen({super.key});

  @override
  State<RulesQuizScreen> createState() => _RulesQuizScreenState();
}

class _RulesQuizScreenState extends State<RulesQuizScreen> {
  static const int totalQuestions = 10;
  final _random = Random();

  late List<RulesQuestion> _questions;
  int _currentQuestion = 0;
  int _correctCount = 0;
  final List<String> _wrongCategories = [];

  int? _selectedIndex;
  bool _showResult = false;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    // Shuffle and pick questions
    final allQ = List<RulesQuestion>.from(rulesQuestions);
    allQ.shuffle(_random);
    _questions = allQ.take(totalQuestions).toList();
  }

  void _selectOption(int index) {
    if (_showResult) return;
    setState(() {
      _selectedIndex = index;
      _showResult = true;

      if (index == _questions[_currentQuestion].correctIndex) {
        _correctCount++;
      } else {
        _wrongCategories.add('rules');
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      setState(() {
        _currentQuestion++;
        if (_currentQuestion >= _questions.length) {
          _isFinished = true;
          _saveResult();
        } else {
          _selectedIndex = null;
          _showResult = false;
        }
      });
    });
  }

  void _saveResult() {
    final practiceState = context.read<PracticeState>();
    practiceState.recordResult(PracticeResult(
      drillType: 'rules',
      totalQuestions: _questions.length,
      correctAnswers: _correctCount,
      wrongTiles: [],
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
          'Rules Quiz',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _currentQuestion / _questions.length,
            backgroundColor: const Color(0xFFE8E8E8),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
          ),
        ),
      ),
      body: _isFinished ? _buildResults() : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_currentQuestion];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestion + 1} of ${_questions.length}',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              q.question,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: q.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  final isCorrect = index == q.correctIndex;

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
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _showResult && isCorrect
                                  ? const Color(0xFF4CAF50)
                                  : _showResult && isSelected && !isCorrect
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFFF5F5F5),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index), // A, B, C, D
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _showResult &&
                                          (isCorrect ||
                                              (isSelected && !isCorrect))
                                      ? Colors.white
                                      : const Color(0xFF757575),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              q.options[index],
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_showResult && isCorrect)
                            const Icon(Icons.check_circle,
                                color: Color(0xFF4CAF50), size: 22),
                          if (_showResult && isSelected && !isCorrect)
                            const Icon(Icons.cancel,
                                color: Color(0xFFE53935), size: 22),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_showResult) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Color(0xFF9C27B0), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        q.explanation,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final accuracy = _correctCount / _questions.length;
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
                      ? const Color(0xFF9C27B0)
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
              '$_correctCount / ${_questions.length} correct ($percentage%)',
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
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        final allQ = List<RulesQuestion>.from(rulesQuestions);
                        allQ.shuffle(_random);
                        _questions = allQ.take(totalQuestions).toList();
                        _currentQuestion = 0;
                        _correctCount = 0;
                        _wrongCategories.clear();
                        _selectedIndex = null;
                        _showResult = false;
                        _isFinished = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
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
