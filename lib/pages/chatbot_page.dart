import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muktiya_new/services/gemini_service.dart';
import 'package:muktiya_new/pages/home_page.dart';
import 'package:muktiya_new/pages/explore_page.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';  // Add this import for Timer
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late final GeminiService _geminiService;
  
  bool _isListening = false;
  Process? _voiceProcess;
  Timer? _transcriptionTimer;
  int _selectedTab = 3; // Set to 3 for Chat tab
  bool _chatStarted = false; // Flag to track if chat has been started

  // Predefined prompt suggestions
  final List<String> _promptSuggestions = [
    "Manage stress naturally",
    "Breathing exercises",
    "Better sleep quality",
    "Mental clarity tips"
  ];

  static const String serverUrl = 'http://localhost:5000'; // Change this to your server IP

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
  }

  void _listenForTranscription() async {
    // Disabled transcription polling
    _transcriptionTimer?.cancel();
  }

  Future<void> _startVoiceInteraction() async {
    if (_isListening) return;

    setState(() => _isListening = true);
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/start_voice'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Voice interaction started",
            isUser: false,
          ));
        });
      }
    } catch (e) {
      print('Error connecting to server: $e');
      setState(() => _isListening = false);
    }
  }

  Future<void> _stopVoiceInteraction() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/stop_voice'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _transcriptionTimer?.cancel();
        setState(() {
          _isListening = false;
          // Remove the voice interaction message if it's the last message
          if (_messages.isNotEmpty && _messages.last.text == "Voice interaction started") {
            _messages.removeLast();
          }
        });
      }
    } catch (e) {
      print('Error stopping voice interaction: $e');
      setState(() => _isListening = false);
    }
  }

  void _beginChat() {
    setState(() {
      _chatStarted = true;
      // Add welcome message
      _messages.add(ChatMessage(
        text: "Welcome to Dr. Swatantra AI! I'm here to guide you on your journey to holistic well-being.",
        isUser: false,
      ));
    });
  }

  void _sendMessage({String? predefinedMessage}) async {
    String message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
      ));
      _isTyping = true;
    });

    String userMessage = message;
    _messageController.clear();

    try {
      final response = await _geminiService.getChatResponse(userMessage);

      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "Sorry, there was an error generating the response.",
          isUser: false,
        ));
        _isTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _transcriptionTimer?.cancel();
    _voiceProcess?.kill();
    super.dispose();
  }

  // Widget to build the predefined prompts section
  Widget _buildPromptSuggestions() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _promptSuggestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: () => _sendMessage(predefinedMessage: _promptSuggestions[index]),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B4C8B).withOpacity(0.1),
                foregroundColor: const Color(0xFF4A2B5C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: const Color(0xFF8B4C8B).withOpacity(0.3)),
                ),
              ),
              child: Text(_promptSuggestions[index], 
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget to build the predefined prompts section for the welcome page
  Widget _buildWelcomePromptSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Try asking about:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A2B5C),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2, // Adjust aspect ratio to better fit content
            physics: const NeverScrollableScrollPhysics(),
            children: _promptSuggestions.map((prompt) {
              return InkWell(
                onTap: () {
                  _beginChat();
                  // Add a slight delay to ensure welcome message shows first
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _sendMessage(predefinedMessage: prompt);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2E6F2), // Fixed color code format
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF2E6F2), // Fixed color code format
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A2B5C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget to show the begin button
  Widget _buildBeginChatSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            "Welcome to Dr. Swatantra AI",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2B5C),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your holistic wellness companion powered by AI",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF8B4C8B),
            ),
          ),
          const SizedBox(height: 40),
          _buildWelcomePromptSuggestions(),
          const Spacer(), // Push button to bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(
              onPressed: _beginChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2B5C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Begin Conversation",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B4C8B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            color: Color(0xFF8B4C8B),
            fontSize: 20,
            fontFamily: 'Serif',
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatStarted 
                ? Container(
                    color: const Color(0xFFF8F1F8),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A2B5C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "Thinking...",
                                  style: TextStyle(color: Color(0xFF4A2B5C)),
                                ),
                              ),
                            ],
                          );
                        }
                        return _messages[index];
                      },
                    ),
                  )
                : _buildBeginChatSection(),
          ),
          if (_chatStarted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F1F8),
                border: Border(
                  top: BorderSide(color: const Color(0xFF4A2B5C).withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: const Color(0xFF4A2B5C).withOpacity(0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Color(0xFF4A2B5C)),
                              decoration: InputDecoration(
                                hintText: _isListening ? 'Listening...' : 'Type your message...',
                                hintStyle: TextStyle(
                                  color: _isListening 
                                    ? Colors.red.withOpacity(0.7)
                                    : const Color(0xFF4A2B5C).withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: _isListening 
                                ? Colors.red.withOpacity(0.1) 
                                : const Color(0xFF4A2B5C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(right: 4),
                            child: Tooltip(
                              message: _isListening ? 'Stop voice input' : 'Start voice input',
                              child: IconButton(
                                icon: Icon(
                                  _isListening ? Icons.mic_off : Icons.mic,
                                  color: _isListening ? Colors.red : const Color(0xFF4A2B5C),
                                  size: 22,
                                ),
                                onPressed: _isListening ? _stopVoiceInteraction : _startVoiceInteraction,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A2B5C),
                      shape: BoxShape.circle,
                    ),
                    child: Tooltip(
                      message: 'Send message',
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 22),
                        onPressed: () => _sendMessage(),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                onTap: () {
                  setState(() => _selectedTab = 0);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ExplorePage()),
                  );
                },
              ),
              _buildTabItem(
                icon: Icons.chat_bubble_outline,
                label: 'Chat',
                isSelected: _selectedTab == 3,
                onTap: () => setState(() => _selectedTab = 3),
              ),          ],
        ),
      ),
    );
  }

  // Bottom navigation tab item
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

  // Helper to get filled icon variants
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
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    required this.text,
    required this.isUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 8,
          right: isUser ? 8 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF8B4C8B).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 20 : 4),
            topRight: Radius.circular(isUser ? 4 : 20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
          border: !isUser
              ? Border.all(color: Colors.grey.withOpacity(0.2))
              : null,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
