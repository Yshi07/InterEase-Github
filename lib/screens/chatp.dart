import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/services/forum_service.dart';

class PageChat extends StatefulWidget {
  const PageChat({super.key});

  @override
  State<PageChat> createState() => _PageChatState();
}

class _PageChatState extends State<PageChat> {
  final ForumService _forumService = ForumService();

  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  Map<String, dynamic>? _replyingTo;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final posts = await _forumService.getPosts();

      if (!mounted) return;

      setState(() {
        _messages = posts;
        _isLoading = false;
      });
    } catch (e) {
      print("Ошибка загрузки форума: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }
  
  
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "";
    }
    
    final date = DateTime.parse(dateString).toLocal();

    final now = DateTime.now();
    
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Сегодня, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
          
      return "Вчера, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _confirmDelete(String postId) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Удалить сообщение?"),
        content: const Text(
          "Это действие нельзя отменить.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Удалить"),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  try {
    await _forumService.deletePost(postId);

    await _loadMessages();
  } catch (e) {
    print("Ошибка удаления сообщения: $e");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Не удалось удалить сообщение: $e"),
      ),
    );
  }
}

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    if (text.isEmpty) {
      return;
    }
    
    try {
      await _forumService.addPost(
        text,
        replyTo: _replyingTo?["id"]?.toString(),
      );
      
      _messageController.clear();
      
      setState(() {
        
        _replyingTo = null;
      });
      
      await _loadMessages();
    } catch (e) {
      print("Ошибка отправки сообщения: $e");
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Не удалось отправить сообщение: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isAuthorized = user != null;

    return AppLayout(
      showBackButton: true,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Форум",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          "Пока нет сообщений",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMyMessage = user != null && message["user_id"] == user.id;
                          final isDeleted = message["is_deleted"] == true;
                          final canReply = !isDeleted;

                          final replyToId = message["reply_to"]?.toString();
                          
                          Map<String, dynamic>? repliedMessage;
                          if (replyToId != null) {
                            for (final item in _messages) {
                              if (item["id"].toString() == replyToId) {
                                repliedMessage = item;
                                break;
                              }
                            }
                          }

                          return Padding(
                            padding: EdgeInsets.only(
                              left: repliedMessage != null ? 30 : 0,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(230),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isDeleted)
                                  const Text(
                                    "🗑️ Сообщение удалено",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  )
                                  
                                else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      message["author_name"] ?? "Пользователь",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B3146),
                                      ),
                                    ),
                                    
                                    if (isMyMessage)
                                      IconButton(
                                        onPressed: () {
                                          _confirmDelete(message["id"].toString());
                                        },
                                        
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Color(0xFF1B3146),
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                if (repliedMessage != null)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.reply,
                                        size: 16,
                                        color: Color(0xFF1B3146),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: repliedMessage!["is_deleted"] == true
                                        ? const Text(
                                          "Сообщение удалено",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                        
                                        : Text(
                                          'Ответ на ${repliedMessage!["author_name"]}: '
                                          '"${repliedMessage!["content"]}"',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF1B3146),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                if (message["is_deleted"] == true)
                                  const Text(
                                    "🗑️ Сообщение удалено",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                  
                                else
                                Text(
                                  message["content"] ?? "",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF1B3146),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  _formatDate(message["created_at"]?.toString()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),

                                if (canReply)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _replyingTo = message;
                                      });
                                    },
                                    
                                    icon: const Icon(
                                      Icons.reply,
                                      size: 17,
                                      color: Color(0xFF1B3146),
                                    ),
                                    label: const Text(
                                      "Ответить",
                                      style: TextStyle(
                                        color: Color(0xFF1B3146),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                            ),
                          );
                        },
                      ),
          ),

          if (isAuthorized)
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingTo != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.reply,
                          color: Colors.white,
                          size: 18,
                        ),
                        
                        const SizedBox(width: 8),
                        
                        Expanded(
                          child: Text(
                            'Ответ на ${_replyingTo!["author_name"]}: '
                            '"${_replyingTo!["content"]}"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _replyingTo = null;
                            });
                          },
                          
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  
                  TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Написать сообщение...",
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha(170),
                      ),
                      filled: true,
                      fillColor: Colors.white.withAlpha(30),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      
                      contentPadding: const EdgeInsets.only(
                        left: 16,
                        right: 50,
                        top: 10,
                        bottom: 10,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "🔒 Войдите в аккаунт, чтобы оставить сообщение",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}