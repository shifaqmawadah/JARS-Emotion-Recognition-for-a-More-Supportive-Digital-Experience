import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'theme_manager.dart';

class AIChatPage extends StatefulWidget {
  final String userEmail;
  final String? currentMood;
  final Color baseMoodColor;
  final ThemeManager themeManager;

  const AIChatPage({
    super.key,
    required this.userEmail,
    this.currentMood,
    required this.baseMoodColor,
    required this.themeManager,
  });

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  
  static const String _apiKey = 'MyApiKey'; 
  late final GenerativeModel _model;
  late final ChatSession _chat;
 
  late Color _themeColor;
  late Color _textColor;
  late bool _isGradientMagic;
  late Gradient? _themeGradient;
  
  bool get _hasValidApiKey => _apiKey.isNotEmpty && 
      _apiKey.startsWith('AIza') && 
      _apiKey.length > 20;

  @override
  void initState() {
    super.initState();
 
    _updateTheme();
  
    widget.themeManager.addListener(_updateTheme);
   
    print(' [DEBUG] API Key check:');
    print('   - Has key: ${_apiKey.isNotEmpty}');
    print('   - Starts with AIza: ${_apiKey.startsWith("AIza")}');
    print('   - Key length: ${_apiKey.length}');
    print('   - Key preview: ${_apiKey.isNotEmpty ? _apiKey.substring(0, min(_apiKey.length, 10)) + "..." : "EMPTY"}');
    
    if (!_hasValidApiKey) {
      print(' [DEBUG] Invalid API key detected!');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyError();
      });
      return;
    }
    
    print(' [DEBUG] API key appears valid. Initializing Gemini...');
    
    try {
      print(' [DEBUG] Creating GenerativeModel...');
      _model = GenerativeModel(
        model: 'gemini-2.5-flash-lite',
        apiKey: _apiKey,
      );
      print(' [DEBUG] GenerativeModel created successfully');
      
      print(' [DEBUG] Starting chat session...');
      _chat = _model.startChat(history: [
        Content.text('''You are MindMate, an empathetic AI companion for mental wellness and emotional support. 
            Your role is to:
           1. Listen actively and validate feelings without judgment
           2. Help users process their emotions
           3. Provide gentle guidance and coping strategies
           4. Ask thoughtful questions to encourage self-reflection
           5. Maintain a warm, compassionate tone

          The user is using an emotion diary app called JARS. Their current mood is: ${widget.currentMood ?? 'not specified'}

           Start by introducing yourself and asking how you can help them today. Keep responses concise but meaningful.'''),
        Content.model([TextPart('Hello! I\'m MindMate, your AI companion for emotional wellness. I see you\'re feeling ${widget.currentMood ?? 'a certain way'} today. How can I support you right now? Whether you want to vent, reflect, or explore coping strategies, I\'m here to listen without judgment.')])
      ]);
      print(' [DEBUG] Chat session started successfully');
      print(' [DEBUG] Current mood: ${widget.currentMood ?? "not specified"}');
      
      _addMessage(
        message: 'Hello! I\'m MindMate, your AI companion for emotional wellness. I see you\'re feeling ${widget.currentMood ?? 'a certain way'} today. How can I support you right now? Whether you want to vent, reflect, or explore coping strategies, I\'m here to listen without judgment.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      print(' [DEBUG] Initialization complete');
      
    } catch (e) {
      print(' [DEBUG] Error during Gemini initialization: $e');
      print('   - Error type: ${e.runtimeType}');
      print('   - Stack trace: ${e.toString()}');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addMessage(
          message: 'Failed to initialize AI. Error: ${e.toString().split('\n').first}',
          isUser: false,
          timestamp: DateTime.now(),
        );
      });
    }
  }
  
  void _updateTheme() {
    if (mounted) {
      setState(() {
        _themeColor = widget.themeManager.getThemeColor(widget.baseMoodColor);
        _textColor = widget.themeManager.getContrastingTextColor(_themeColor);
        _isGradientMagic = widget.themeManager.selectedPaletteIndex == 7;
        _themeGradient = _isGradientMagic 
            ? widget.themeManager.getThemeGradient(widget.baseMoodColor)
            : null;
      });
    }
  }
  
  @override
  void dispose() {
    widget.themeManager.removeListener(_updateTheme);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  int min(int a, int b) => a < b ? a : b;

  void _showApiKeyError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('API Key Issue', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: _themeColor, size: 48),
            const SizedBox(height: 16),
            Text(
              'Please check your Gemini API key:\n\n'
              '1. Make sure it starts with "AIzaSy..."\n'
              '2. Ensure it\'s not empty\n'
              '3. Check if the key has proper permissions\n\n'
              'Get a new key from: https://makersuite.google.com/app/apikey',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _addMessage({
    required String message,
    required bool isUser,
    required DateTime timestamp,
  }) {
    print(' [DEBUG] Adding message:');
    print('   - User: $isUser');
    print('   - Length: ${message.length} chars');
    print('   - Preview: ${message.substring(0, min(message.length, 50))}${message.length > 50 ? "..." : ""}');
    
    setState(() {
      _messages.add(ChatMessage(
        id: const Uuid().v4(),
        message: message,
        isUser: isUser,
        timestamp: timestamp,
      ));
    });
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    print(' [DEBUG] Sending message: "$message"');
    print('   - Loading state: $_isLoading');
    print('   - Valid API key: $_hasValidApiKey');

    _addMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messageController.clear();
    setState(() {
      _isLoading = true;
      _isTyping = true;
    });

    if (!_hasValidApiKey) {
      print(' [DEBUG] Cannot send: Invalid API key');
      setState(() {
        _isTyping = false;
        _isLoading = false;
      });
      _addMessage(
        message: 'Cannot send message: API key is invalid or missing.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      return;
    }

    try {
      print(' [DEBUG] Sending to Gemini API...');
      final startTime = DateTime.now();
   
      final response = await _chat.sendMessage(Content.text(message));
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(' [DEBUG] Gemini response received:');
      print('   - Response time: ${duration.inMilliseconds}ms');
      print('   - Has text: ${response.text != null}');
      print('   - Response length: ${response.text?.length ?? 0} chars');
      
      final aiResponse = response.text ?? 'I understand. How does that make you feel?';
    
      print(' [DEBUG] Simulating typing delay...');
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _isTyping = false;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
  
      _addMessage(
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      print(' [DEBUG] Message sent and processed successfully');
      
    } catch (e) {
      print(' [DEBUG] Error sending message:');
      print('   - Error: $e');
      print('   - Error type: ${e.runtimeType}');
      print('   - Stack trace: ${e.toString()}');
   
      if (e.toString().contains('quota')) {
        print('   - Detected: Quota exceeded error');
      } else if (e.toString().contains('permission') || e.toString().contains('API key')) {
        print('   - Detected: API key/permission error');
      } else if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        print('   - Detected: Network error');
      } else if (e.toString().contains('platform')) {
        print('   - Detected: Platform restriction error');
      }

      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _isTyping = false;
      });
      await Future.delayed(const Duration(milliseconds: 500));
     
      String errorMessage;
      if (e.toString().contains('quota')) {
        errorMessage = 'I apologize, I\'ve reached my daily limit. Please try again tomorrow or check your Gemini API quota.';
      } else if (e.toString().contains('permission') || e.toString().contains('API key')) {
        errorMessage = 'There seems to be an issue with the API key. Please check your Gemini API key permissions.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'I\'m having trouble connecting to the network. Please check your internet connection.';
      } else {
        errorMessage = 'I apologize, I\'m having trouble connecting right now. Error: ${e.toString().split('\n').first}';
      }
      
      _addMessage(
        message: errorMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      print('🔄 [DEBUG] Loading state reset: $_isLoading');
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final backgroundColor = message.isUser
        ? _themeColor
        : _isGradientMagic
            ? Colors.white.withOpacity(0.9)
            : Colors.white;
    
    final textColor = message.isUser
        ? _textColor
        : _isGradientMagic
            ? Colors.grey.shade800
            : Colors.grey.shade800;
    
    final timeColor = _isGradientMagic
        ? Colors.white.withOpacity(0.7)
        : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isUser) const Spacer(),
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Column(
              crossAxisAlignment: message.isUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: message.isUser
                        ? [
                            BoxShadow(
                              color: _themeColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                    border: _isGradientMagic && !message.isUser
                        ? Border.all(color: Colors.white.withOpacity(0.3))
                        : null,
                  ),
                  child: Text(
                    message.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    right: message.isUser ? 0 : 8,
                    left: message.isUser ? 8 : 0,
                  ),
                  child: Text(
                    DateFormat('hh:mm a').format(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: timeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (!message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: _isGradientMagic
                    ? LinearGradient(
                        colors: [
                          _themeColor,
                          _themeColor.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          _themeColor,
                          Color.lerp(_themeColor, Colors.black, 0.3)!,
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _themeColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmotionChip(String text) {
    return GestureDetector(
      onTap: () {
        print('🎯 [DEBUG] Quick emotion selected: "$text"');
        _messageController.text = text;
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isGradientMagic
              ? Colors.white.withOpacity(0.9)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isGradientMagic
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _isGradientMagic
                ? Colors.grey.shade800
                : Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(' [DEBUG] Building AIChatPage widget');
    print('   - Message count: ${_messages.length}');
    print('   - Is loading: $_isLoading');
    print('   - Is typing: $_isTyping');
    print('   - Theme color: $_themeColor');
    print('   - Is Gradient Magic: $_isGradientMagic');
    
    return Scaffold(
      backgroundColor: _isGradientMagic ? null : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _themeColor,
        elevation: 0,
        title: Text(
          "EmoSupport AI",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: _textColor,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        iconTheme: IconThemeData(color: _textColor),
        actions: [
          IconButton(
            onPressed: () {
              print(' [DEBUG] Clear conversation requested');
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Clear Conversation',
                    style: GoogleFonts.poppins(),
                  ),
                  content: Text(
                    'Are you sure you want to clear all messages?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        print('   - User canceled clear');
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print('   - User confirmed clear');
                        print('   - Clearing ${_messages.length} messages');
                        setState(() {
                          _messages.clear();
                          // Add new welcome message
                          _addMessage(
                            message: 'Hello! I\'m here to give you support and ready to listen. How are you feeling today?',
                            isUser: false,
                            timestamp: DateTime.now(),
                          );
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.delete_outline_rounded, color: _textColor),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: _isGradientMagic
              ? BoxDecoration(
                  gradient: _themeGradient,
                )
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Mood indicator
                  Container(
                    margin: EdgeInsets.all(constraints.maxWidth > 600 ? 20 : 16),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isGradientMagic
                          ? Colors.white.withOpacity(0.9)
                          : _themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isGradientMagic
                            ? Colors.white.withOpacity(0.3)
                            : _themeColor.withOpacity(0.3)
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _themeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.currentMood != null
                                ? "Current Mood: ${widget.currentMood}"
                                : "AI Companion: Always here for you",
                            style: GoogleFonts.poppins(
                              fontSize: constraints.maxWidth > 600 ? 16 : 14,
                              fontWeight: FontWeight.w500,
                              color: _themeColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Expanded(
                    child: _messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: _isGradientMagic
                                          ? LinearGradient(
                                              colors: [
                                                _themeColor,
                                                _themeColor.withOpacity(0.8),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                _themeColor,
                                                Color.lerp(_themeColor, Colors.black, 0.3)!,
                                              ],
                                            ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: _themeColor.withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.psychology_alt_rounded,
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'EmoSupport AI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: _isGradientMagic
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your compassionate AI companion',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: _isGradientMagic
                                          ? Colors.white.withOpacity(0.8)
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 40),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _isGradientMagic
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: _isGradientMagic
                                          ? Border.all(color: Colors.white.withOpacity(0.3))
                                          : null,
                                    ),
                                    child: Text(
                                      'I\'m here to listen, support, and help you navigate your emotions. Feel free to share anything on your mind.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _isGradientMagic
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade800,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(top: 16, bottom: 100),
                            itemCount: _messages.length + (_isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _messages.length) {
                                return _buildMessageBubble(_messages[index]);
                              } else {
                                print('[DEBUG] Showing typing indicator');
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          gradient: _isGradientMagic
                                              ? LinearGradient(
                                                  colors: [
                                                    _themeColor,
                                                    _themeColor.withOpacity(0.8),
                                                  ],
                                                )
                                              : LinearGradient(
                                                  colors: [
                                                    _themeColor,
                                                    Color.lerp(_themeColor, Colors.black, 0.3)!,
                                                  ],
                                                ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'M',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _isGradientMagic
                                              ? Colors.white.withOpacity(0.9)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.05),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                          border: _isGradientMagic
                                              ? Border.all(color: Colors.white.withOpacity(0.3))
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _isGradientMagic
                                                    ? _themeColor
                                                    : Colors.grey.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _isGradientMagic
                                                    ? _themeColor.withOpacity(0.7)
                                                    : Colors.grey.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: _isGradientMagic
                                                    ? _themeColor.withOpacity(0.4)
                                                    : Colors.grey.shade600,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isGradientMagic
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white,
                      border: Border(top: BorderSide(
                        color: _isGradientMagic
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.shade200,
                      )),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _isGradientMagic
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('[DEBUG] Quick emotions button pressed');
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: _isGradientMagic
                                    ? Colors.white.withOpacity(0.95)
                                    : Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                builder: (context) => Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Quick Emotions',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _isGradientMagic
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          _buildEmotionChip('😢 I\'m feeling sad'),
                                          _buildEmotionChip('😠 I\'m feeling angry'),
                                          _buildEmotionChip('😰 I\'m feeling anxious'),
                                          _buildEmotionChip('😊 I\'m feeling happy'),
                                          _buildEmotionChip('😴 I\'m feeling tired'),
                                          _buildEmotionChip('🤯 I\'m feeling overwhelmed'),
                                          _buildEmotionChip('🙏 I\'m feeling grateful'),
                                          _buildEmotionChip('😌 I need to vent'),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _themeColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                          'Close',
                                          style: GoogleFonts.poppins(
                                            color: _textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: _isGradientMagic
                                  ? Colors.white
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: _isGradientMagic
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    style: GoogleFonts.poppins(
                                      color: _isGradientMagic
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Type your message...',
                                      hintStyle: GoogleFonts.poppins(
                                        color: _isGradientMagic
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.black54,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                    onSubmitted: (_) {
                                      print('↩️ [DEBUG] Enter key pressed, sending message');
                                      _sendMessage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            gradient: _isGradientMagic
                                ? LinearGradient(
                                    colors: [
                                      _themeColor,
                                      _themeColor.withOpacity(0.8),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      _themeColor,
                                      Color.lerp(_themeColor, Colors.black, 0.3)!,
                                    ],
                                  ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _themeColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('📤 [DEBUG] Send button pressed');
                              _sendMessage();
                            },
                            icon: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.send_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}