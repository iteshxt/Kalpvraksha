import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class QuoteService {
  static const String _quotesKey = 'daily_quotes';
  static const String _lastFetchKey = 'last_fetch_date';
  static const String _batchIndexKey = 'quote_batch_index';
  static const String _jsonFilePath =
      'assets/quotes.json'; // Path to your JSON file

  static Future<List<Map<String, String>>> _fetchQuotesFromFile() async {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString(_jsonFilePath);
      final List<dynamic> jsonData = json.decode(jsonString);

      // Convert to the required format
      List<Map<String, String>> allQuotes = jsonData.map<Map<String, String>>((
        item,
      ) {
        return {
          'quote': item['quote'].toString(),
          'author': item['author'].toString(),
        };
      }).toList();

      // Get current batch index from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      int currentBatchIndex = prefs.getInt(_batchIndexKey) ?? 0;

      // Calculate how many complete batches we can make
      int totalBatches = (allQuotes.length / 5).ceil();

      // Ensure batch index is within bounds (loop back to 0 if needed)
      if (currentBatchIndex >= totalBatches) {
        currentBatchIndex = 0;
      }

      // Calculate start and end indices for current batch
      int startIndex = currentBatchIndex * 5;
      int endIndex = (startIndex + 5).clamp(0, allQuotes.length);

      // Get the current batch of quotes
      List<Map<String, String>> batchQuotes = allQuotes.sublist(
        startIndex,
        endIndex,
      );

      // If we don't have 5 quotes in this batch (last batch might be smaller),
      // fill remaining with quotes from the beginning
      if (batchQuotes.length < 5 && allQuotes.length > 5) {
        int remaining = 5 - batchQuotes.length;
        List<Map<String, String>> additionalQuotes = allQuotes
            .take(remaining)
            .toList();
        batchQuotes.addAll(additionalQuotes);
      }

      // Update batch index for next day (move to next batch)
      int nextBatchIndex = currentBatchIndex + 1;
      if (nextBatchIndex >= totalBatches) {
        nextBatchIndex = 0; // Loop back to beginning
      }
      await prefs.setInt(_batchIndexKey, nextBatchIndex);

      return batchQuotes.take(5).toList();
    } catch (e) {
      print('Error loading quotes from file: $e');
      return _getFallbackQuotes();
    }
  }

  static List<Map<String, String>> _getFallbackQuotes() {
    return [
      {
        'quote':
            'Your mind is a garden where thoughts bloom into reality. Plant seeds of positivity today.',
        'author': 'Dr. Marina Wellness',
      },
      {
        'quote':
            'Every breath is a new beginning, every moment a chance to choose peace over chaos.',
        'author': 'Chen Mindful',
      },
      {
        'quote':
            'Healing happens in the spaces between thoughts, in the silence between heartbeats.',
        'author': 'Dr. Alexander Serenity',
      },
      {
        'quote':
            'Your wellness journey is not about perfection, but about progress and self-compassion.',
        'author': 'Sofia Brightpath',
      },
      {
        'quote':
            'In the orchestra of life, your mental health sets the rhythm for everything else.',
        'author': 'Dr. Michael Innerpeace',
      },
    ];
  }

  static Future<List<Map<String, String>>> getDailyQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastFetch = prefs.getString(_lastFetchKey);

    // Check if we need to fetch new quotes (24 hours have passed)
    if (lastFetch != today) {
      try {
        final quotes = await _fetchQuotesFromFile();
        final quotesJson = quotes.map((q) => json.encode(q)).toList();
        await prefs.setStringList(_quotesKey, quotesJson);
        await prefs.setString(_lastFetchKey, today);
        return quotes;
      } catch (e) {
        print('Error fetching new quotes: $e');
        return _getStoredQuotes();
      }
    } else {
      return _getStoredQuotes();
    }
  }

  static Future<List<Map<String, String>>> _getStoredQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final quotesJson = prefs.getStringList(_quotesKey);

    if (quotesJson != null) {
      return quotesJson.map<Map<String, String>>((q) {
        final decoded = json.decode(q);
        return {
          'quote': decoded['quote'] as String,
          'author': decoded['author'] as String,
        };
      }).toList();
    }
    return _getFallbackQuotes();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  Timer? _timer;
  Timer? _greetingTimer;
  int _currentPage = 0;
  final AuthService _authService = AuthService();

  List<Map<String, String>> _dailyQuotes = [];
  bool _isLoadingQuotes = true;

  @override
  void initState() {
    super.initState();
    _loadDailyQuotes();
    _greetingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  Future<void> _loadDailyQuotes() async {
    try {
      final quotes = await QuoteService.getDailyQuotes();
      setState(() {
        _dailyQuotes = quotes;
        _isLoadingQuotes = false;
      });
      _startAutoSlider();
    } catch (e) {
      setState(() => _isLoadingQuotes = false);
    }
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_dailyQuotes.isNotEmpty) {
        if (_currentPage < _dailyQuotes.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _greetingTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getUserName() {
    final user = _authService.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        String displayName = user.displayName!.trim();
        if (displayName.contains('@')) {
          String emailName = displayName.split('@').first;
          return emailName[0].toUpperCase() + emailName.substring(1);
        }
        String firstName = displayName.split(' ').first.trim();
        if (firstName.isNotEmpty) {
          return firstName[0].toUpperCase() +
              firstName.substring(1).toLowerCase();
        }
      }
      if (user.email != null) {
        String emailName = user.email!.split('@').first;
        return emailName[0].toUpperCase() +
            emailName.substring(1).toLowerCase();
      }
      if (user.isAnonymous) return 'Guest';
    }
    return 'Friend';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome text
              Text(
                'Welcome back, ${_getUserName()}!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // How are you feeling text
              const Text(
                'How are you feeling today?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              // Mood chips
              Row(
                children: [
                  _buildMoodChip('Calm', false),
                  const SizedBox(width: 12),
                  _buildMoodChip('Sleep', false),
                  const SizedBox(width: 12),
                  _buildMoodChip('Anxious', false),
                  const SizedBox(width: 12),
                  _buildMoodChip('Music', false),
                ],
              ),
              const SizedBox(height: 32),

              // AI Daily Quotes slider with page indicators
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: _isLoadingQuotes
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF667EEA),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Loading daily inspiration...',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _dailyQuotes.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Unable to load quotes. Please check your quotes file.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                        : PageView.builder(
                            controller: _pageController,
                            itemCount: _dailyQuotes.length,
                            onPageChanged: (page) =>
                                setState(() => _currentPage = page),
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF667EEA,
                                      ).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Daily Inspiration',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.psychology,
                                          size: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _dailyQuotes[index]['quote']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '— ${_dailyQuotes[index]['author']!}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Page indicators (dots)
                  if (!_isLoadingQuotes && _dailyQuotes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _dailyQuotes.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF667EEA)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Wellness session card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E4F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'A 10-minute sessions for today\'s mood',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '14 Sessions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.self_improvement,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recommendation section
              const Text(
                'Recommendation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              // Recommendation cards
              Row(
                children: [
                  Expanded(
                    child: _buildRecommendationCard(
                      'Energize',
                      '14 Sessions',
                      Icons.flash_on,
                      const Color(0xFFFFE0E0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecommendationCard(
                      'Anxious',
                      '8 Sessions',
                      Icons.wb_sunny,
                      const Color(0xFFE0F4FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Additional wellness cards
              Row(
                children: [
                  Expanded(
                    child: _buildRecommendationCard(
                      'Sleep',
                      '12 Sessions',
                      Icons.nightlight_round,
                      const Color(0xFFF0E6FF),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecommendationCard(
                      'Focus',
                      '10 Sessions',
                      Icons.center_focus_strong,
                      const Color(0xFFE6F7FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Wellness tracking cards
              Row(
                children: [
                  Expanded(
                    child: _buildRecommendationCard(
                      'Mindfulness',
                      '16 Sessions',
                      Icons.psychology,
                      const Color(0xFFE8F5E8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildRecommendationCard(
                      'Breathe',
                      '6 Sessions',
                      Icons.air,
                      const Color(0xFFFFF0E6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    String subtitle,
    IconData icon,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.play_circle_outline,
                size: 16,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
