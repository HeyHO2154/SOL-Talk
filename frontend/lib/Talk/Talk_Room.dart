import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TalkRoomPage extends StatefulWidget {
  final String friendName;

  TalkRoomPage({required this.friendName, String? profileImagePath});

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();

  String _lastMessage = ""; // 마지막 메시지 저장 변수

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(_messageController.text);
        _lastMessage = _messageController.text; // 마지막 메시지 업데이트
        _scrollToBottom(); // 메시지 전송 후 자동 스크롤
        _messageController.clear(); // 메시지 전송 후 입력창 비우기
      });
      _saveMessages();
      _updateChatRoomLastMessageTime(); // 채팅방의 마지막 메시지 시간 업데이트
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String messagesJson = json.encode(_messages);
    await prefs.setString('messages_${widget.friendName}', messagesJson);
  }

  // 마지막 메시지와 시간 업데이트
  void _updateChatRoomLastMessageTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      int roomIndex = chatRoomsList.indexWhere((room) => room['name'] == widget.friendName);

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = _lastMessage;
        chatRoomsList[roomIndex]['lastMessageTime'] = DateTime.now().toIso8601String();

        String updatedChatRoomsJson = json.encode(chatRoomsList);
        await prefs.setString('chatRooms', updatedChatRoomsJson);
      }
    }
  }

  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('messages_${widget.friendName}');
    if (messagesJson != null) {
      List<dynamic> messagesList = json.decode(messagesJson);
      setState(() {
        _messages.addAll(messagesList.cast<String>());
        if (_messages.isNotEmpty) {
          _lastMessage = _messages.last; // 저장된 마지막 메시지로 설정
        }
      });
      _scrollToBottom();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _lastMessage); // 뒤로 가기 시 마지막 메시지 반환
        return Future.value(true); // true로 설정하면 뒤로가기가 진행됨
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat with ${widget.friendName}'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _messages[index],
                          style: TextStyle(color: Colors.white),
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
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
