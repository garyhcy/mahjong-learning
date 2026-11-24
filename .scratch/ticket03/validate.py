#!/usr/bin/env python3
"""Validate authored stage json files before injecting them into mahjong_data.dart.

Usage:
  python3 .scratch/ticket03/validate.py stage5.json stage6.json ...

Checks per question:
  - type is one of the six QuizType values;
  - question text is non-empty and not already used by that lesson in the Dart file;
  - every tile id in options / tiles / stems resolves to an existing asset;
  - multiChoice needs >= 2 correctIndexes, all in range, with >= 2 options;
  - singleChoice / tileSelection / tileOrdering need correctIndex in range;
  - fillBlank needs acceptedAnswers (or an options fallback);
  - matching needs >= 2 pairs with unique right-hand values;
  - tileOrdering needs >= 2 tiles.
Checks per lesson: 5 authored questions, and the merged lesson stays within 8-12
questions with at least 2 distinct question types.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path('/opt/data/home/Ludi/mahjong-learning')
DATA = ROOT / 'lib/models/mahjong_data.dart'
SCRATCH = ROOT / '.scratch/ticket03'
TILES = {p.stem for p in (ROOT / 'assets/tiles').glob('*.png')}
TYPES = {'singleChoice', 'multiChoice', 'tileSelection', 'tileOrdering', 'fillBlank', 'matching'}
NEW_TYPES = {'multiChoice', 'fillBlank', 'matching', 'tileOrdering', 'tileSelection'}
MARKER = re.compile(r'\{\{([a-zA-Z0-9_]+)\}\}')
LESSON_BLOCK = re.compile(r"id: '([0-9]+-[0-9]+)'")


def lesson_slices(text: str):
    """Map lesson id -> (start, end) using the `id: 'x-y'` anchors."""
    hits = [(m.group(1), m.start()) for m in LESSON_BLOCK.finditer(text)]
    out = {}
    for idx, (lid, pos) in enumerate(hits):
        start = text.rfind('Lesson(', 0, pos)
        end = hits[idx + 1][1] if idx + 1 < len(hits) else len(text)
        out[lid] = (start, end)
    return out


def existing_questions(text: str, lid: str) -> list:
    spans = lesson_slices(text)
    if lid not in spans:
        raise SystemExit('lesson missing from data: %s' % lid)
    s, e = spans[lid]
    block = text[s:e]
    return re.findall(r"question:\s*'((?:[^'\\]|\\.)*)'", block)


def ALL_TYPES_IN_DART(text: str, lid: str) -> set:
    s, e = lesson_slices(text)[lid]
    return set(re.findall(r'type:\s*QuizType\.(\w+)', text[s:e]))


def merged_type_count(text: str, lid: str) -> int:
    """Distinct types after the merge. Existing questions that omit `type:`
    are singleChoice by default, so count that in."""
    s, e = lesson_slices(text)[lid]
    block = text[s:e]
    return len(set(re.findall(r'type:\s*QuizType\.(\w+)', block)) | {'singleChoice'})


def check_question(lid: str, i: int, q: dict, problems: list) -> None:
    where = '%s q%d' % (lid, i + 1)
    t = q.get('type')
    if t not in TYPES:
        problems.append('%s: bad type %r' % (where, t))
        return
    stem = q.get('question') or ''
    if not stem.strip():
        problems.append('%s: empty question' % where)
    opts = q.get('options') or []
    pairs = q.get('pairs') or []
    tiles = q.get('tiles') or []
    ci = q.get('correctIndex', 0)

    for m in MARKER.finditer(' '.join([stem, ' '.join(opts)])):
        if m.group(1) not in TILES:
            problems.append('%s: unknown tile {{%s}}' % (where, m.group(1)))
    for tid in tiles:
        if tid not in TILES:
            problems.append('%s: unknown ordering tile %r' % (where, tid))

    if t == 'multiChoice':
        cis = q.get('correctIndexes') or []
        if len(cis) < 2:
            problems.append('%s: multiChoice needs >= 2 correctIndexes' % where)
        if any(not (0 <= int(c) < len(opts)) for c in cis):
            problems.append('%s: correctIndexes out of range' % where)
        if len(opts) < 3:
            problems.append('%s: multiChoice needs >= 3 options' % where)
    elif t in ('singleChoice', 'tileSelection'):
        if len(opts) < 2:
            problems.append('%s: %s needs >= 2 options' % (where, t))
        if not (0 <= int(ci) < len(opts)):
            problems.append('%s: correctIndex out of range' % where)
    elif t == 'tileOrdering':
        if len(tiles) < 2:
            problems.append('%s: tileOrdering needs >= 2 tiles' % where)
    elif t == 'fillBlank':
        if not (q.get('acceptedAnswers') or []):
            problems.append('%s: fillBlank needs acceptedAnswers' % where)
    elif t == 'matching':
        if len(pairs) < 2:
            problems.append('%s: matching needs >= 2 pairs' % where)
        rights = [p.get('right') for p in pairs]
        if len(set(rights)) != len(rights):
            problems.append('%s: matching right values must be unique' % where)
        if any(not (p.get('left') or '').strip() or not (p.get('right') or '').strip() for p in pairs):
            problems.append('%s: matching pair has an empty side' % where)
    if not (q.get('explanation') or '').strip():
        problems.append('%s: missing explanation' % where)


def main() -> None:
    args = sys.argv[1:]
    if not args:
        raise SystemExit(__doc__)
    text = DATA.read_text()
    problems = []
    for name in args:
        path = Path(name) if Path(name).is_absolute() else SCRATCH / name
        data = json.loads(path.read_text())
        for lid, questions in data.items():
            existing = {q.replace("\\'", "'") for q in existing_questions(text, lid)}
            stems = [q.get('question', '').strip() for q in questions]
            if len(questions) != 5:
                problems.append('%s: expected 5 authored questions, got %d' % (lid, len(questions)))
            if len(set(stems)) != len(stems):
                problems.append('%s: duplicate question text inside the file' % lid)
            for stem in stems:
                if stem in existing:
                    problems.append('%s: duplicates an existing question: %s' % (lid, stem[:60]))
            types = {q.get('type') for q in questions}
            if len(types) < 2:
                problems.append('%s: authored set has only one question type' % lid)
            for i, q in enumerate(questions):
                check_question(lid, i, q, problems)
            total = len(existing) + len(questions)
            if not (8 <= total <= 12):
                problems.append('%s: merged lesson has %d questions (need 8-12)' % (lid, total))
            merged_types = set(types) | {t for t in ALL_TYPES_IN_DART(text, lid)} | {'singleChoice'}
            if len(merged_types) < 2:
                problems.append('%s: lesson would have < 2 question types' % lid)
        print('%s: %d lessons' % (name, len(data)))
    if problems:
        print('\n%d problem(s):' % len(problems))
        for p in problems:
            print(' -', p)
        raise SystemExit(1)
    print('\nOK')


if __name__ == '__main__':
    main()
