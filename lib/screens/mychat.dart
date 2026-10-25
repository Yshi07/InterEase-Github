import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/chat_service.dart';


class MyChat extends StatefulWidget {
  const MyChat({super.key});

  @override
  State<MyChat> createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];

  @override
  void dispose() {
    print("CHAT DISPOSE");
    super.dispose();
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
    });

    _controller.clear();
    FocusScope.of(context).unfocus();

    try {
      final response = await _chatService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        messages.add({"role": "bot", "text": response});
      });
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "text": "Ошибка подключения"});
      });
    }
  }

  Future<bool> exitChat() async {
    print("EXIT CHAT");
    
    messages.clear();
    
    try {
      await _chatService.sendMessage("__logout__")
      .timeout(const Duration(seconds: 2));
    } catch (e) {
      print("Logout failed, continuing exit: $e");
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: exitChat,

      child: AppLayout(
        showBackButton: true,

        onBackPressed: () async {
          final canExit = await exitChat();

          if (canExit && mounted) {
            Navigator.pop(context);
          }
        },

        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),

          child: Column(
            children: [

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg["role"] == "user";

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 260,
                        ),
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Colors.blueAccent
                              : const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          msg["text"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Напиши сообщение...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
