import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../theme_manager.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class ContentPage extends StatefulWidget {
  final String mood;
  final String userId;
  const ContentPage({super.key, required this.mood, required this.userId});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ThemeManager _themeManager = ThemeManager.instance;
  
  List<Map<String, dynamic>> youtubeMusic = [];
  List<Map<String, dynamic>> youtubeVideos = [];
  List<Map<String, dynamic>> feedPosts = [];
  bool isLoading = true;

  String? _currentlyPlayingId;
  Map<String, dynamic>? _currentTrack;
  final String youtubeApiKey = 'MyApiKey';
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  YoutubePlayerController? _musicController;
  
  // Track video controllers for proper disposal
  final Map<String, YoutubePlayerController> _videoControllers = {};
  final Map<String, bool> _videoPlayingStates = {};
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  XFile? _selectedVideo;

  // Database configuration
  final String baseUrl = 'https://humancc.site/shifaqmawaddah/jars_app/api';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Listen for tab changes to manage music player
    _tabController.addListener(() {
      if (_tabController.indexIsChanging && _tabController.index != 0) {
        _pauseCurrentMusic();
      }
    });
    
    fetchAllContent();
    _loadFeedPosts();
    _themeManager.addListener(_onThemeChanged);
  }

  @override
  void didUpdateWidget(covariant ContentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _cleanupPlayers();
      fetchAllContent();
      _loadFeedPosts();
    }
  }

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    _cleanupPlayers();
    _tabController.dispose();
    
    _themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _cleanupPlayers() {
    // Clean up music controller
    if (_musicController != null) {
      _musicController!.pause();
      _musicController!.dispose();
      _musicController = null;
    }
    
    // Clean up all video controllers
    for (final controller in _videoControllers.values) {
      controller.pause();
      controller.dispose();
    }
    _videoControllers.clear();
    _videoPlayingStates.clear();
    
    setState(() {
      _currentlyPlayingId = null;
      _currentTrack = null;
    });
  }

  void _pauseCurrentMusic() {
    if (_musicController != null) {
      _musicController!.pause();
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFD166);
      case 'sad':
        return const Color(0xFF6A9AB0);
      case 'angry':
        return const Color(0xFFEF476F);
      case 'fear':
        return const Color(0xFF9C89B8);
      case 'neutral':
        return const Color(0xFF8A817C);
      default:
        return const Color(0xFF6C757D);
    }
  }

  Future<void> fetchAllContent() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    await Future.wait([
      fetchYouTubeMusic(widget.mood),
      fetchYouTubeVideos(widget.mood),
    ]);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchYouTubeMusic(String mood) async {
    try {
      final moodQueries = {
        'happy': [
          "upbeat pop songs 2024 feel good",
          "happy dance music positive vibes",
          "summer hits good mood playlist",
          "disco funk uplifting energy",
          "indie pop cheerful melodies"
        ],
        'sad': [
          "sad songs playlist emotional ballads",
          "heartbreak R&B soul 2024",
          "melancholy acoustic guitar",
          "rainy day indie folk",
          "piano sad emotional instrumental"
        ],
        'angry': [
          "heavy metal workout motivation",
          "rap aggressive beats angry",
          "punk rock loud fast",
          "industrial electronic intense",
          "screamo hardcore cathartic"
        ],
        'fear': [
          "calming meditation music anxiety",
          "soothing ambient peaceful",
          "ASMR relaxation soft sounds",
          "lofi chill study beats",
          "spa music tranquility calm"
        ],
        'neutral': [
          "indie chill relaxed vibes",
          "acoustic coffee shop music",
          "background study focus",
          "instrumental ambient atmospheric",
          "vocal chill pop easy listening"
        ],
      };

      final queries = moodQueries[mood.toLowerCase()] ?? ["chill music playlist"];
      final randomQuery = queries[Random().nextInt(queries.length)];
      
      String additionalFilters = "";
      switch (mood.toLowerCase()) {
        case 'happy':
          additionalFilters = "official video -slowed -reverb";
          break;
        case 'sad':
          additionalFilters = "official audio -remix -speed";
          break;
        case 'angry':
          additionalFilters = "official video -acoustic -cover";
          break;
        case 'fear':
          additionalFilters = "no talking -instrumental -sleep";
          break;
        case 'neutral':
          additionalFilters = "no lyrics -chill -relax";
          break;
      }
      
      final query = "$randomQuery $additionalFilters";

      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&q=${Uri.encodeComponent(query)}'
        '&type=video'
        '&videoCategoryId=10'
        '&videoEmbeddable=true'
        '&maxResults=15'
        '&regionCode=US'
        '&relevanceLanguage=en'
        '&order=relevance'
        '&key=$youtubeApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        
        final List<Map<String, dynamic>> allResults = items.map<Map<String, dynamic>>((video) {
          final snippet = video['snippet'];
          return {
            'title': snippet['title'],
            'thumbnail': snippet['thumbnails']['medium']['url'],
            'videoId': video['id']['videoId'],
            'channel': snippet['channelTitle'],
            'views': '${Random().nextInt(500) + 100}K views',
            'description': snippet['description'] ?? '',
            'publishedAt': snippet['publishedAt'],
          };
        }).toList();

        youtubeMusic = allResults.where((video) {
          final title = video['title'].toString().toLowerCase();
          final description = video['description'].toString().toLowerCase();
          
          final excludeKeywords = [
            'reaction', 'lyrics', 'cover', 'remix', 'live',
            'karaoke', 'tutorial', 'meme', 'parody', 'reupload'
          ];
          
          final hasExcluded = excludeKeywords.any((keyword) => 
              title.contains(keyword) || description.contains(keyword));
          
          if (hasExcluded) return false;
          
          final moodLower = mood.toLowerCase();
          bool matchesMood = false;
          
          switch (moodLower) {
            case 'happy':
              final happyKeywords = ['happy', 'upbeat', 'dance', 'party', 'summer', 'feel good', 'positive', 'fun'];
              matchesMood = happyKeywords.any((word) => title.contains(word));
              break;
            case 'sad':
              final sadKeywords = ['sad', 'heartbreak', 'emotional', 'tears', 'miss', 'goodbye', 'alone', 'pain'];
              matchesMood = sadKeywords.any((word) => title.contains(word));
              break;
            case 'angry':
              final angryKeywords = ['angry', 'rage', 'furious', 'heavy', 'metal', 'aggressive', 'intense', 'scream'];
              matchesMood = angryKeywords.any((word) => title.contains(word));
              break;
            case 'fear':
              final fearKeywords = ['calm', 'peaceful', 'relax', 'meditation', 'chill', 'ambient', 'soothing', 'soft'];
              matchesMood = fearKeywords.any((word) => title.contains(word));
              break;
            case 'neutral':
              final neutralKeywords = ['chill', 'relaxed', 'ambient', 'instrumental', 'background', 'study', 'focus'];
              matchesMood = neutralKeywords.any((word) => title.contains(word));
              break;
          }
          
          return matchesMood;
        }).toList();
        
        if (youtubeMusic.length < 8 && allResults.isNotEmpty) {
          final needed = 8 - youtubeMusic.length;
          final additional = allResults
              .where((v) => !youtubeMusic.contains(v))
              .take(needed)
              .toList();
          youtubeMusic.addAll(additional);
        }
        
        if (youtubeMusic.length > 12) {
          youtubeMusic = youtubeMusic.sublist(0, 12);
        }
        
      } else {
        print('⚠️ Failed to fetch music. Status: ${response.statusCode}');
        _loadFallbackMusic(mood);
      }
    } catch (e) {
      print('⚠️ Music fetch error: $e');
      _loadFallbackMusic(mood);
    }
  }

  Future<void> fetchYouTubeVideos(String mood) async {
    try {
      final moodQueries = {
        'happy': [
          "funny moments compilation laugh",
          "cute animals pets joyful",
          "travel adventure beautiful nature",
          "success stories motivation",
          "dance performance celebration"
        ],
        'sad': [
          "emotional short films story",
          "comforting words empathy",
          "rainy day aesthetic",
          "healing journey documentary",
          "art therapy creative expression"
        ],
        'angry': [
          "anger management techniques",
          "intense workout motivation",
          "martial arts discipline",
          "cathartic art destruction",
          "standing up empowerment"
        ],
        'fear': [
          "anxiety relief techniques",
          "guided meditation calm",
          "breathing exercises stress",
          "safe space comfort",
          "gradual exposure therapy"
        ],
        'neutral': [
          "documentary learning interesting",
          "art process creative",
          "nature documentary peaceful",
          "science explainer educational",
          "daily vlog chill"
        ],
      };

      final queries = moodQueries[mood.toLowerCase()] ?? ["interesting video"];
      final randomQuery = queries[Random().nextInt(queries.length)];
      
      String therapeuticKeywords = "";
      switch (mood.toLowerCase()) {
        case 'fear':
          therapeuticKeywords = "anxiety relief help calm";
          break;
        case 'sad':
          therapeuticKeywords = "comfort support healing";
          break;
        case 'angry':
          therapeuticKeywords = "management control channel";
          break;
      }
      
      final query = "$randomQuery $therapeuticKeywords -prank -challenge -clickbait";

      final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search'
        '?part=snippet'
        '&q=${Uri.encodeComponent(query)}'
        '&type=video'
        '&videoEmbeddable=true'
        '&maxResults=15'
        '&regionCode=US'
        '&relevanceLanguage=en'
        '&order=relevance'
        '&key=$youtubeApiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        
        final random = Random();
        final List<Map<String, dynamic>> allResults = items.map<Map<String, dynamic>>((video) {
          final snippet = video['snippet'];
          return {
            'title': snippet['title'],
            'thumbnail': snippet['thumbnails']['high']['url'],
            'videoId': video['id']['videoId'],
            'channel': snippet['channelTitle'],
            'publishedAt': snippet['publishedAt'],
            'views': '${random.nextInt(800) + 50}K views',
            'duration': '${random.nextInt(15) + 1}:${random.nextInt(60).toString().padLeft(2, '0')}',
            'avatar': 'https://i.pravatar.cc/150?img=${random.nextInt(70)}',
            'description': snippet['description'] ?? '',
          };
        }).toList();

        youtubeVideos = allResults.where((video) {
          final title = video['title'].toString().toLowerCase();
          final description = video['description'].toString().toLowerCase();
          
          final excludeVideoTypes = [
            'prank', 'challenge', 'unboxing', 'sponsor',
            'advertisement', 'buy now', 'click here', 'reaction'
          ];
          
          final hasExcluded = excludeVideoTypes.any((keyword) => 
              title.contains(keyword) || description.contains(keyword));
          
          if (hasExcluded) return false;
          
          final moodLower = mood.toLowerCase();
          bool matchesMood = false;
          
          switch (moodLower) {
            case 'happy':
              final happyVidKeywords = ['funny', 'cute', 'joy', 'smile', 'laugh', 'happy', 'positive'];
              matchesMood = happyVidKeywords.any((word) => title.contains(word));
              break;
            case 'sad':
              final sadVidKeywords = ['emotional', 'story', 'healing', 'comfort', 'sad', 'heartfelt'];
              matchesMood = sadVidKeywords.any((word) => title.contains(word));
              break;
            case 'angry':
              final angryVidKeywords = ['anger', 'management', 'workout', 'intense', 'cathartic', 'release'];
              matchesMood = angryVidKeywords.any((word) => title.contains(word));
              break;
            case 'fear':
              final fearVidKeywords = ['anxiety', 'calm', 'meditation', 'breathing', 'peaceful', 'relax'];
              matchesMood = fearVidKeywords.any((word) => title.contains(word));
              break;
            case 'neutral':
              final neutralVidKeywords = ['documentary', 'educational', 'interesting', 'learn', 'explain'];
              matchesMood = neutralVidKeywords.any((word) => title.contains(word));
              break;
          }
          
          return matchesMood;
        }).toList();
        
        if (youtubeVideos.length < 8 && allResults.isNotEmpty) {
          final needed = 8 - youtubeVideos.length;
          final additional = allResults
              .where((v) => !youtubeVideos.contains(v))
              .take(needed)
              .toList();
          youtubeVideos.addAll(additional);
        }
        
        if (youtubeVideos.length > 12) {
          youtubeVideos = youtubeVideos.sublist(0, 12);
        }
        
      } else {
        print('⚠️ Failed to fetch videos. Status: ${response.statusCode}');
        _loadFallbackVideos(mood);
      }
    } catch (e) {
      print('⚠️ Video fetch error: $e');
      _loadFallbackVideos(mood);
    }
  }

  void _loadFallbackMusic(String mood) {
    final fallbackMusic = {
      'happy': [
        {
          'title': 'Happy - Pharrell Williams',
          'thumbnail': 'https://i.ytimg.com/vi/ZbZSe6N_BXs/hqdefault.jpg',
          'videoId': 'ZbZSe6N_BXs',
          'channel': 'PharrellWilliamsVEVO',
          'views': '1.2B views',
        },
      ],
      'sad': [
        {
          'title': 'Someone Like You - Adele',
          'thumbnail': 'https://i.ytimg.com/vi/hLQl3WQQoQ0/hqdefault.jpg',
          'videoId': 'hLQl3WQQoQ0',
          'channel': 'adeleVEVO',
          'views': '2.1B views',
        },
      ],
      'angry': [
        {
          'title': 'Break Stuff - Limp Bizkit',
          'thumbnail': 'https://i.ytimg.com/vi/RWq7JGXxqW0/hqdefault.jpg',
          'videoId': 'RWq7JGXxqW0',
          'channel': 'Limp Bizkit',
          'views': '250M views',
        },
      ],
      'fear': [
        {
          'title': 'Weightless - Marconi Union',
          'thumbnail': 'https://i.ytimg.com/vi/UfcAVejslrU/hqdefault.jpg',
          'videoId': 'UfcAVejslrU',
          'channel': 'Just Music',
          'views': '45M views',
        },
      ],
      'neutral': [
        {
          'title': 'Chillhop Music',
          'thumbnail': 'https://i.ytimg.com/vi/5qap5aO4i9A/hqdefault.jpg',
          'videoId': '5qap5aO4i9A',
          'channel': 'Chillhop Music',
          'views': '300M views',
        },
      ],
    };

    final defaultList = [
      {
        'title': 'Popular Music Playlist',
        'thumbnail': 'https://i.ytimg.com/vi/9bZkp7q19f0/hqdefault.jpg',
        'videoId': '9bZkp7q19f0',
        'channel': 'Various Artists',
        'views': '500M views',
      },
    ];

    youtubeMusic = (fallbackMusic[mood.toLowerCase()] ?? defaultList);
  }

  void _loadFallbackVideos(String mood) {
    final fallbackVideos = {
      'happy': [
        {
          'title': 'Funny Animals Compilation',
          'thumbnail': 'https://i.ytimg.com/vi/J---aiyznGQ/hqdefault.jpg',
          'videoId': 'J---aiyznGQ',
          'channel': 'Funny Pets',
          'views': '50M views',
          'duration': '10:15',
          'avatar': 'https://i.pravatar.cc/150?img=10',
        },
      ],
      'sad': [
        {
          'title': 'A Short Film About Healing',
          'thumbnail': 'https://i.ytimg.com/vi/9OpGp7QqR1k/hqdefault.jpg',
          'videoId': '9OpGp7QqR1k',
          'channel': 'Soul Stories',
          'views': '8M views',
          'duration': '12:45',
          'avatar': 'https://i.pravatar.cc/150?img=40',
        },
      ],
      'angry': [
        {
          'title': 'Anger Management Techniques',
          'thumbnail': 'https://i.ytimg.com/vi/QsqLrHcFYfg/hqdefault.jpg',
          'videoId': 'QsqLrHcFYfg',
          'channel': 'Mental Health Support',
          'views': '12M views',
          'duration': '9:45',
          'avatar': 'https://i.pravatar.cc/150?img=20',
        },
      ],
      'fear': [
        {
          'title': '5-Minute Meditation for Anxiety',
          'thumbnail': 'https://i.ytimg.com/vi/inpok4MKVLM/hqdefault.jpg',
          'videoId': 'inpok4MKVLM',
          'channel': 'Calm',
          'views': '25M views',
          'duration': '5:00',
          'avatar': 'https://i.pravatar.cc/150?img=30',
        },
      ],
      'neutral': [
        {
          'title': 'Interesting Science Documentary',
          'thumbnail': 'https://i.ytimg.com/vi/6v2L2UGZJAM/hqdefault.jpg',
          'videoId': '6v2L2UGZJAM',
          'channel': 'Science Channel',
          'views': '30M views',
          'duration': '22:15',
          'avatar': 'https://i.pravatar.cc/150?img=50',
        },
      ],
    };

    final defaultList = [
      {
        'title': 'Relaxation Video',
        'thumbnail': 'https://i.ytimg.com/vi/1ZYbU82GVz4/hqdefault.jpg',
        'videoId': '1ZYbU82GVz4',
        'channel': 'Mindful Moments',
        'views': '30M views',
        'duration': '15:00',
        'avatar': 'https://i.pravatar.cc/150?img=1',
      },
    ];

    youtubeVideos = (fallbackVideos[mood.toLowerCase()] ?? defaultList);
  }

  Future<void> _loadFeedPosts() async {
    try {
      final encodedMood = Uri.encodeComponent(widget.mood);
      final url = Uri.parse('$baseUrl/get_posts.php?mood=$encodedMood');
      print('Fetching posts from: $url');
      
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      print('Posts response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('Posts data type: ${data.runtimeType}');
        
        if (data is Map && data['success'] == true) {
          final List<Map<String, dynamic>> dbPosts = 
              List<Map<String, dynamic>>.from(data['posts'] ?? []);
          
          print('Found ${dbPosts.length} posts from database');
          
          final List<Map<String, dynamic>> formattedPosts = dbPosts.map((dbPost) {
            final author = dbPost['username']?.toString() ?? 'User${dbPost['user_id']}';
            final avatar = dbPost['avatar']?.toString() ?? 'https://i.pravatar.cc/150?img=${(dbPost['user_id'] as int? ?? 0) % 70}';
            
            return {
              'id': dbPost['id'] is int ? dbPost['id'] : 
                    dbPost['id'] is String ? int.tryParse(dbPost['id']) ?? 0 : 0,
              'author': author,
              'avatar': avatar,
              'text': dbPost['content']?.toString() ?? '',
              'likes': dbPost['likes'] is int ? dbPost['likes'] : 
                      dbPost['likes'] is String ? int.tryParse(dbPost['likes']) ?? 0 : 0,
              'liked': false,
              'reposted': false,
              'time': _formatTime(dbPost['created_at']?.toString()),
              'comments': dbPost['comments'] ?? [],
              'showComments': false,
              'hasImage': dbPost['image_url'] != null && dbPost['image_url'].toString().isNotEmpty,
              'imageUrl': dbPost['image_url']?.toString(),
              'hasVideo': dbPost['video_url'] != null && dbPost['video_url'].toString().isNotEmpty,
              'videoUrl': dbPost['video_url']?.toString(),
              'isUserUpload': dbPost['user_id']?.toString() == widget.userId,
              'mood': dbPost['mood']?.toString() ?? widget.mood,
            };
          }).toList();
          
          setState(() {
            feedPosts = formattedPosts;
            print('Loaded ${feedPosts.length} posts into UI');
          });
        } else {
          print('API returned success: false');
          _loadSamplePosts();
        }
      } else {
        print('Failed to load posts: ${response.statusCode}');
        _loadSamplePosts();
      }
    } catch (e) {
      print('Error loading posts: $e');
      _loadSamplePosts();
    }
  }

  String _formatTime(String? dbTime) {
    if (dbTime == null) return 'Unknown time';
    
    try {
      final postTime = DateTime.parse(dbTime);
      final now = DateTime.now();
      final difference = now.difference(postTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(postTime);
      }
    } catch (e) {
      return dbTime;
    }
  }

  Future<void> _savePostToDatabase(Map<String, dynamic> postData) async {
  try {
    print('Starting post save process...');
    print('User ID from widget: ${widget.userId}');
    
    int? numericUserId;
    
    if (widget.userId.contains('@')) {
      numericUserId = await _getUserIdFromEmail(widget.userId);
      if (numericUserId == null) {
        print('Could not get/create user ID for: ${widget.userId}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User authentication failed')),
          );
        }
        return;
      }
      print('Got numeric user ID: $numericUserId');
    } else {
      numericUserId = int.tryParse(widget.userId) ?? 1;
      print('Using provided numeric ID: $numericUserId');
    }

    final Map<String, dynamic> requestData = {
      'user_id': numericUserId, // Must be numeric
      'mood': widget.mood,
      'content': postData['text']?.toString() ?? '',
    };

    String? imageUrl, videoUrl;
    
    if (_selectedImage != null) {
      print('Uploading image...');
      imageUrl = await _uploadMediaFile(_selectedImage!);
      if (imageUrl != null) {
        requestData['image_url'] = imageUrl;
        print('Image uploaded: $imageUrl');
      }
    }

    if (_selectedVideo != null) {
      print('Uploading video...');
      videoUrl = await _uploadMediaFile(_selectedVideo!);
      if (videoUrl != null) {
        requestData['video_url'] = videoUrl;
        print('Video uploaded: $videoUrl');
      }
    }

    final url = Uri.parse('$baseUrl/save_posts.php');
    print('Sending POST to: $url');
    print('Request data: $requestData');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    ).timeout(Duration(seconds: 15));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      print('Response data: $data');

      if (data is Map && data['success'] == true) {
        print('Post saved successfully! ID: ${data['post_id']}');
        
        // Update the local post with database ID
        if (mounted && feedPosts.isNotEmpty) {
          final postId = data['post_id'] ?? 0;
          setState(() {
            feedPosts[0]['id'] = postId;
            feedPosts[0]['isUserUpload'] = true;
          });
        }
        
        return;
      } else {
        final errorMsg = data['message'] ?? 'Unknown server error';
        print('Server error: $errorMsg');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server error: $errorMsg'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      print('HTTP Error ${response.statusCode}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e, stackTrace) {
    print('CRITICAL ERROR in _savePostToDatabase:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  // Get numeric user ID from email
  Future<int?> _getUserIdFromEmail(String email) async {
  try {
    print('Looking up user ID for email: $email');
    final url = Uri.parse('$baseUrl/get_user_id.php');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    ).timeout(Duration(seconds: 10));

    print('User ID response: ${response.statusCode}');
    print('User ID body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final userId = data['user_id'];
        print('Found user ID: $userId');
        return userId;
      }
    }
    return null;
  } catch (e) {
    print('Error getting user ID: $e');
    return null;
  }
}

  // Upload media file to server
  Future<String?> _uploadMediaFile(XFile file) async {
    try {
      final url = Uri.parse('$baseUrl/upload_media.php');
      final request = http.MultipartRequest('POST', url);
      
      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'media',
        fileStream,
        fileLength,
        filename: path.basename(file.path),
      );
      
      request.files.add(multipartFile);
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['url'] as String?;
        }
      }
      return null;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _saveCommentToDatabase(int postId, String comment) async {
    try {
      final url = Uri.parse('$baseUrl/save_comments.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postId.toString(),
          'user_id': widget.userId,
          'content': comment,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          print('Comment saved to database');
        }
      }
    } catch (e) {
      print('Error saving comment: $e');
    }
  }

  Future<void> _updatePostLikes(int postId, int likes) async {
    try {
      final url = Uri.parse('$baseUrl/update_likes.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postId.toString(),
          'user_id': widget.userId,
          'likes': likes.toString(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          print('Likes updated in database');
        }
      }
    } catch (e) {
      print('Error updating likes: $e');
    }
  }

  void _loadSamplePosts() {
    final moodSamples = {
      'happy': [
        "What a beautiful day! 🌞 Just finished my morning run and feeling amazing!",
        "Just discovered this amazing new coffee shop downtown! ☕",
      ],
      'sad': [
        "Feeling a bit down today... Sometimes life gets overwhelming 🌧️",
        "Memories hitting hard today. Missing old friends 💭",
      ],
      'angry': [
        "Need to vent this out before I explode 😤",
        "Why is everything so frustrating today? Taking deep breaths 🔥",
      ],
      'fear': [
        "Feeling anxious about tomorrow's presentation 😬",
        "Heart racing a bit... Trying mindfulness techniques 😟",
      ],
      'neutral': [
        "Just another day, finding my rhythm 😌",
        "Coffee in hand, thoughts flowing ☕",
      ],
    };

    final random = Random();
    final selected = moodSamples[widget.mood.toLowerCase()] ?? ['Hello world!'];
    
    feedPosts = List.generate(4, (index) {
      final postText = selected[random.nextInt(selected.length)];
      final comments = List.generate(random.nextInt(3), (i) {
        final commentSamples = [
          "I feel the same way!",
          "Thanks for sharing this",
          "Sending positive vibes ✨",
        ];
        return {
          'author': "User${random.nextInt(1000)}",
          'text': commentSamples[random.nextInt(commentSamples.length)],
          'time': '${random.nextInt(12) + 1}h ago',
          'avatar': 'https://i.pravatar.cc/150?img=${random.nextInt(70)}',
          'likes': random.nextInt(50),
        };
      });
      
      return {
        'id': index + 1,
        'author': "User${random.nextInt(10000)}",
        'avatar': 'https://i.pravatar.cc/150?img=${random.nextInt(70)}',
        'text': postText,
        'likes': random.nextInt(500),
        'liked': false,
        'reposted': false,
        'time': '${random.nextInt(24)}h ago',
        'comments': comments,
        'showComments': false,
        'hasImage': random.nextDouble() > 0.7,
        'imageUrl': random.nextDouble() > 0.7 
            ? 'https://picsum.photos/400/300?random=${random.nextInt(1000)}'
            : null,
        'hasVideo': false,
        'videoUrl': null,
        'isUserUpload': false,
      };
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _selectedVideo = null;
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImage = null;
      });
    }
  }

  void _removeMedia() {
    setState(() {
      _selectedImage = null;
      _selectedVideo = null;
    });
  }

  Widget _buildPlatformAwareImage({required String imageUrl, required bool isUserUpload}) {
    if (!isUserUpload || imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    }
    
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    }
  }

  void addPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty && _selectedImage == null && _selectedVideo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write something or add media to post'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final newPost = {
      'id': null,
      'author': "You",
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'text': text,
      'likes': 0,
      'liked': false,
      'reposted': false,
      'time': 'Just now',
      'comments': [],
      'showComments': false,
      'hasImage': _selectedImage != null,
      'imageUrl': _selectedImage?.path,
      'hasVideo': _selectedVideo != null,
      'videoUrl': _selectedVideo?.path,
      'isUserUpload': true,
      'mood': widget.mood,
    };
  
    if (mounted) {
      setState(() {
        feedPosts.insert(0, newPost);
      });
    }
 
    await _savePostToDatabase(newPost);
 
    if (mounted) {
      setState(() {
        _postController.clear();
        _selectedImage = null;
        _selectedVideo = null;
      });
    }
   
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Post published successfully!'),
          backgroundColor: _getThemeColor(),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void toggleLike(int index) async {
    if (index >= 0 && index < feedPosts.length) {
      setState(() {
        final post = feedPosts[index];
        if (post['liked'] == true) {
          post['liked'] = false;
          post['likes'] = (post['likes'] as int) - 1;
        } else {
          post['liked'] = true;
          post['likes'] = (post['likes'] as int) + 1;
        }
      });

      if (feedPosts[index]['id'] != null) {
        await _updatePostLikes(feedPosts[index]['id'], feedPosts[index]['likes']);
      }
    }
  }

  void toggleRepost(int index) {
    if (index >= 0 && index < feedPosts.length) {
      setState(() {
        final post = feedPosts[index];
        if (post['reposted'] != true) {
          feedPosts.insert(0, {
            ...post,
            'author': "You",
            'text': "🔁 Reposted: ${post['text']}",
            'reposted': true,
            'time': 'Just now',
            'isUserUpload': true,
          });
          post['reposted'] = true;
        }
      });
    }
  }

  void toggleComments(int index) {
    if (index >= 0 && index < feedPosts.length) {
      setState(() {
        feedPosts[index]['showComments'] = !feedPosts[index]['showComments'];
      });
    }
  }

  void addComment(int postIndex, String comment) async {
    if (postIndex < 0 || postIndex >= feedPosts.length || comment.trim().isEmpty) return;
    
    final newComment = {
      'author': "You",
      'text': comment,
      'time': 'Just now',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'likes': 0,
    };
    
    setState(() {
      if (feedPosts[postIndex]['comments'] is List) {
        feedPosts[postIndex]['comments'].insert(0, newComment);
      } else {
        feedPosts[postIndex]['comments'] = [newComment];
      }
      _commentController.clear();
    });
  
    if (feedPosts[postIndex]['id'] != null) {
      await _saveCommentToDatabase(feedPosts[postIndex]['id'], comment);
    }
  }

  void playMusic(Map<String, dynamic> track) {
    final String? videoId = track['videoId']?.toString();

    if (videoId == null) return;

    if (_currentlyPlayingId == videoId) {
      _musicController?.pause();
      setState(() {
        _currentlyPlayingId = null;
        _currentTrack = null;
      });
      return;
    }

    if (_musicController != null) {
      _musicController!.pause();
      _musicController!.dispose();
      _musicController = null;
    }

    _musicController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        hideControls: false,
        controlsVisibleAtStart: true,
        useHybridComposition: true,
      ),
    );

    setState(() {
      _currentlyPlayingId = videoId;
      _currentTrack = track;
    });
  }

  void _toggleVideoPlayback(String videoId) {
    if (!_videoControllers.containsKey(videoId)) {
      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          controlsVisibleAtStart: true,
          hideControls: false,
          enableCaption: false,
          useHybridComposition: true,
        ),
      );
      
      _videoControllers[videoId] = controller;
      _videoPlayingStates[videoId] = true;

      controller.addListener(() {
        if (!controller.value.isPlaying && 
            controller.value.playerState == PlayerState.ended) {
          if (mounted) {
            setState(() {
              _videoPlayingStates[videoId] = false;
            });
          }
        }
      });
    } else {
      final controller = _videoControllers[videoId]!;
      final isPlaying = _videoPlayingStates[videoId] ?? false;
      
      if (isPlaying) {
        controller.pause();
        _videoPlayingStates[videoId] = false;
      } else {
        for (final otherId in _videoControllers.keys) {
          if (otherId != videoId && (_videoPlayingStates[otherId] ?? false)) {
            _videoControllers[otherId]?.pause();
            _videoPlayingStates[otherId] = false;
          }
        }
        
        controller.play();
        _videoPlayingStates[videoId] = true;
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Color _getThemeColor() {
    final baseMoodColor = _getMoodColor(widget.mood);
    return _themeManager.getThemeColor(baseMoodColor);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final Gradient? themeGradient = isGradientMagic 
        ? _themeManager.getThemeGradient(_getMoodColor(widget.mood))
        : null;

    return Scaffold(
      backgroundColor: isGradientMagic
          ? null
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Center(
          child: Text(
            'MoodMatch: ${widget.mood.toUpperCase()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: textColor,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: textColor,
              indicatorWeight: 3,
              labelColor: textColor,
              unselectedLabelColor: textColor.withOpacity(0.7),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.music_note, size: 20), text: 'Music'),
                Tab(icon: Icon(Icons.video_library, size: 20), text: 'Videos'),
                Tab(icon: Icon(Icons.forum, size: 20), text: 'Community'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: isGradientMagic
            ? BoxDecoration(gradient: themeGradient)
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.05),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: themeColor))
            : TabBarView(
                controller: _tabController,
                children: [
                  buildMusicTab(),
                  buildVideoTab(),
                  buildFeedTab(),
                ],
              ),
      ),
    );
  }

  Widget buildMusicTab() {
    if (youtubeMusic.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No music found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your mood or check your connection',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final themeColor = _getThemeColor();
    final textColor = _themeManager.getContrastingTextColor(themeColor);
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16).copyWith(bottom: 180),
          itemCount: youtubeMusic.length,
          itemBuilder: (context, index) {
            final track = youtubeMusic[index];
            final isPlaying = _currentlyPlayingId == track['videoId'];
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isGradientMagic
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isGradientMagic
                    ? Border.all(color: Colors.white.withOpacity(0.3))
                    : null,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(track['thumbnail']?.toString() ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isPlaying
                      ? Container(
                          color: themeColor.withOpacity(0.7),
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  track['title']?.toString() ?? 'Unknown Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isGradientMagic
                        ? Colors.grey.shade800
                        : Colors.grey.shade800,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track['channel']?.toString() ?? 'Unknown Channel',
                      style: TextStyle(
                        fontSize: 12,
                        color: isGradientMagic
                            ? themeColor.withOpacity(0.8)
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility, 
                          size: 12, 
                          color: isGradientMagic
                              ? themeColor.withOpacity(0.7)
                              : Colors.grey.shade500
                        ),
                        const SizedBox(width: 4),
                        Text(
                          track['views']?.toString() ?? '0 views',
                          style: TextStyle(
                            fontSize: 11,
                            color: isGradientMagic
                                ? themeColor.withOpacity(0.7)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                    color: themeColor,
                    size: 32,
                  ),
                  onPressed: () => playMusic(track),
                ),
              ),
            );
          },
        ),
        
        if (_currentTrack != null && _musicController != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isGradientMagic
                    ? Colors.white.withOpacity(0.95)
                    : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isGradientMagic ? 0.1 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
                border: isGradientMagic
                    ? Border.all(color: Colors.white.withOpacity(0.4))
                    : null,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.music_note, color: textColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Now Playing',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor, size: 20),
                          onPressed: () {
                            _musicController?.pause();
                            setState(() {
                              _currentlyPlayingId = null;
                              _currentTrack = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _currentTrack!['thumbnail']?.toString() ?? '',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentTrack!['title']?.toString() ?? 'Unknown Title',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isGradientMagic
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentTrack!['channel']?.toString() ?? 'Unknown Channel',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isGradientMagic
                                          ? themeColor.withOpacity(0.8)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black,
                          ),
                          child: YoutubePlayer(
                            controller: _musicController!,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: themeColor,
                            progressColors: ProgressBarColors(
                              playedColor: themeColor,
                              handleColor: themeColor,
                              backgroundColor: Colors.grey.shade600,
                              bufferedColor: Colors.grey.shade400,
                            ),
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(isExpanded: true),
                              RemainingDuration(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildVideoTab() {
    if (youtubeVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No videos found',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your mood or check your connection',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    final themeColor = _getThemeColor();
    final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: youtubeVideos.length,
      itemBuilder: (context, index) {
        final video = youtubeVideos[index];
        final videoId = video['videoId']?.toString();
        final isPlaying = _videoPlayingStates[videoId] ?? false;
        
        return Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          decoration: BoxDecoration(
            color: isGradientMagic
                ? Colors.white.withOpacity(0.9)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            border: isGradientMagic
                ? Border.all(color: Colors.white.withOpacity(0.3))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: videoId != null ? () => _toggleVideoPlayback(videoId) : null,
                child: Container(
                  height: screenHeight * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Show YouTube player if playing, otherwise show thumbnail
                      if (videoId != null && _videoControllers.containsKey(videoId) && isPlaying)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: YoutubePlayer(
                            controller: _videoControllers[videoId]!,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: themeColor,
                            progressColors: ProgressBarColors(
                              playedColor: themeColor,
                              handleColor: themeColor,
                              backgroundColor: Colors.grey.shade600,
                              bufferedColor: Colors.grey.shade400,
                            ),
                            onEnded: (_) {
                              if (mounted) {
                                setState(() {
                                  _videoPlayingStates[videoId] = false;
                                });
                              }
                            },
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            video['thumbnail']?.toString() ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    size: 40,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      // Play/pause overlay
                      if (!isPlaying || !_videoControllers.containsKey(videoId))
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                            ),
                          ),
                        ),
                      
                      // Duration badge
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.005,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video['duration']?.toString() ?? '0:00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      
                      // Playing indicator
                      if (isPlaying)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02,
                              vertical: screenHeight * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.play_arrow, size: screenWidth * 0.03, color: Colors.white),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  'Playing',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.028,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title']?.toString() ?? 'Unknown Title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.04,
                        color: isGradientMagic
                            ? Colors.grey.shade800
                            : Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility, 
                          size: screenWidth * 0.035, 
                          color: isGradientMagic
                              ? themeColor.withOpacity(0.7)
                              : Colors.grey.shade600
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          video['views']?.toString() ?? '0 views',
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: isGradientMagic
                                ? themeColor.withOpacity(0.7)
                                : Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.account_circle,
                          size: screenWidth * 0.04,
                          color: isGradientMagic
                              ? themeColor.withOpacity(0.7)
                              : Colors.grey.shade600,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Expanded(
                          child: Text(
                            video['channel']?.toString() ?? 'Unknown Channel',
                            style: TextStyle(
                              fontSize: screenWidth * 0.033,
                              color: isGradientMagic
                                  ? themeColor.withOpacity(0.7)
                                  : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFeedTab() {
  final themeColor = _getThemeColor();
  final textColor = _themeManager.getContrastingTextColor(themeColor);
  final isGradientMagic = _themeManager.selectedPaletteIndex == 7;
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isGradientMagic
              ? Colors.white.withOpacity(0.9)
              : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isGradientMagic
                  ? Colors.white.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.06,
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=1'),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.1,
                    ),
                    child: TextField(
                      controller: _postController,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: TextStyle(
                          color: isGradientMagic
                              ? themeColor.withOpacity(0.7)
                              : Colors.grey.shade600,
                          fontSize: screenWidth * 0.038,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isGradientMagic
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.shade100,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.015),

            if (_selectedImage != null || _selectedVideo != null)
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isGradientMagic
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey.shade100,
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildPlatformAwareImage(
                                imageUrl: _selectedImage!.path,
                                isUserUpload: true,
                              ),
                            )
                          : _selectedVideo != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: screenWidth * 0.08,
                                        color: themeColor,
                                      ),
                                      SizedBox(height: screenHeight * 0.005),
                                      Text(
                                        'Video selected',
                                        style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _removeMedia,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.015),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: screenHeight * 0.01),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: isGradientMagic
                          ? Colors.white.withOpacity(0.7)
                          : themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isGradientMagic
                            ? themeColor.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image,
                            color: themeColor, size: screenWidth * 0.045),
                        SizedBox(width: screenWidth * 0.015),
                        Text(
                          'Photo',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.034,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: _pickVideo,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: isGradientMagic
                          ? Colors.white.withOpacity(0.7)
                          : themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isGradientMagic
                            ? themeColor.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam,
                            color: themeColor, size: screenWidth * 0.045),
                        SizedBox(width: screenWidth * 0.015),
                        Text(
                          'Video',
                          style: TextStyle(
                            color: themeColor,
                            fontWeight: FontWeight.w500,
                            fontSize: screenWidth * 0.034,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: addPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    minimumSize: Size(screenWidth * 0.18, screenHeight * 0.04),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, size: screenWidth * 0.04),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        'Post',
                        style: TextStyle(
                          fontSize: screenWidth * 0.034,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      Expanded(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.01),
              ...feedPosts.asMap().entries.map((entry) {
                final index = entry.key;
                final post = entry.value;
                final isLiked = post['liked'] == true;
                final isReposted = post['reposted'] == true;
                final showComments = post['showComments'] == true;
                final hasImage = post['hasImage'] == true && post['imageUrl'] != null;
                final hasVideo = post['hasVideo'] == true && post['videoUrl'] != null;
                final isUserUpload = post['isUserUpload'] == true;

                return Container(
                  margin: EdgeInsets.only(
                    bottom: screenHeight * 0.02,
                    left: screenWidth * 0.04,
                    right: screenWidth * 0.04,
                  ),
                  decoration: BoxDecoration(
                    color: isGradientMagic
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(isGradientMagic ? 0.03 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: isGradientMagic
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: screenWidth * 0.045,
                              backgroundImage:
                                  NetworkImage(post['avatar']?.toString() ?? ''),
                            ),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['author']?.toString() ?? 'Unknown User',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: screenWidth * 0.036,
                                      color: isGradientMagic
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: screenHeight * 0.002),
                                  Text(
                                    post['time']?.toString() ?? 'Unknown time',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: isGradientMagic
                                          ? themeColor.withOpacity(0.7)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: isGradientMagic
                                  ? themeColor.withOpacity(0.7)
                                  : Colors.grey.shade500,
                              size: screenWidth * 0.045,
                            ),
                          ],
                        ),
                      ),

                      if (post['text'] != null && post['text'].toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Text(
                            post['text'].toString(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              height: 1.5,
                              color: isGradientMagic
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),

                      if (hasImage)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.015),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildPlatformAwareImage(
                              imageUrl: post['imageUrl'].toString(),
                              isUserUpload: isUserUpload,
                            ),
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite,
                                        size: screenWidth * 0.04, color: Colors.red),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      (post['likes'] as int?)?.toString() ?? '0',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        color: isGradientMagic
                                            ? themeColor.withOpacity(0.8)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.comment,
                                      size: screenWidth * 0.04,
                                      color: isGradientMagic
                                          ? themeColor.withOpacity(0.7)
                                          : Colors.grey.shade600,
                                    ),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      (post['comments'] is List
                                              ? (post['comments'] as List).length
                                              : 0)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        color: isGradientMagic
                                            ? themeColor.withOpacity(0.8)
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (isUserUpload)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.003,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isGradientMagic
                                          ? Colors.white.withOpacity(0.7)
                                          : themeColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: isGradientMagic
                                          ? Border.all(
                                              color: themeColor.withOpacity(0.3))
                                          : null,
                                    ),
                                    child: Text(
                                      'Your Upload',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: themeColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                if (!isUserUpload)
                                  Text(
                                    'Mood: ${widget.mood}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: themeColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.012),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => toggleLike(index),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? Colors.red
                                                : (isGradientMagic
                                                    ? themeColor.withOpacity(0.7)
                                                    : Colors.grey.shade600),
                                            size: screenWidth * 0.045,
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          Flexible(
                                            child: Text(
                                              'Like',
                                              style: TextStyle(
                                                color: isLiked
                                                    ? Colors.red
                                                    : (isGradientMagic
                                                        ? themeColor
                                                        : Colors.grey.shade600),
                                                fontWeight: FontWeight.w500,
                                                fontSize: screenWidth * 0.034,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => toggleComments(index),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.comment,
                                            size: screenWidth * 0.045,
                                            color: isGradientMagic
                                                ? themeColor.withOpacity(0.7)
                                                : Colors.grey.shade600,
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          Flexible(
                                            child: Text(
                                              'Comment',
                                              style: TextStyle(
                                                color: isGradientMagic
                                                    ? themeColor
                                                    : Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                                fontSize: screenWidth * 0.034,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => toggleRepost(index),
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.repeat,
                                            size: screenWidth * 0.045,
                                            color: isReposted
                                                ? Colors.green
                                                : (isGradientMagic
                                                    ? themeColor.withOpacity(0.7)
                                                    : Colors.grey.shade600),
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          Flexible(
                                            child: Text(
                                              'Repost',
                                              style: TextStyle(
                                                color: isReposted
                                                    ? Colors.green
                                                    : (isGradientMagic
                                                        ? themeColor
                                                        : Colors.grey.shade600),
                                                fontWeight: FontWeight.w500,
                                                fontSize: screenWidth * 0.034,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (showComments)
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: isGradientMagic
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: screenWidth * 0.04,
                                    backgroundImage:
                                        const NetworkImage('https://i.pravatar.cc/150?img=1'),
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: screenHeight * 0.08,
                                      ),
                                      child: TextField(
                                        controller: _commentController,
                                        decoration: InputDecoration(
                                          hintText: "Write a comment...",
                                          hintStyle: TextStyle(
                                            fontSize: screenWidth * 0.034,
                                            color: isGradientMagic
                                                ? themeColor.withOpacity(0.7)
                                                : Colors.grey.shade600,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: isGradientMagic
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.04,
                                            vertical: screenHeight * 0.01,
                                          ),
                                        ),
                                        maxLines: null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  ElevatedButton(
                                    onPressed: () =>
                                        addComment(index, _commentController.text),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: themeColor,
                                      foregroundColor: textColor,
                                      shape: const CircleBorder(),
                                      padding: EdgeInsets.all(screenWidth * 0.025),
                                      minimumSize:
                                          Size(screenWidth * 0.1, screenWidth * 0.1),
                                    ),
                                    child: Icon(Icons.send, size: screenWidth * 0.04),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.015),

                              if (post['comments'] is List)
                                ...(post['comments'] as List).map<Widget>((comment) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(bottom: screenHeight * 0.015),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: screenWidth * 0.035,
                                          backgroundImage: NetworkImage(
                                              comment['avatar']?.toString() ?? ''),
                                        ),
                                        SizedBox(width: screenWidth * 0.025),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(screenWidth * 0.03),
                                            decoration: BoxDecoration(
                                              color: isGradientMagic
                                                  ? Colors.white.withOpacity(0.9)
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: isGradientMagic
                                                  ? Border.all(
                                                      color: Colors.white.withOpacity(0.3))
                                                  : null,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        comment['author']
                                                                ?.toString() ??
                                                            'Unknown User',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: screenWidth * 0.034,
                                                          color: isGradientMagic
                                                              ? Colors.grey.shade800
                                                              : Colors.grey.shade800,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.02),
                                                    Text(
                                                      comment['time']?.toString() ??
                                                          'Unknown time',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.03,
                                                        color: isGradientMagic
                                                            ? themeColor.withOpacity(0.7)
                                                            : Colors.grey.shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: screenHeight * 0.004),
                                                Text(
                                                  comment['text']?.toString() ?? '',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.034,
                                                    color: isGradientMagic
                                                        ? Colors.grey.shade800
                                                        : Colors.grey.shade800,
                                                  ),
                                                ),
                                                SizedBox(height: screenHeight * 0.004),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.favorite_border,
                                                      size: screenWidth * 0.03,
                                                      color: isGradientMagic
                                                          ? themeColor.withOpacity(0.7)
                                                          : Colors.grey.shade500,
                                                    ),
                                                    SizedBox(width: screenWidth * 0.01),
                                                    Text(
                                                      (comment['likes'] as int?)
                                                              ?.toString() ??
                                                          '0',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.032,
                                                        color: isGradientMagic
                                                            ? themeColor.withOpacity(0.7)
                                                            : Colors.grey.shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    ],
  );
}
}