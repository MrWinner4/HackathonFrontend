import 'package:budgetbuddy/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../colorscheme.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio _dio = Dio();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Add user message
    await chatProvider.addMessage(text, true);
    _controller.clear();
    
    // Set loading state
    chatProvider.setLoading(true);
    
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
    
    // Fetch AI response
    final response = await _fetchChatbotResponse(text);
    
    // Add AI response
    await chatProvider.addMessage(response, false);
    chatProvider.setLoading(false);
    
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<String> _fetchChatbotResponse(String prompt) async {
    try {
      final response = await _dio.post(
        backendBaseUrl + '/chatbot/ask',
        data: {'message': prompt},
      );
      // The backend returns: { "response": "..." }
      return response.data['response'] ?? "No response from server.";
    } catch (e) {
      return "Error: $e";
    }
  }

  void _clearChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.clearMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColorScheme.accent.withOpacity(0.15),
                    child: const Icon(Icons.smart_toy_rounded,
                        size: 32, color: AppColorScheme.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Finance Chatbot',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ask me anything about money! 💬',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColorScheme.secondaryVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Clear chat button
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, child) {
                      return chatProvider.messages.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Clear Chat History'),
                                    content: const Text('Are you sure you want to clear all messages? This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _clearChat();
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Clear'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.history,
                                color: AppColorScheme.secondaryVariant,
                                size: 24,
                              ),
                              tooltip: 'Clear chat history',
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            // Chat area
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.95),
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, i) {
                        final msg = chatProvider.messages[i];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 18),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? AppColorScheme.accent
                                  : AppColorScheme.primaryVariant.withOpacity(0.7),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                                bottomRight: Radius.circular(msg.isUser ? 4 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: msg.isUser
                                ? Text(
                                    msg.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : MarkdownBody(
                                    data: msg.text,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                        color: AppColorScheme.secondary,
                                        fontSize: 16,
                                      ),
                                      strong: const TextStyle(
                                        color: AppColorScheme.secondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      em: const TextStyle(
                                        color: AppColorScheme.secondary,
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      code: TextStyle(
                                        color: AppColorScheme.accent,
                                        fontSize: 16,
                                        backgroundColor: AppColorScheme.accent.withOpacity(0.1),
                                      ),
                                      codeblockDecoration: BoxDecoration(
                                        color: AppColorScheme.primaryVariant,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Input area
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Send button
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColorScheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColorScheme.accent.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          return IconButton(
                            icon: chatProvider.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send_rounded, color: Colors.white),
                            onPressed: chatProvider.isLoading ? null : _sendMessage,
                            splashRadius: 24,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Text input
                    Expanded(
                      child: Consumer<ChatProvider>(
                        builder: (context, chatProvider, child) {
                          return TextField(
                            controller: _controller,
                            onSubmitted: (_) => _sendMessage(),
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type a message...'),
                            enabled: !chatProvider.isLoading,
                          );
                        },
                      ),
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
}
