import 'dart:async';
import 'package:flutter/material.dart';
import 'package:muktiya_new/pages/chatbot_page.dart';
import 'package:muktiya_new/pages/home_page.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:muktiya_new/services/youtube_service.dart'; // Import YouTube service
import 'package:cached_network_image/cached_network_image.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with AutomaticKeepAliveClientMixin {
  int _selectedTab = 0; // Set to 0 for Explore tab
  
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
  bool get wantKeepAlive => true; // Keep state when navigating away

  // Sample book data
  final List<Map<String, dynamic>> books = [
    {
      'title': 'Natural Healing Wisdom',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/hands.png',
      'description': 'A comprehensive guide to natural healing methods and holistic health practices.',
    },
    {
      'title': 'Homeopathic Remedies',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/hands.png',
      'description': 'Discover effective homeopathic remedies for common ailments and chronic conditions.',
    },
    {
      'title': 'Mind-Body Connection',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/hands.png',
      'description': 'Understanding the powerful connection between mental and physical health.',
    },
    {
      'title': 'Meditation Techniques',
      'author': 'Dr. Swatantra Jain',
      'coverImage': 'assets/hands.png',
      'description': 'Simple yet powerful meditation techniques for daily practice and spiritual growth.',
    },
  ];

  // Sample YouTube videos data with video IDs
  final List<Map<String, dynamic>> videos = [
    {
      'title': 'Sun Bath: Athapa Snana',
      'videoId': 'nRvGvR9TM0Q', // YouTube video ID
      'description': 'Learn the ancient practice of sun bathing for health benefits.',
    },
    {
      'title': 'Wet Wrap: Dr Jain\'s Method',
      'videoId': '1Kwjja5Q6IQ', // YouTube video ID
      'description': 'Discover the healing effects of wet wraps for your body.',
    },
    {
      'title': 'Energy Asana',
      'videoId': 'mbdBC5katc8', // YouTube video ID
      'description': 'Boost your energy levels with these special asanas.',
    },
    {
      'title': '4G Meal: Traditional Grain',
      'videoId': '8L7e1qrQdmQ', // YouTube video ID
      'description': 'Nutritious traditional grain meals for optimal health.',
    },
    {
      'title': 'Meditation: As natural as your breath',
      'videoId': 'nl00xG4h1o0', // YouTube video ID
      'description': 'Learn meditation techniques that flow as naturally as your breathing.',
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize YouTube service
    _youtubeService = YouTubeService();
    
    // Fetch video thumbnails
    _fetchVideoThumbnails();
    
    // Delay the auto-scrolling timer to allow the UI to settle first
    Future.delayed(Duration(seconds: 1), () {
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0E6FF),  // Light lavender
                  Color(0xFFE6D9FF),  // Slightly darker lavender
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.elliptical(200, 60),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 20, color: Color(0xFF4A2B5C)),
                            const SizedBox(width: 8),
                            Text(
                              'Explore',
                              style: TextStyle(
                                color: Color(0xFF4A2B5C),
                                fontSize: 16,
                                fontFamily: 'Serif',
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.search, color: Color(0xFF4A2B5C)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Discover Yourself',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF4A2B5C),
                        fontFamily: 'Serif',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Explore our collection of books on natural healing',
                      style: TextStyle(
                        color: Color(0xFF4A2B5C).withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          
          // Books section
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transform Yourself section with YouTube videos
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transform Yourself',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2B5C),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _launchURL('https://greatchyren.com/our-videos/');
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF8B4C9B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // YouTube video carousel
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _loadingVideos 
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4C9B)),
                            ),
                          )
                        : PageView.builder(
                            controller: _videoPageController,
                            itemCount: _videoData.isNotEmpty ? _videoData.length : videos.length,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _videoData.length > 0 ? _videoData.length : videos.length,
                          (index) => _buildDot(index, _currentVideoPage),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Books section (moved below Transform Yourself)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Books',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2B5C),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigation to view all books
                            },
                            child: Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF8B4C9B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Horizontal scrollable book list
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return _buildBookCard(book);
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Featured book section
                    Text(
                      'Featured Book',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2B5C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeaturedBook(books[0]),
                    
                    const SizedBox(height: 32),
                    
                    // New releases section
                    Text(
                      'New Releases',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2B5C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Vertically stacked book list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: books.length > 2 ? 2 : books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return _buildBookListItem(book);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: _selectedTab == 1,
                onTap: () {
                  setState(() => _selectedTab = 1);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              _buildTabItem(
                icon: Icons.water_drop,
                label: 'Explore',
                isSelected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
              ),
              _buildTabItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isSelected: _selectedTab == 3,
                onTap: () {
                  setState(() => _selectedTab = 3);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Book card for horizontal scrolling
  Widget _buildBookCard(Map<String, dynamic> book) {
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 150, // Reduced height slightly
              decoration: BoxDecoration(
                color: Color(0xFFF0E6FF),
                border: Border.all(
                  color: Color(0xFF8B4C9B).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Image.asset(
                book['coverImage'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFF0E6FF),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 50,
                        color: Color(0xFF8B4C9B).withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4), // Reduced spacing
          // Book title
          Text(
            book['title'],
            style: TextStyle(
              fontSize: 13, // Smaller font size
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A2B5C),
            ),
            maxLines: 1, // Limit to 1 line
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Author name
          Flexible(
            child: Text(
              book['author'],
              style: TextStyle(
                fontSize: 11, // Smaller font size
                color: Color(0xFF4A2B5C).withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Featured book with larger display and description
  Widget _buildFeaturedBook(Map<String, dynamic> book) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0E6FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF8B4C9B).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 100,
              height: 140,
              color: Color(0xFFF0E6FF),
              child: Image.asset(
                book['coverImage'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFF0E6FF),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 40,
                        color: Color(0xFF8B4C9B).withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Book details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2B5C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A2B5C).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  book['description'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4A2B5C).withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Open book details
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B4C9B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Read Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // List item for vertical book list
  Widget _buildBookListItem(Map<String, dynamic> book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 70,
              height: 90,
              color: Color(0xFFF0E6FF),
              child: Image.asset(
                book['coverImage'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Color(0xFFF0E6FF),
                    child: Center(
                      child: Icon(
                        Icons.book,
                        size: 30,
                        color: Color(0xFF8B4C9B).withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Book details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2B5C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A2B5C).withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A2B5C).withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? _getFilledIcon(icon) : icon,
              color: isSelected ? const Color(0xFF8B4C9B) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF8B4C9B) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFilledIcon(IconData outlinedIcon) {
    // Map outlined icons to their filled counterparts
    switch (outlinedIcon) {
      case Icons.home_outlined:
        return Icons.home;
      case Icons.water_drop:
        return Icons.water_drop;
      case Icons.chat_bubble_outline:
        return Icons.chat_bubble;
      default:
        return outlinedIcon;
    }
  }

  // Safer URL launcher method that works on all platforms and handles errors gracefully
  _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      // Check if we're on mobile by testing if url_launcher is available
      bool canLaunch = false;
      try {
        canLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        // url_launcher might not be initialized
        print('URL launcher plugin error: $e');
        canLaunch = false;
      }
      
      if (!canLaunch) {
        // Fallback for web or when plugin isn't available
        print('Could not launch $url, showing dialog instead');
        
        // Show a dialog instead
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Open Link'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Would you like to open this link?'),
                    SizedBox(height: 8),
                    Text(
                      url,
                      style: TextStyle(
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
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Copy URL to clipboard as a fallback
                    // This would require clipboard package in a real app
                  },
                  child: Text('Copy Link'),
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

  // Direct method to launch YouTube videos that works more reliably on Android
  void _launchYouTubeVideo(String videoId) {
    try {
      final String youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
      final Uri uri = Uri.parse(youtubeUrl);
      
      // First attempt: Launch directly without confirmation dialog
      launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ).then((success) {
        if (!success) {
          // Fallback to showing alert
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening video in browser...'),
              duration: Duration(seconds: 2),
            )
          );
          
          // Try again with inAppWebView mode as fallback
          launchUrl(
            uri,
            mode: LaunchMode.inAppWebView,
          ).catchError((error) {
            print('Error opening YouTube URL: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open video. Please try again later.'),
                backgroundColor: Colors.red,
              )
            );
          });
        }
      }).catchError((error) {
        print('Error opening YouTube URL: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open video. Please try again.'),
            backgroundColor: Colors.red,
          )
        );
      });
    } catch (e) {
      print('General error launching YouTube: $e');
    }
  }

  // Video card for YouTube videos - updated to use actual YouTube thumbnails
  Widget _buildVideoCard(Map<String, dynamic> video) {
    final bool hasThumbnail = video.containsKey('thumbnailUrl') && video['thumbnailUrl'] != null && video['thumbnailUrl'].isNotEmpty;
    
    return GestureDetector(
      onTap: () {
        _launchYouTubeVideo(video['videoId']);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail and play button area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // YouTube thumbnail with fallback gradient background
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: hasThumbnail
                        ? CachedNetworkImage(
                            imageUrl: video['thumbnailUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF0E6FF),  // Light lavender
                                    Color(0xFFE6D9FF),  // Slightly darker lavender
                                  ],
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4C9B)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              // If high quality thumbnail fails, try medium quality
                              if (url.contains('hqdefault')) {
                                return CachedNetworkImage(
                                  imageUrl: _youtubeService.getYouTubeThumbnailUrl(video['videoId'], quality: 'mq'),
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => _buildVideoErrorPlaceholder(video),
                                );
                              }
                              return _buildVideoErrorPlaceholder(video);
                            },
                          )
                        : _buildVideoErrorPlaceholder(video),
                  ),
                  
                  // Dark overlay for better text visibility
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Title overlay at top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        video['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  
                  // Author/channel name if available
                  if (video.containsKey('author') && video['author'] != null && video['author'].toString().isNotEmpty)
                    Positioned(
                      top: 60,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video['author'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  
                  // Play button overlay in center
                  Center(
                    child: Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // Add duration badge if available
                  if (video.containsKey('duration') && video['duration'] != null)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(video['duration']),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // "Watch on YouTube" banner at bottom
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF003366),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Watch on',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.play_circle_filled,
                    color: Colors.red,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'YouTube',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  // Helper method to select appropriate icons for videos based on title
  IconData _getVideoIcon(String title) {
    if (title.toLowerCase().contains('sun bath')) {
      return Icons.wb_sunny_outlined;
    } else if (title.toLowerCase().contains('wet wrap')) {
      return Icons.water_drop_outlined;
    } else if (title.toLowerCase().contains('energy')) {
      return Icons.bolt_outlined;
    } else if (title.toLowerCase().contains('meal')) {
      return Icons.restaurant_outlined;
    } else if (title.toLowerCase().contains('meditation')) {
      return Icons.self_improvement_outlined;
    } else {
      return Icons.healing_outlined;
    }
  }

  // Dot indicator for video pagination
  Widget _buildDot(int index, int currentIndex) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: currentIndex == index ? Color(0xFF8B4C9B) : Color(0xFF8B4C9B).withOpacity(0.3),
      ),
    );
  }

  // Fetch YouTube thumbnails and video details
  Future<void> _fetchVideoThumbnails() async {
    setState(() {
      _loadingVideos = true;
    });
    
    try {
      // Extract video IDs from the videos list
      final List<String> videoIds = videos.map<String>((video) => video['videoId'] as String).toList();
      
      // Fetch video details including thumbnails
      final videoDetails = await _youtubeService.getMultipleVideoDetails(videoIds);
      
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
          // If there's an error, create a basic video data set with thumbnail URLs
          _videoData = videos.map((video) {
            final String videoId = video['videoId'] as String;
            return {
              ...video,
              'thumbnailUrl': _youtubeService.getYouTubeThumbnailUrl(videoId, quality: 'maxres'),
              'author': 'Dr. Swatantra Jain',  // Default author when data isn't available
            };
          }).toList();
          _loadingVideos = false;
        });
      }
    }
  }

  // Video error handler
  Widget _buildVideoErrorPlaceholder(Map<String, dynamic> video) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0E6FF),  // Light lavender
            Color(0xFFE6D9FF),  // Slightly darker lavender
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getVideoIcon(video['title']),
              size: 60,
              color: Color(0xFF8B4C9B).withOpacity(0.7),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                video['title'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF4A2B5C),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format duration for display
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