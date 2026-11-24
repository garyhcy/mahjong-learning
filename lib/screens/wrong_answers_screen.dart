import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/mahjong_data.dart';
import '../models/wrong_answer.dart';
import '../providers/game_state.dart';
import 'learn_screen.dart';

/// The wrong-answer book: every question the learner got wrong, with a way to
/// practise them all in one run or drop a single entry.
///
/// Gary 2026-11-24 (P3, D1a): a question leaves this book as soon as it is
/// answered correctly once in review mode.
class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  static String _plainQuestion(String raw) =>
      raw.replaceAll(RegExp(r'\{\{[^}]+\}\}'), 'tile');

  String _lessonTitle(String lessonId) {
    final lesson = allLessonsData.firstWhere(
      (l) => l.id == lessonId,
      orElse: () => allLessonsData.first,
    );
    return lesson.localizedTitle;
  }

  QuizQuestion? _questionOf(WrongAnswer entry) {
    final lesson = allLessonsData.firstWhere(
      (l) => l.id == entry.lessonId,
      orElse: () => allLessonsData.first,
    );
    final questions = lesson.localizedQuestions;
    if (entry.questionIndex < 0 || entry.questionIndex >= questions.length) {
      return null;
    }
    return questions[entry.questionIndex];
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final entries = game.wrongAnswers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wrong answers',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D2D2D),
        elevation: 0,
      ),
      body: entries.isEmpty
          ? _emptyState(context)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        game.startWrongAnswerReview();
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const LearnScreen(),
                        ));
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        'Practise all ${entries.length}',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF58CC02),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final question = _questionOf(entry);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _lessonTitle(entry.lessonId),
                                      style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      question == null
                                          ? 'Question unavailable'
                                          : _plainQuestion(question.question),
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D2D2D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: Color(0xFFBDBDBD)),
                                onPressed: () => game.removeWrongAnswer(
                                    entry.lessonId, entry.questionIndex),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_rounded,
                size: 48, color: Color(0xFF58CC02)),
            const SizedBox(height: 12),
            Text(
              'No wrong answers yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Questions you miss in a lesson land here for review.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
