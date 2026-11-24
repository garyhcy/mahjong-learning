#!/usr/bin/env python3
"""Inject authored questions from explicit stage json files into mahjong_data.dart.

Usage:
  python3 .scratch/ticket03/inject_v2.py stage5.json stage6.json stage7.json stage8.json

Differences from inject.py (kept for the ticket 03 run):
  - takes the json files as arguments instead of globbing every stage*.json
    (re-running inject.py would double-inject stages 1-4);
  - refuses to touch a lesson that already holds >= 8 questions, so a partial
    or repeated run cannot duplicate content.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path('/opt/data/home/Ludi/mahjong-learning')
DATA = ROOT / 'lib/models/mahjong_data.dart'
SCRATCH = ROOT / '.scratch/ticket03'
MIN_QUESTIONS = 8


def esc(text: str) -> str:
    # '$' must be escaped too: Dart expands $name / ${...} inside single quotes.
    return (text.replace('\\', '\\\\').replace('$', '\\$')
            .replace("'", "\\'"))


def dart_str(text: str) -> str:
    return "'" + esc(text) + "'"


def to_dart(q: dict) -> str:
    t = q.get('type', 'singleChoice')
    lines = ['      QuizQuestion(', f'        type: QuizType.{t},',
             f'        question: {dart_str(q["question"])},']
    opts = q.get('options') or []
    if opts:
        lines.append('        options: [' + ', '.join(dart_str(o) for o in opts) + '],')
    else:
        lines.append('        options: const [],')
    lines.append(f'        correctIndex: {int(q.get("correctIndex", 0))},')
    if q.get('correctIndexes'):
        lines.append('        correctIndexes: [' + ', '.join(str(int(i)) for i in q['correctIndexes']) + '],')
    if q.get('acceptedAnswers'):
        lines.append('        acceptedAnswers: [' + ', '.join(dart_str(str(a)) for a in q['acceptedAnswers']) + '],')
    if q.get('pairs'):
        pairs = ', '.join(
            'QuestionPair(left: %s, right: %s)' % (dart_str(p['left']), dart_str(p['right']))
            for p in q['pairs'])
        lines.append('        pairs: const [' + pairs + '],')
    if q.get('tiles'):
        lines.append('        tiles: const [' + ', '.join(dart_str(t2) for t2 in q['tiles']) + '],')
    exp = q.get('explanation')
    if exp:
        lines.append(f'        explanation: {dart_str(exp)},')
    lines.append('      ),')
    return '\n'.join(lines)


def find_lesson_block(text: str, lesson_id: str):
    """Return (start, end) of the `Lesson(...)` block for lesson_id."""
    marker = "id: '%s'" % lesson_id
    pos = text.find(marker)
    if pos < 0:
        raise SystemExit('lesson not found: %s' % lesson_id)
    start = text.rfind('Lesson(', 0, pos)
    if start < 0:
        raise SystemExit('Lesson( not found for %s' % lesson_id)
    i = start + len('Lesson(')
    depth = 1
    in_single = in_double = False
    escaped = False
    while i < len(text):
        ch = text[i]
        if escaped:
            escaped = False
        elif ch == '\\':
            escaped = True
        elif in_single:
            if ch == "'":
                in_single = False
        elif in_double:
            if ch == '"':
                in_double = False
        elif ch == "'":
            in_single = True
        elif ch == '"':
            in_double = True
        elif ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
            if depth == 0:
                return start, i + 1
        i += 1
    raise SystemExit('unbalanced block for %s' % lesson_id)


def insert_questions(block: str, dart: str) -> str:
    marker = 'questions: ['
    pos = block.find(marker)
    if pos < 0:
        raise SystemExit('questions: [ not found in block')
    i = pos + len(marker) - 1  # at '['
    depth = 0
    in_single = in_double = False
    escaped = False
    while i < len(block):
        ch = block[i]
        if escaped:
            escaped = False
        elif ch == '\\':
            escaped = True
        elif in_single:
            if ch == "'":
                in_single = False
        elif in_double:
            if ch == '"':
                in_double = False
        elif ch == "'":
            in_single = True
        elif ch == '"':
            in_double = True
        elif ch == '[':
            depth += 1
        elif ch == ']':
            depth -= 1
            if depth == 0:
                return block[:i] + dart + '\n    ' + block[i:]
        i += 1
    raise SystemExit('unbalanced questions list')


def main() -> None:
    args = sys.argv[1:]
    if not args:
        raise SystemExit(__doc__)
    text = DATA.read_text()
    total = 0
    for name in args:
        path = Path(name) if Path(name).is_absolute() else SCRATCH / name
        data = json.loads(path.read_text())
        for lesson_id, questions in data.items():
            start, end = find_lesson_block(text, lesson_id)
            block = text[start:end]
            existing = len(re.findall(r'QuizQuestion\(', block))
            if existing >= MIN_QUESTIONS:
                print('skip %s: already has %d questions' % (lesson_id, existing))
                continue
            dart = '\n'.join(to_dart(q) for q in questions)
            text = text[:start] + insert_questions(block, dart) + text[end:]
            total += len(questions)
            print('%s: %d -> +%d' % (lesson_id, existing, len(questions)))
    DATA.write_text(text)
    print('total new questions: %d' % total)


if __name__ == '__main__':
    main()
