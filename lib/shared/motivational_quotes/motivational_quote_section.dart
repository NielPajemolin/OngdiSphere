import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ongdisphere/core/theme/theme.dart';
import 'package:ongdisphere/shared/widgets/kuromi_accents.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MotivationalQuoteSection extends StatefulWidget {
  const MotivationalQuoteSection({super.key});

  @override
  State<MotivationalQuoteSection> createState() =>
      _MotivationalQuoteSectionState();
}

class _MotivationalQuoteSectionState extends State<MotivationalQuoteSection> {
  static const _quoteCacheKey = 'motivational_quote_cache';

  late Future<List<_MotivationalQuote>> _quotesFuture;
  List<_MotivationalQuote> _loadedQuotes = [];
  int _quoteIndex = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _quotesFuture = _fetchQuotes();
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || _loadedQuotes.isEmpty) return;
      final nextIndex = _quoteIndex + 1;
      if (nextIndex >= _loadedQuotes.length) {
        _autoTimer?.cancel();
        setState(() {
          _quoteIndex = 0;
          _loadedQuotes = [];
          _quotesFuture = _fetchQuotes();
        });
      } else {
        setState(() {
          _quoteIndex = nextIndex;
        });
      }
    });
  }

  Future<List<_MotivationalQuote>> _fetchQuotes() async {
    try {
      final uri = Uri.parse(
        'https://motivational-spark-api.vercel.app/api/quotes/random/10',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        throw Exception('Unable to load motivational quotes right now.');
      }

      final quotes = _parseQuotesFromBody(response.body);
      if (quotes.isEmpty) {
        throw Exception('No quotes available at the moment.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_quoteCacheKey, response.body);
      return quotes;
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final cachedBody = prefs.getString(_quoteCacheKey);
      if (cachedBody != null && cachedBody.isNotEmpty) {
        final cachedQuotes = _parseQuotesFromBody(cachedBody);
        if (cachedQuotes.isNotEmpty) {
          return cachedQuotes;
        }
      }

      rethrow;
    }
  }

  List<_MotivationalQuote> _parseQuotesFromBody(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw Exception('Unexpected response format from quote service.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_MotivationalQuote.fromJson)
        .where((quote) => quote.text.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colorsOf(context);

    return KuromiDecoratedContainer(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D1321), Color(0xFF8F6EA8)],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.secondary.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      patternColor: Colors.white,
      patternOpacity: 0.16,
      child: FutureBuilder<List<_MotivationalQuote>>(
        future: _quotesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(color: colors.secondary),
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(colors);
          }

          final quotes = snapshot.data ?? const [];
          if (quotes.isEmpty) {
            return _buildEmptyState();
          }

          if (_loadedQuotes.isEmpty) {
            _loadedQuotes = quotes;
            WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
          }

          final quote = quotes[_quoteIndex % quotes.length];
          final totalDots = quotes.length;
          final activeDot = _quoteIndex % quotes.length;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.06, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<String>('${quote.text}-${quote.author}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFC9DD),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Daily Motivation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Color(0x45FFFFFF), thickness: 1, height: 1),
                const SizedBox(height: 10),
                Text(
                  '"${quote.text}"',
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.45,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFC9DD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x55FFC9DD)),
                  ),
                  child: Text(
                    '- ${quote.author}',
                    style: const TextStyle(
                      color: Color(0xFFFFEAF3),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 5,
                  children: List.generate(totalDots, (i) {
                    final isActive = i == activeDot;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFFFC9DD)
                            : Colors.white.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFC9DD), size: 18),
            SizedBox(width: 8),
            Text(
              'Daily Motivation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0x45FFFFFF), thickness: 1, height: 1),
        const SizedBox(height: 8),
        const Text(
          'Could not load quotes. Tap below to retry.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            foregroundColor: const Color(0xFF211724),
            backgroundColor: const Color(0xFFFFC9DD),
          ),
          onPressed: () {
            _autoTimer?.cancel();
            setState(() {
              _quoteIndex = 0;
              _loadedQuotes = [];
              _quotesFuture = _fetchQuotes();
            });
          },
          child: const Text('Retry'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFC9DD), size: 18),
            SizedBox(width: 8),
            Text(
              'Daily Motivation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Divider(color: Color(0x45FFFFFF), thickness: 1, height: 1),
        SizedBox(height: 8),
        Text(
          'No quote found right now.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}

class _MotivationalQuote {
  const _MotivationalQuote({required this.text, required this.author});

  final String text;
  final String author;

  factory _MotivationalQuote.fromJson(Map<String, dynamic> json) {
    return _MotivationalQuote(
      text: (json['quote'] as String? ?? '').trim(),
      author: (json['author'] as String? ?? 'Unknown').trim(),
    );
  }
}
