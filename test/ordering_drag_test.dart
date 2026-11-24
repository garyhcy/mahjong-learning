import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludi/models/mahjong_data.dart';
import 'package:ludi/widgets/quiz/question_inputs.dart';

void main() {
  testWidgets('top-down answer ordering survives drag events', (tester) async {
    List<String> order = ['s1', 's2', 's3'];

    QuestionInputConfig config() => QuestionInputConfig(
          selected: const {},
          orderingTiles: order,
          answerText: '',
          matches: const {},
          feedbackActive: false,
          feedbackCorrect: null,
          pressedOption: null,
          onOptionTap: (_) {},
          onPressedOption: (_) {},
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) newIndex -= 1;
            final moved = order.removeAt(oldIndex);
            order.insert(newIndex, moved);
          },
          onTextChanged: (_) {},
          onMatch: (_, __) {},
          onSubmit: () {},
        );

    final question = QuizQuestion(
      question: 'Order these',
      options: const [],
      correctIndex: 0,
      type: QuizType.tileOrdering,
      tiles: const ['s1', 's2', 's3'],
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: buildQuestionInput(question: question, config: config()),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Drag the first row (long press first: ReorderableListView uses a
    // delayed drag listener on touch platforms).
    final firstRow = find.byKey(const Key('tile_s1'));
    expect(firstRow, findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(firstRow));
    await tester.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 30));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(order, isNot(['s1', 's2', 's3']),
        reason: 'dragging the first tile down should reorder the list');
  });
}
