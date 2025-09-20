import 'dart:async';
import 'package:flutter/material.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/home_page.dart';
import 'package:muktiya_new/pages/voice_page.dart';
import 'package:muktiya_new/pages/profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:muktiya_new/services/youtube_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with AutomaticKeepAliveClientMixin {
  // Controllers and variables for video slider
  final PageController _videoPageController = PageController();
  Timer? _videoTimer;
  int _currentVideoPage = 0;

  // YouTube service
  late YouTubeService _youtubeService;

  // Loading state
  bool _loadingVideos = true;

  // List for video data with thumbnails
  List<Map<String, dynamic>> _videoData = [];

  @override
  bool get wantKeepAlive => true;

  // Sample book data with URLs
  final List<Map<String, dynamic>> books = [
    {
      'title':
          'Governing With Heart: Ahilyabai Holkar’s Vision for A Harmonious World',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/deviahilya.png',
      'description':
          'A comprehensive guide to natural healing methods and holistic health practices.',
      'url': 'https://drive.google.com/file/d/1UQNuEYMoyaiG7H7DOJrEW2zVNzgvzAcd/view?usp=sharing',
    },
    {
      'title':
          'Dr. Swatantra AI A Revolutionary Kalpavriksha AI for Global Welfare',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/swatantra_ai_book.png',
      'description':
          'Discover effective homeopathic remedies for common ailments and chronic conditions.',
      'url': 'https://drive.google.com/file/d/10oyeqPL17ZvdfJaofpYMw1EotI7lPMld/view?usp=sharing',
    },
    {
      'title': 'Universal Prosperity: The Dawn of Satyug',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/universal_prosperity.png',
      'description':
          'Understanding the powerful connection between mental and physical health.',
      'url': 'https://tinyurl.com/mps23bru',
    },
    {
      'title': 'The Timeless Path to Vitality',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/timeless_path.png',
      'description':
          'Understanding the powerful connection between mental and physical health.',
      'url': 'https://drive.google.com/file/d/1iV9piIHfG5DBiHVeL5cR2IHaz3uZ_1MP/view?usp=sharing',
    },
  ];

  // Sample YouTube videos data with video IDs
  final List<Map<String, dynamic>> videos = [
    {
      'title': 'Sun Bath: Athapa Snana',
      'videoId': 'jOp5cT-eOdM',
      'description':
          'Learn the ancient practice of sun bathing for health benefits.',
    },
    {
      'title': 'Wet Wrap: Dr Jain\'s Method',
      'videoId': 'y9hSPqxaEKc',
      'description': 'Discover the healing effects of wet wraps for your body.',
    },
    {
      'title': 'Energy Asana',
      'videoId': 'vbkeJp2riP4',
      'description': 'Boost your energy levels with these special asanas.',
    },
    {
      'title': '4G Meal: Traditional Grain',
      'videoId': 'Re2yzSvsdeU',
      'description': 'Nutritious traditional grain meals for optimal health.',
    },
    {
      'title': 'Meditation: As natural as your breath',
      'videoId': 'mQnvKjs5bC8',
      'description':
          'Learn meditation techniques that flow as naturally as your breathing.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _youtubeService = YouTubeService();
    _fetchVideoThumbnails();
    Future.delayed(const Duration(seconds: 1), () {
      _initVideoTimer();
    });
  }

  void _initVideoTimer() {
    _videoTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;

      if (_currentVideoPage < videos.length - 1) {
        _currentVideoPage++;
      } else {
        _currentVideoPage = 0;
      }

      if (_videoPageController.hasClients) {
        _videoPageController.animateToPage(
          _currentVideoPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _videoTimer?.cancel();
    _videoPageController.dispose();
    _youtubeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page title
              const Text(
                'Discover & Learn',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Explore wellness content & resources',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 32),

              // Transform Yourself section with YouTube videos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transform Yourself',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _launchURL('https://greatchyren.com/our-videos/');
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // YouTube video carousel with modern design
              SizedBox(
                height: 240,
                child: _loadingVideos
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF667EEA),
                            ),
                          ),
                        ),
                      )
                    : PageView.builder(
                        controller: _videoPageController,
                        itemCount: _videoData.isNotEmpty
                            ? _videoData.length
                            : videos.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentVideoPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final video = _videoData.isNotEmpty
                              ? _videoData[index]
                              : videos[index];
                          return _buildVideoCard(video);
                        },
                      ),
              ),

              // Video pagination dots
              if (_videoData.isNotEmpty || videos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _videoData.isNotEmpty ? _videoData.length : videos.length,
                      (index) => _buildDot(index, _currentVideoPage),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Books section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Wellness Library',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigation to view all books
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFF667EEA),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Books grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return _buildModernBookCard(book);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        if (book.containsKey('url') && book['url'] != null) {
          _launchURL(book['url'] as String);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book link not available.'),
              backgroundColor: Colors.black87,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    book['coverImage'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF0F4FF),
                        child: Center(
                          child: Icon(
                            Icons.book,
                            size: 40,
                            color: const Color(0xFF667EEA).withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Book details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book['author'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final bool hasThumbnail =
        video.containsKey('thumbnailUrl') &&
        video['thumbnailUrl'] != null &&
        video['thumbnailUrl'].isNotEmpty;

    return GestureDetector(
      onTap: () {
        _launchYouTubeVideo(video['videoId']);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: hasThumbnail
                        ? CachedNetworkImage(
                            imageUrl: video['thumbnailUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              return _buildVideoErrorPlaceholder(video);
                            },
                          )
                        : _buildVideoErrorPlaceholder(video),
                  ),

                  // Dark overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Play button
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF667EEA),
                        size: 30,
                      ),
                    ),
                  ),

                  // Title overlay
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      video['title'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoErrorPlaceholder(Map<String, dynamic> video) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                video['title'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, int currentIndex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentIndex == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: currentIndex == index
            ? const Color(0xFF667EEA)
            : const Color(0xFF667EEA).withOpacity(0.3),
      ),
    );
  }

  _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      bool canLaunch = false;
      try {
        canLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('URL launcher plugin error: $e');
        canLaunch = false;
      }

      if (!canLaunch) {
        print('Could not launch $url, showing dialog instead');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Open Link'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Would you like to open this link?'),
                    const SizedBox(height: 8),
                    Text(
                      url,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Copy Link'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error handling URL: $e');
    }
  }

  void _launchYouTubeVideo(String videoId) {
    try {
      final String youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
      final Uri uri = Uri.parse(youtubeUrl);

      launchUrl(uri, mode: LaunchMode.externalApplication)
          .then((success) {
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening video in browser...'),
                  duration: Duration(seconds: 2),
                ),
              );

              launchUrl(uri, mode: LaunchMode.inAppWebView).catchError((error) {
                print('Error opening YouTube URL: $error');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not open video. Please try again later.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return false;
              });
            }
          })
          .catchError((error) {
            print('Error opening YouTube URL: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open video. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          });
    } catch (e) {
      print('General error launching YouTube: $e');
    }
  }

  Future<void> _fetchVideoThumbnails() async {
    setState(() {
      _loadingVideos = true;
    });

    try {
      final List<String> videoIds = videos
          .map<String>((video) => video['videoId'] as String)
          .toList();

      final videoDetails = await _youtubeService.getMultipleVideoDetails(
        videoIds,
      );

      if (mounted) {
        setState(() {
          _videoData = videoDetails;
          _loadingVideos = false;
        });
      }
    } catch (e) {
      print('Error fetching video thumbnails: $e');

      if (mounted) {
        setState(() {
          _videoData = videos.map((video) {
            final String videoId = video['videoId'] as String;
            return {
              ...video,
              'thumbnailUrl': _youtubeService.getYouTubeThumbnailUrl(
                videoId,
                quality: 'maxres',
              ),
              'author': 'Dr. Swatantra Jain',
            };
          }).toList();
          _loadingVideos = false;
        });
      }
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '';

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }
}
