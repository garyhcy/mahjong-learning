import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/match_data.dart';
import '../providers/game_state.dart';
import '../providers/match_state.dart';
import '../services/app_i18n.dart';
import 'match_room_screen.dart';

/// Find a Match (約戰) — entry flow.
/// Auto-matchmaking: no player list. System auto-forms a 4-player chat room.
class FindMatchScreen extends StatefulWidget {
  const FindMatchScreen({super.key});

  @override
  State<FindMatchScreen> createState() => _FindMatchScreenState();
}

class _FindMatchScreenState extends State<FindMatchScreen> {
  static const Color _green = Color(0xFF4CAF50);
  static const Color _bg = Color(0xFFF5F9F3);
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
            _findButton(match, skill),
            const SizedBox(height: 28),
            if (match.activeRooms.isNotEmpty) ...[
              _roomsHeader(),
              const SizedBox(height: 12),
              ...match.activeRooms.map((r) => _roomCard(r, match)),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quotaBanner(MatchState match) {
    if (match.isPremium) {
      return _chip('Pro: unlimited matches', const Color(0xFFFFF3E0),
          const Color(0xFFE65100));
    }
    if (!match.hasWeeklyOpportunity) {
      return _chip(
          'Weekly match used. Resets next week — or go Pro for unlimited.',
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828));
    }
    return _chip(
        '1 free match this week · ${match.failedRemaining} scheduling tries left',
        const Color(0xFFE8F5E9),
        const Color(0xFF2E7D32));
  }

  Widget _chip(String text, Color bg, Color fg) {
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

  Widget _languageSection(MatchState match) {
    final isEn = AppI18n.current == DisplayLang.en;
    return _section(
      'Match Language',
      'Players are paired in your chosen language',
      Wrap(
        spacing: 10,
        children: AppLanguage.values.map((lang) {
          final selected = match.language == lang;
          return ChoiceChip(
            label: Text(lang.displayLabel(isEn)),
            selected: selected,
            onSelected: (_) => match.setLanguage(lang, markChosen: false),
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

  Widget _daySection(MatchState match) {
    final days = [DayPref.noPreference, ...DayPref.values.where((d) => d != DayPref.noPreference)];
    return _section(
      'Preferred Days',
      'Pick the days you usually can play',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: days.map((day) {
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

  Widget _timeSection(MatchState match) {
    final times = [TimeBand.noPreference, ...TimeBand.values.where((t) => t != TimeBand.noPreference)];
    return _section(
      'Preferred Time',
      'Optional — leave on "No preference" if flexible',
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: times.map((band) {
          final selected = match.times.contains(band);
          return FilterChip(
            label: Text(band == TimeBand.noPreference ? 'No preference' : '${band.label}  ·  ${band.range}'),
            selected: selected,
            onSelected: (_) => match.toggleTime(band),
            selectedColor: _green,
            checkmarkColor: Colors.white,
            labelStyle: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 12,
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

  Widget _findButton(MatchState match, int skill) {
    final canSearch = match.hasWeeklyOpportunity && !_searching;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSearch ? () => _autoMatch(match, skill) : null,
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
                ? 'Find a match'
                : 'No matches left this week',
                style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
      ),
    );
  }

  Future<void> _autoMatch(MatchState match, int skill) async {
    setState(() => _searching = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    // Auto-generate 3 opponents near the player's skill
    final opponents = MatchDemoData.candidates(
      targetSkill: skill,
      language: match.language,
      count: 3,
    );
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    final room = MatchRoomData(
      id: roomId,
      title: 'Match ${opponents.map((o) => o.name).join(', ')}',
      opponents: opponents,
      createdAt: DateTime.now(),
      deleteAt: DateTime.now().add(const Duration(hours: 24)),
    );
    await match.saveRoom(room.toJson());
    setState(() => _searching = false);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MatchRoomScreen(
        roomId: roomId,
        opponents: opponents,
        roomData: room,
      ),
    ));
  }

  Widget _roomsHeader() {
    return Text('Your Match Rooms',
        style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2D3A2E)));
  }

  Widget _roomCard(Map<String, dynamic> raw, MatchState match) {
    final room = MatchRoomData.fromJson(raw);
    final now = DateTime.now();
    final left = room.deleteAt.difference(now);
    final hrs = left.inHours;
    final mins = left.inMinutes % 60;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: room.confirmed ? _green : const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(room.confirmed ? Icons.check_circle_rounded : Icons.chat_rounded,
              color: room.confirmed ? _green : const Color(0xFF9AA89C),
              size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room.title,
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    room.confirmed
                        ? 'Confirmed · ${room.venueName ?? 'Venue'} · ${room.confirmedTime ?? ''}'
                        : 'In progress · expires in ${hrs}h ${mins}m',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: const Color(0xFF9AA89C))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => MatchRoomScreen(
                  roomId: room.id,
                  opponents: room.opponents,
                  roomData: room,
                ),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(room.confirmed ? 'Open' : 'Continue',
                style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
