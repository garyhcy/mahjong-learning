#!/usr/bin/env python3
"""Inject authored questions from .scratch/ticket03/stage*.json into mahjong_data.dart."""
import json
import re
import sys
from pathlib import Path

ROOT = Path('/opt/data/home/Ludi/mahjong-learning')
DATA = ROOT / 'lib/models/mahjong_data.dart'


def esc(text: str) -> str:
    return text.replace('\\', '\\\\').replace("'", "\\'")


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
    if q.get('explanation'):
        lines.append(f'        explanation: {dart_str(q["explanation"])},')
    lines.append('      ),')
    return '\n'.join(lines)


def find_lesson_block(text: str, lesson_id: str):
    """Return (start, end) of the Lesson( ... ) block containing this lesson id."""
    marker = f"id: '{lesson_id}',"
    idx = text.find(marker)
    if idx < 0:
        raise SystemExit(f'lesson {lesson_id} not found')
    start = text.rfind('Lesson(', 0, idx)
    if start < 0:
        raise SystemExit(f'Lesson( opener not found for {lesson_id}')
    # walk forward to the matching close paren
    depth = 0
    i = start
    while i < len(text):
        c = text[i]
        if c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return start, i + 1
        elif c == "'":
            i += 1
            while i < len(text) and text[i] != "'":
                if text[i] == '\\':
                    i += 1
                i += 1
        i += 1
    raise SystemExit(f'unterminated Lesson block for {lesson_id}')


def insert_questions(block: str, new_dart: str) -> str:
    m = re.search(r'questions:\s*\[', block)
    if not m:
        raise SystemExit('questions list not found in block')
    start = m.end()
    depth = 1
    i = start
    while i < len(block):
        c = block[i]
        if c in '([':
            depth += 1
        elif c in ')]':
            depth -= 1
            if depth == 0:
                break
        elif c == "'":
            i += 1
            while i < len(block) and block[i] != "'":
                if block[i] == '\\':
                    i += 1
                i += 1
        i += 1
    body = block[start:i].rstrip()
    if not body.endswith(','):
        body += ','
    return block[:m.end()] + body + '\n' + new_dart + '\n    ' + block[i:]


def main():
    stages = sorted((ROOT / '.scratch/ticket03').glob('stage*.json'))
    if not stages:
        raise SystemExit('no stage json found')
    text = DATA.read_text()
    total = 0
    for path in stages:
        data = json.loads(path.read_text())
        for lesson_id, questions in data.items():
            start, end = find_lesson_block(text, lesson_id)
            block = text[start:end]
            dart = '\n'.join(to_dart(q) for q in questions)
            text = text[:start] + insert_questions(block, dart) + text[end:]
            total += len(questions)
            print(f'{lesson_id}: +{len(questions)}')
    DATA.write_text(text)
    print(f'total new questions: {total}')


if __name__ == '__main__':
    main()
