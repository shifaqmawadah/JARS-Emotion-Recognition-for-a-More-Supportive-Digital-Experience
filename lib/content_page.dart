import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ContentPage extends StatefulWidget {
  final String mood;
  const ContentPage({super.key, required this.mood});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> youtubeMusic = [];
  List<Map<String, dynamic>> youtubeVideos = [];
  List<Map<String, dynamic>> feedPosts = [];
  bool isLoading = true;

  String? _currentlyPlayingId;
  Map<String, dynamic>? _currentTrack;
  final String youtubeApiKey = 'AIzaSyCF_C264uP9ZHeLGzUXyD8j_45QAw06DRo';
  final TextEditingController _postController = TextEditingController();
  YoutubePlayerController? _musicController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchAllContent();
    _loadSamplePosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    _musicController?.close();
    _tabController.dispose();
    super.dispose();
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.yellow.shade700;
      case 'sad':
        return Colors.blue.shade600;
      case 'angry':
        return Colors.red.shade600;
      case 'excited':
        return Colors.orange.shade600;
      case 'stressed':
        return Colors.green.shade600;
      case 'bored':
        return Colors.grey.shade600;
      case 'anxious':
        return Colors.teal.shade600;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> fetchAllContent() async {
    setState(() => isLoading = true);
    await Future.wait([
      fetchYouTubeMusic(widget.mood),
      fetchYouTubeVideos(widget.mood),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchYouTubeMusic(String mood) async {
  try {
    final moodQueries = {
      'happy': "happy upbeat pop songs official music video VEVO",
      'sad': "sad emotional ballads official music video VEVO",
      'angry': "angry rock metal official music video VEVO",
      'stressed': "relaxing calm soothing official music video chill",
      'anxious': "lofi chill calm official music video",
      'excited': "energetic dance pop official music video VEVO",
      'bored': "catchy trending pop official music video VEVO",
      'neutral': "soft chill mood pop official music video VEVO",
    };
    final query =
        moodQueries[mood.toLowerCase()] ?? "official music video VEVO popular songs";

    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&q=${Uri.encodeComponent(query)}'
      '&type=video'
      '&videoCategoryId=10'
      '&maxResults=15'
      '&regionCode=US'
      '&key=$youtubeApiKey',
    );

    final response = await http.get(url);

    // Debug prints
    print('🎵 Music API status code: ${response.statusCode}');
    print('🎵 Music API response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];
      youtubeMusic = items.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'];
        return {
          'title': snippet['title'],
          'thumbnail': snippet['thumbnails']['medium']['url'],
          'videoId': video['id']['videoId'],
          'channel': snippet['channelTitle'],
        };
      }).where((v) {
        final title = v['title'].toString().toLowerCase();
        return !(title.contains('reaction') ||
            title.contains('lyrics') ||
            title.contains('cover') ||
            title.contains('remix') ||
            title.contains('live') ||
            title.contains('instrumental'));
      }).toList();
    } else {
      print('⚠️ Failed to fetch music. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Music fetch error: $e');
  }
}

Future<void> fetchYouTubeVideos(String mood) async {
  try {
    final moodQueries = {
      'happy': "uplifting positive emotion vlog cinematic",
      'sad': "emotional deep thoughtful cinematic short film",
      'angry': "empowering motivation action cinematic scenes",
      'stressed': "calming relaxing peaceful scenic cinematic",
      'anxious': "mindfulness meditation calm cinematic",
      'excited': "adventure energetic uplifting cinematic",
      'bored': "interesting fun cinematic creative vlog",
      'neutral': "everyday life cinematic aesthetic vlog",
    };
    final query =
        moodQueries[mood.toLowerCase()] ?? "mood cinematic vlog film";

    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search'
      '?part=snippet'
      '&q=${Uri.encodeComponent(query)}'
      '&type=video'
      '&maxResults=15'
      '&regionCode=US'
      '&key=$youtubeApiKey',
    );

    final response = await http.get(url);

    // Debug prints
    print('📺 Video API status code: ${response.statusCode}');
    print('📺 Video API response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final items = data['items'] as List? ?? [];
      youtubeVideos = items.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'];
        return {
          'title': snippet['title'],
          'thumbnail': snippet['thumbnails']['high']['url'],
          'videoId': video['id']['videoId'],
          'channel': snippet['channelTitle'],
          'publishedAt': snippet['publishedAt'],
        };
      }).toList();
    } else {
      print('⚠️ Failed to fetch videos. Status: ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Video fetch error: $e');
  }
}


  void _loadSamplePosts() {
    final moodSamples = {
      'happy': [
        "What a beautiful day! 🌞",
        "Just finished my favorite song! 🎵",
        "Life is good 😄",
        "Enjoying the small moments 🌸",
        "Can't stop smiling today 😎",
      ],
      'sad': [
        "Feeling a bit down today 🌧️",
        "Memories hitting hard 💭",
        "Trying to find motivation... 💔",
        "Quiet night, heavy thoughts 🖤",
        "Listening to emotional tunes 🎶",
      ],
      'angry': [
        "Need to vent this out 😤",
        "Why is everything so frustrating? 🔥",
        "Trying to stay calm... 🧘‍♂️",
        "Focused and angry 💪",
        "Letting go of negativity 💥",
      ],
      'stressed': [
        "Deep breaths, deep breaths 🌿",
        "Need some calm time 🕯️",
        "Overwhelmed but coping 💆‍♂️",
        "Relaxing music helps 🧘‍♀️",
        "Just one step at a time 🐾",
      ],
      'excited': [
        "Can't wait for tonight! 🎉",
        "Feeling pumped 😎",
        "Adventure time! 🏞️",
        "High energy today! ⚡",
        "Let's gooo! 🚀",
      ],
      'bored': [
        "Nothing to do today 😐",
        "Scrolling endlessly 📱",
        "Need something fun 🎯",
        "Exploring random stuff 🌀",
        "Time to get creative ✨",
      ],
      'anxious': [
        "Heart racing a bit... 😬",
        "Trying to stay mindful 🧘",
        "Feeling uneasy 😟",
        "Breathing exercises help 🌬️",
        "Focus on the now 🌸",
      ],
      'neutral': [
        "Just another day 😌",
        "Coffee in hand ☕",
        "Observing the world 🌍",
        "Nothing special today 🤷‍♂️",
        "Chill vibes only 🛋️",
      ],
    };

    final random = Random();
    final selected = moodSamples[widget.mood.toLowerCase()] ?? ['Hello world!'];
    feedPosts = List.generate(5, (index) {
      return {
        'author': "Anonymous${random.nextInt(1000)}",
        'text': selected[random.nextInt(selected.length)],
        'likes': 0,
        'liked': false,
        'reposted': false,
      };
    });
  }

  void addPost() {
    final text = _postController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      feedPosts.insert(0, {
        'author': "You",
        'text': text,
        'likes': 0,
        'liked': false,
        'reposted': false,
      });
      _postController.clear();
    });
  }

  void toggleLike(int index) {
    setState(() {
      final post = feedPosts[index];
      if (!post['liked']) {
        post['liked'] = true;
        post['likes'] += 1;
      }
    });
  }

  void toggleRepost(int index) {
    setState(() {
      final post = feedPosts[index];
      if (!post['reposted']) {
        feedPosts.insert(0, {
          ...post,
          'text': "🔁 ${post['text']}",
          'reposted': true,
        });
        post['reposted'] = true;
      }
    });
  }

  void playMusic(Map<String, dynamic> track) {
    if (_currentlyPlayingId == track['videoId']) {
      _musicController?.pauseVideo();
      setState(() {
        _currentlyPlayingId = null;
        _currentTrack = null;
      });
    } else {
      _musicController?.close();
      _musicController = YoutubePlayerController.fromVideoId(
        videoId: track['videoId'],
        autoPlay: true,
        params: const YoutubePlayerParams(showControls: true),
      );
      setState(() {
        _currentlyPlayingId = track['videoId'];
        _currentTrack = track;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _getMoodColor(widget.mood);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recommendations'),
          backgroundColor: moodColor,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.music_note), text: 'Music'),
              Tab(icon: Icon(Icons.ondemand_video), text: 'Videos'),
              Tab(icon: Icon(Icons.forum), text: 'Feed'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                moodColor.withOpacity(0.3),
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    buildMusicTab(),
                    buildVideoTab(),
                    buildFeedTab(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildMusicTab() {
    if (youtubeMusic.isEmpty) {
      return const Center(child: Text('No music found 🎵'));
    }


    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 180),
          itemCount: youtubeMusic.length,
          itemBuilder: (context, index) {
            final track = youtubeMusic[index];
            final isPlaying = _currentlyPlayingId == track['videoId'];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(track['thumbnail'], width: 60, height: 60),
                ),
                title: Text(
                  track['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(track['channel']),
                trailing: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle_fill,
                    color: const Color(0xFF331F39),
                    size: 36,
                  ),
                  onPressed: () => playMusic(track),
                ),
              ),
            );
          },
        ),
        if (_currentTrack != null && _musicController != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              height: 180,
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _currentTrack!['thumbnail'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTrack!['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(_currentTrack!['channel'],
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.white, size: 28),
                        onPressed: () {
                          _musicController?.pauseVideo();
                          setState(() {
                            _currentlyPlayingId = null;
                            _currentTrack = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: YoutubePlayer(controller: _musicController!)),
                ],
              ),
            ),
          ),
      ],
    );
  }


  Widget buildVideoTab() {
    if (youtubeVideos.isEmpty) {
      return const Center(child: Text('No mood-matching videos 📺'));
    }


    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: youtubeVideos.length,
      itemBuilder: (context, index) {
        final video = youtubeVideos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoDetailPage(videoId: video['videoId']),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    video['thumbnail'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(video['channel'],
                        style: const TextStyle(color: Colors.grey)),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    hintText: "Share what’s on your mind right now…",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: addPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF331F39),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Post"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: feedPosts.length,
            itemBuilder: (context, index) {
              final post = feedPosts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple.shade300,
                            child: Text(post['author'][0],
                                style: const TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          Text(post['author'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(post['text'], style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite,
                                color: post['liked'] ? Colors.red : Colors.grey),
                            onPressed: () => toggleLike(index),
                          ),
                          Text('${post['likes']}'),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(Icons.repeat,
                                color: post['reposted'] ? Colors.green : Colors.grey),
                            onPressed: () => toggleRepost(index),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class VideoDetailPage extends StatelessWidget {
  final String videoId;
  const VideoDetailPage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showControls: true, mute: false),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Video Player"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(controller: controller),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Engaging Video Title Here",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.shade200,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text("Channel Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "This is a detailed description of the video. "
                    "You can add mood-related context here to make it more engaging "
                    "for the user, giving them a reason to watch and interact.",
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
