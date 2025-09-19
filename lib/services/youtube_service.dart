import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeService {
  // Method to get video details including thumbnail URLs
  Future<Map<String, dynamic>> getVideoDetails(String videoId) async {
    // Directly construct thumbnail URLs using YouTube's thumbnail pattern
    final thumbnailUrl = getYouTubeThumbnailUrl(videoId);

    try {
      // We'll make a lightweight request to get basic video info
      // This is more reliable than using a full YouTube API client
      final response = await http
          .get(
            Uri.parse(
              'https://www.youtube.com/oembed?url=https://www.youtube.com/watch?v=$videoId&format=json',
            ),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'title': data['title'] ?? 'YouTube Video',
          'thumbnailUrl': thumbnailUrl,
          'videoId': videoId,
          'description': data['title'] ?? 'YouTube Video',
          'author': data['author_name'] ?? 'YouTube Creator',
          'duration': null, // Duration not available via oembed
        };
      } else {
        // Fallback to just using the video ID and thumbnail
        return _createFallbackVideoDetails(videoId);
      }
    } catch (e) {
      print('Error fetching video details for $videoId: $e');
      return _createFallbackVideoDetails(videoId);
    }
  }

  // Creates fallback video details with the thumbnail URL
  Map<String, dynamic> _createFallbackVideoDetails(String videoId) {
    return {
      'title': 'YouTube Video',
      'thumbnailUrl': getYouTubeThumbnailUrl(videoId),
      'videoId': videoId,
      'description': 'Tap to watch this video on YouTube',
      'author': '',
      'duration': null,
    };
  }

  // Get YouTube thumbnail URL directly from video ID
  // This is more reliable than fetching from the API
  String getYouTubeThumbnailUrl(String videoId, {String quality = 'hq'}) {
    // Available qualities:
    // maxres: maxresdefault.jpg (1280x720)
    // hq: hqdefault.jpg (480x360)
    // mq: mqdefault.jpg (320x180)
    // sd: default.jpg (120x90)
    // 0,1,2,3: specific frames from the video (120x90)

    switch (quality) {
      case 'maxres':
        return 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';
      case 'mq':
        return 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      case 'sd':
        return 'https://img.youtube.com/vi/$videoId/default.jpg';
      case 'hq':
      default:
        return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
  }

  // Get multiple video details at once
  Future<List<Map<String, dynamic>>> getMultipleVideoDetails(
    List<String> videoIds,
  ) async {
    final List<Map<String, dynamic>> results = [];

    for (final videoId in videoIds) {
      try {
        final details = await getVideoDetails(videoId);
        results.add(details);
      } catch (e) {
        print('Error processing video $videoId: $e');
        // Add fallback entry
        results.add(_createFallbackVideoDetails(videoId));
      }
    }

    return results;
  }

  void dispose() {
    // No resources to dispose in this implementation
  }
}
