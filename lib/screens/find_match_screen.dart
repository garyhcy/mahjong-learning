import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/match_data.dart';
import '../providers/game_state.dart';
import '../providers/match_state.dart';
import 'match_room_screen.dart';

/// Find a Match (約戰) — entry flow.
///
/// Demo scope: language + day/time preferences and weekly quota are REAL and
/// persisted. The opponent pool is generated locally around the player's
/// Skill Rating. Picking an opponent opens a (simulated) chat room where the
/// scheduling vote flow is fully interactive.
class FindMatchScreen extends StatefulWidget {
  const FindMatchScreen({super.key});

  @override
  State<FindMatchScreen> createState() => _FindMatchScreenState();
}

class _FindMatchScreenState extends State<FindMatchScreen> {
  static const Color _green = Color(0xFF4CAF50);
  static const Color _bg = Color(0xFFF5F9F3);

  List<MatchCandidate>? _pool;
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();
    final match = context.watch<MatchState>();
    final skill = game.skillRating;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3A2E),
        title: Text('Find a Match',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _skillSnapshot(game),
            const SizedBox(height: 20),
            _quotaBanner(match),
            const SizedBox(height: 20),
            _languageSection(match),
            const SizedBox(height: 20),
            _daySection(match),
            const SizedBox(height: 20),
            _timeSection(match),
            const SizedBox(height: 24),
            _findButton(game, match, skill),
            if (_pool != null) ...[
              const SizedBox(height: 24),
              _poolHeader(),
              const SizedBox(height: 12),
              ..._pool!.map((c) => _candidateCard(c, match)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Skill Snapshot ──
  Widget _skillSnapshot(GameState game) {
    final skill = game.skillRating;
    final tier = SkillRating(skill);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(tier.tierEmoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Skill Rating',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('$skill',
                        style: GoogleFonts.nunito(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                    Text(' / 100',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tier.tierName,
                          style: GoogleFonts.nunito(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Calculated from your progress & accuracy',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.white.withAlpha(200))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Weekly quota banner ──
  Widget _quotaBanner(MatchState match) {
    if (match.isPremium) {
      return _infoChip('♾️  Pro: unlimited matches', const Color(0xFFFFF3E0),
          const Color(0xFFE65100));
    }
    if (!match.hasWeeklyOpportunity) {
      return _infoChip(
          '🔒  Weekly match used. Resets next week — or go Pro for unlimited.',
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828));
    }
    return _infoChip(
        '🎟️  1 free match this week · ${match.failedRemaining} scheduling tries left',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32));
  }

  Widget _infoChip(String text, Color bg, Color fg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  // ── Language ──
  Widget _languageSection(MatchState match) {
    return _section(
      'Match Language',
      'Players are paired in your chosen language',
      Wrap(
        spacing: 10,
        children: AppLanguage.values.map((lang) {
          final selected = match.language == lang;
          return ChoiceChip(
            label: Text(lang.label),
            selected: selected,
            onSelected: (_) => match.setLanguage(lang),
            selectedColor: _green,
            labelStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF424242)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Days ──
  Widget _daySection(MatchState match) {
    return _section(
      'Preferred Days',
      'Pick the days you usually can play',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: DayPref.values.map((day) {
          final selected = match.days.contains(day);
          return FilterChip(
            label: Text(day.short),
            selected: selected,
            onSelected: (_) => match.toggleDay(day),
            selectedColor: _green,
            checkmarkColor: Colors.white,
            labelStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : const Color(0xFF424242)),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Times ──
  Widget _timeSection(MatchState match) {
    return _section(
      'Preferred Time',
      'Optional — leave on "No preference" if flexible',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: match.noTimePref,
            activeColor: _green,
            title: Text('No particular preference',
                style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            onChanged: (v) => match.setNoTimePref(v),
          ),
          if (!match.noTimePref)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TimeBand.values.map((band) {
                final selected = match.times.contains(band);
                return FilterChip(
                  label: Text('${band.label}  ·  ${band.range}'),
                  selected: selected,
                  onSelected: (_) => match.toggleTime(band),
                  selectedColor: _green,
                  checkmarkColor: Colors.white,
                  labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color:
                          selected ? Colors.white : const Color(0xFF424242)),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ── Find button ──
  Widget _findButton(GameState game, MatchState match, int skill) {
    final canSearch = match.hasWeeklyOpportunity && !_searching;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSearch ? () => _runSearch(match, skill) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          disabledBackgroundColor: const Color(0xFFC8E6C9),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _searching
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(match.hasWeeklyOpportunity
                ? 'Find Players Near Me'
                : 'No matches left this week',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
      ),
    );
  }

  Future<void> _runSearch(MatchState match, int skill) async {
    setState(() => _searching = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _pool = MatchDemoData.candidates(
        targetSkill: skill,
        language: match.language,
      );
      _searching = false;
    });
  }

  Widget _poolHeader() {
    return Text('Players near your skill',
        style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D3A2E)));
  }

  Widget _candidateCard(MatchCandidate c, MatchState match) {
    final tier = SkillRating(c.skill);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF1F8E9),
            child: Text(c.avatarEmoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.name,
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Text('${tier.tierEmoji} ${c.skill}',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7A6E))),
                  ],
                ),
                const SizedBox(height: 2),
                Text('${c.city} · ${c.gamesPlayed} games · ${(c.reliability * 100).round()}% show-up',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF9AA89C))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _openRoom(c, match),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Invite',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openRoom(MatchCandidate c, MatchState match) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MatchRoomScreen(opponent: c),
    ));
  }

  // ── Section wrapper ──
  Widget _section(String title, String subtitle, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D3A2E))),
        const SizedBox(height: 2),
        Text(subtitle,
            style: GoogleFonts.nunito(
                fontSize: 12, color: const Color(0xFF9AA89C))),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
