import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TalkRoomPage extends StatefulWidget {
  final String friendName; // 대화 상대 이름

  TalkRoomPage({required this.friendName});

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  // 메시지를 전송하는 함수
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        String lastMessage = _messageController.text; // 마지막 메시지 저장
        _messages.insert(0, lastMessage); // 메시지를 리스트의 맨 앞에 추가
        _messageController.clear(); // 메시지 전송 후 입력창 비우기
        _saveMessages(); // 로컬 저장소에 저장
        _updateLastMessage(lastMessage); // TalkList에 마지막 메시지 업데이트
      });
      _scrollToBottom(); // 메시지 전송 후 자동으로 아래로 스크롤
    }
  }

  // 자동 스크롤 함수
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 채팅 메시지 로컬 저장소에 저장
  void _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String messagesJson = json.encode(_messages);
    await prefs.setString('messages_${widget.friendName}', messagesJson);
  }

  // 채팅 메시지 로컬 저장소에서 불러오기
  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('messages_${widget.friendName}');
    if (messagesJson != null) {
      List<dynamic> messagesList = json.decode(messagesJson);
      setState(() {
        _messages.addAll(messagesList.cast<String>());
      });
      _scrollToBottom(); // 로드된 메시지가 있다면 스크롤을 최신 메시지로 이동
    }
  }

  // 마지막 메시지를 TalkListPage에서 미리보기를 위해 SharedPreferences에 업데이트
  void _updateLastMessage(String lastMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      int roomIndex = chatRoomsList.indexWhere((room) => room['name'] == widget.friendName);

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = lastMessage;
        String updatedChatRoomsJson = json.encode(chatRoomsList);
        await prefs.setString('chatRooms', updatedChatRoomsJson);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.friendName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // 스크롤 컨트롤러 연결
              itemCount: _messages.length,
              reverse: true, // 아래에서 위로 쌓이도록 설정
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
    );
  }
}