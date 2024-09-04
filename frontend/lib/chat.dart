import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'file_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  void _sendMessage(String text) async {
    setState(() {
      _messages.add({'sender': 'me', 'text': text});
    });
    _controller.clear();
    _focusNode.requestFocus();

    List<String> selectedMessages = await _getRandomMessages();

    for (var message in selectedMessages) {
      int delayInSeconds = Random().nextInt(4) + 1;
      await Future.delayed(Duration(seconds: delayInSeconds));

      setState(() {
        _messages.add({'sender': 'other', 'text': message});
      });

      await Future.delayed(Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }

    _saveChatHistory();
  }

  Future<List<String>> _getRandomMessages() async {
    List<String> jihiMessages = await _fileService.loadChatContext();
    final random = Random();
    List<String> selectedMessages = [];

    int numberOfMessages = random.nextInt(5);
    for (int i = 0; i < numberOfMessages; i++) {
      if (jihiMessages.isNotEmpty) {
        String message = jihiMessages[random.nextInt(jihiMessages.length)];
        selectedMessages.add(message);
      }
    }

    return selectedMessages;
  }

  Future<void> _loadChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatData = prefs.getString('chat_history');
    if (chatData != null) {
      List<dynamic> decodedData = jsonDecode(chatData);
      setState(() {
        _messages = decodedData.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _saveChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chatData = jsonEncode(_messages);
    await prefs.setString('chat_history', chatData);
  }

  Future<void> _clearChatHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _clearChatHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['sender'] == 'me';
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Column(
                    crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            '지히',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment:
                        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe)
                            CircleAvatar(
                              backgroundImage: AssetImage('assets/profile.png'),
                              radius: 18,
                            ),
                          if (!isMe) SizedBox(width: 10),
                          Container(
                            padding: EdgeInsets.all(12),
                            constraints: BoxConstraints(
                                maxWidth:
                                MediaQuery.of(context).size.width * 0.6),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.yellow[100] : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: isMe
                                    ? Radius.circular(20)
                                    : Radius.zero,
                                bottomRight: isMe
                                    ? Radius.zero
                                    : Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              message['text']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          spreadRadius: 1,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요',
                              border: InputBorder.none,
                            ),
                            onEditingComplete: () {
                              if (_controller.text.trim().isNotEmpty) {
                                _sendMessage(_controller.text.trim());
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            if (_controller.text.trim().isNotEmpty) {
                              _sendMessage(_controller.text.trim());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
