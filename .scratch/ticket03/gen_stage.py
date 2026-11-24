#!/usr/bin/env python3
"""Generate a whole stage (lessons + stage entry) from authored JSON parts.

Usage:
  python3 .scratch/ticket03/gen_stage.py \
      --stage 14 --parts a,b,c --lessons 14-1,14-2,14-3,14-4,14-5,14-6,14-7 \
      --title 'Faan Mastery' --subtitle '...' \
      --icon Icons.calculate_rounded --color 'const Color(0xFF6A1B9A)' \
      --after-stage 13 --banner 'STAGE 14: Faan Mastery (7 lessons)'

The parts are read from .scratch/ticket03/stage<stage><part>.json, i.e. for
--stage 14 --parts a,b,c the script reads stage14a.json, stage14b.json and
stage14c.json. Everything is validated before a single byte is written.

Refuses to run twice: it aborts if any lesson id already exists in the data
file, so a half-finished run can simply be re-run after the JSON is fixed.
"""
import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path('/opt/data/home/Ludi/mahjong-learning')
DATA = ROOT / 'lib/models/mahjong_data.dart'
SCRATCH = ROOT / '.scratch/ticket03'

sys.path.insert(0, str(SCRATCH))
from inject_v2 import dart_str, to_dart  # noqa: E402

VALID_TILES = set(
    ['m%d' % i for i in range(1, 10)]
    + ['p%d' % i for i in range(1, 10)]
    + ['s%d' % i for i in range(1, 10)]
    + ['east', 'south', 'west', 'north', 'red', 'green', 'white',
       'f_spring', 'f_summer', 'f_autumn', 'f_winter',
       'f_plum', 'f_orchid', 'f_chrys', 'f_bamboo']
)
QUESTION_TYPES = {'singleChoice', 'multiChoice', 'tileSelection',
                  'tileOrdering', 'fillBlank', 'matching'}


def check_question(lid: str, index: int, q: dict) -> None:
    where = f'{lid} q{index + 1}'
    qtype = q.get('type', 'singleChoice')
    if qtype not in QUESTION_TYPES:
        raise SystemExit(f'{where}: unknown type {qtype}')
    if not q.get('question'):
        raise SystemExit(f'{where}: empty question')
    if not q.get('explanation'):
        raise SystemExit(f'{where}: missing explanation')
    if '$' in json.dumps(q):
        raise SystemExit(f'{where}: contains a dollar sign')

    for token in re.findall(r'\{\{([^}]+)\}\}', q['question']):
        if token not in VALID_TILES:
            raise SystemExit(f'{where}: bad tile {token}')

    if qtype in ('singleChoice', 'tileSelection'):
        opts = q.get('options') or []
        if len(opts) != 4:
            raise SystemExit(f'{where}: expected 4 options, got {len(opts)}')
        if not 0 <= q.get('correctIndex', -1) <= 3:
            raise SystemExit(f'{where}: bad correctIndex')
        if qtype == 'tileSelection':
            for opt in opts:
                if opt not in VALID_TILES:
                    raise SystemExit(f'{where}: bad tile option {opt}')
    elif qtype == 'multiChoice':
        opts = q.get('options') or []
        if len(opts) != 4:
            raise SystemExit(f'{where}: expected 4 options, got {len(opts)}')
        idxs = q.get('correctIndexes') or []
        if len(idxs) < 2 or any(not 0 <= i <= 3 for i in idxs):
            raise SystemExit(f'{where}: bad correctIndexes {idxs}')
        if q.get('correctIndex') != idxs[0]:
            raise SystemExit(f'{where}: correctIndex must equal first correct index')
    elif qtype == 'tileOrdering':
        tiles = q.get('tiles') or []
        if not 3 <= len(tiles) <= 5:
            raise SystemExit(f'{where}: ordering needs 3-5 tiles, got {len(tiles)}')
        for tile in tiles:
            if tile not in VALID_TILES:
                raise SystemExit(f'{where}: bad tile {tile}')
    elif qtype == 'fillBlank':
        answers = q.get('acceptedAnswers') or []
        if len(answers) < 4:
            raise SystemExit(f'{where}: fillBlank needs 4+ answers, got {len(answers)}')
    elif qtype == 'matching':
        pairs = q.get('pairs') or []
        if not 3 <= len(pairs) <= 4:
            raise SystemExit(f'{where}: matching needs 3-4 pairs, got {len(pairs)}')
        rights = [p.get('right') for p in pairs]
        if len(set(rights)) != len(rights):
            raise SystemExit(f'{where}: matching right values must be unique')
        for pair in pairs:
            if not pair.get('left') or not pair.get('right'):
                raise SystemExit(f'{where}: empty matching pair')


def check_lesson(lid: str, lesson: dict) -> None:
    questions = lesson.get('questions') or []
    if len(questions) != 8:
        raise SystemExit(f'{lid}: expected 8 questions, got {len(questions)}')
    types = {q.get('type', 'singleChoice') for q in questions}
    if len(types) < 3:
        raise SystemExit(f'{lid}: needs 3+ question types, got {sorted(types)}')
    dialogues = lesson.get('dialogues') or []
    if not 4 <= len(dialogues) <= 5:
        raise SystemExit(f'{lid}: expected 4-5 dialogues, got {len(dialogues)}')
    for msg in dialogues:
        if msg.get('speaker') not in ('mj', 'you'):
            raise SystemExit(f'{lid}: bad speaker {msg.get("speaker")}')
        if not msg.get('text') or '$' in msg['text']:
            raise SystemExit(f'{lid}: bad dialogue text')
    for i, q in enumerate(questions):
        check_question(lid, i, q)


def load_lessons(stage: str, parts: list, order: list) -> dict:
    merged = {}
    for part in parts:
        path = SCRATCH / f'stage{stage}{part}.json'
        if not path.exists():
            raise SystemExit(f'missing {path}')
        data = json.loads(path.read_text())
        for lid, lesson in data.items():
            if lid in merged:
                raise SystemExit(f'duplicate lesson {lid} in {path}')
            merged[lid] = lesson
    missing = [lid for lid in order if lid not in merged]
    if missing:
        raise SystemExit(f'missing lessons: {missing}')
    extra = [lid for lid in merged if lid not in order]
    if extra:
        raise SystemExit(f'unexpected lessons: {extra}')
    for lid, lesson in merged.items():
        check_lesson(lid, lesson)
    return merged


def dialogue_dart(msg: dict) -> str:
    return ('      DialogueMessage(\n'
            f"        speaker: '{msg['speaker']}',\n"
            f"        text: {dart_str(msg['text'])},\n"
            '      ),')


def lesson_dart(stage_id: str, lid: str, lesson: dict) -> str:
    lines = [
        '  Lesson(',
        f"    id: '{lid}',",
        f"    stageId: '{stage_id}',",
        f"    title: {dart_str(lesson['title'])},",
        f"    subtitle: {dart_str(lesson['subtitle'])},",
        '    dialogues: [',
        '\n'.join(dialogue_dart(m) for m in lesson['dialogues']),
        '    ],',
        '    questions: [',
        '\n'.join(to_dart(q) for q in lesson['questions']),
        '    ],',
        '  ),',
    ]
    return '\n'.join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument('--stage', required=True)
    parser.add_argument('--parts', required=True)
    parser.add_argument('--lessons', required=True)
    parser.add_argument('--title', required=True)
    parser.add_argument('--subtitle', required=True)
    parser.add_argument('--icon', required=True)
    parser.add_argument('--color', required=True)
    parser.add_argument('--after-stage', required=True)
    parser.add_argument('--banner', required=True)
    args = parser.parse_args()

    stage_id = f'stage{args.stage}'
    parts = [p.strip() for p in args.parts.split(',') if p.strip()]
    order = [lid.strip() for lid in args.lessons.split(',') if lid.strip()]

    text = DATA.read_text()
    if f"id: '{order[0]}'" in text:
        raise SystemExit(f'stage {args.stage} looks already generated; aborting')

    lessons = load_lessons(args.stage, parts, order)

    # 1. stage entry right after the previous stage entry
    prev = re.search(
        r"  LearningStage\(\n    id: 'stage%s',\n(?:.*\n)*?  \),\n" % re.escape(args.after_stage),
        text)
    if not prev:
        raise SystemExit(f'stage{args.after_stage} LearningStage entry not found')
    stage_entry = (
        '  LearningStage(\n'
        f"    id: '{stage_id}',\n"
        f"    title: {dart_str(args.title)},\n"
        f"    subtitle: {dart_str(args.subtitle)},\n"
        f'    icon: {args.icon},\n'
        f'    color: {args.color},\n'
        f'    lessonCount: {len(order)},\n'
        '  ),\n')
    text = text[:prev.end()] + stage_entry + text[prev.end():]

    # 2. lesson blocks before the closing `];` of defaultLessons
    blocks = '\n'.join(lesson_dart(stage_id, lid, lessons[lid]) for lid in order)
    banner = (
        '  // ═══════════════════════════════════\n'
        f'  //  {args.banner}\n'
        '  // ═══════════════════════════════════\n')
    tail = '\n];\n'
    if not text.endswith(tail):
        raise SystemExit('file does not end with the expected `];`')
    text = text[:-len(tail)] + '\n' + banner + blocks + tail

    # 3. header comment
    header = re.search(r'Complete Curriculum \((\d+) Stages, (\d+) Lessons\)', text)
    if not header:
        raise SystemExit('curriculum header comment not found')
    total_lessons = int(header.group(2)) + len(order)
    text = text.replace(
        header.group(0),
        f'Complete Curriculum ({args.stage} Stages, {total_lessons} Lessons)')

    DATA.write_text(text)

    counts = {lid: len(lessons[lid]['questions']) for lid in order}
    print('inserted lessons:', ', '.join(f'{k}({v})' for k, v in counts.items()))
    print('total new questions:', sum(counts.values()))


if __name__ == '__main__':
    main()
