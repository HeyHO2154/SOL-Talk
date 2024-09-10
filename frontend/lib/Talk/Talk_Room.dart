import 'dart:convert';
import 'dart:io';
import 'dart:math'; // 랜덤 선택을 위해 추가
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation.dart';
import 'chat_service.dart';

class TalkRoomPage extends StatefulWidget {
  final String friendId; // friendId 추가
  final String friendName;
  final String? profileImagePath;

  TalkRoomPage({
    required this.friendId, // friendId 추가
    required this.friendName,
    this.profileImagePath,
  });

  @override
  _TalkRoomPageState createState() => _TalkRoomPageState();
}

class _TalkRoomPageState extends State<TalkRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // 메시지에 sender 추가
  late List<String> _friendMessages = []; // 친구 메시지 저장을 위한 리스트 추가
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService(); // ChatService 인스턴스 생성

  String _lastMessage = ""; // 마지막 메시지 저장 변수
  double _fontSize = 16.0; // 기본 글자 크기

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        // 내 메시지 전송
        _messages.add({
          'sender': 'me',
          'message': _messageController.text,
        });
        _lastMessage = _messageController.text; // 마지막 메시지 업데이트
        _scrollToBottom(); // 메시지 전송 후 자동 스크롤
        _messageController.clear(); // 메시지 전송 후 입력창 비우기
      });
      _saveMessages();
      _updateChatRoomLastMessageTime(); // 채팅방의 마지막 메시지 시간 업데이트

      // 상대방의 메시지 중 하나를 랜덤하게 선택하여 답변
      _respondWithRandomMessage();
    }
  }

  // 상대방의 메시지 중 하나를 랜덤하게 선택하여 답변하는 함수
  void _respondWithRandomMessage() {
    if (_friendMessages.isNotEmpty) {
      final random = Random();
      int randomIndex = random.nextInt(_friendMessages.length);

      setState(() {
        // 상대방 메시지 전송
        _messages.add({
          'sender': 'friend',
          'message': _friendMessages[randomIndex],
        });
        _scrollToBottom(); // 자동 스크롤
      });
      _saveMessages(); // 메시지 저장
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
    await prefs.setString('messages_${widget.friendId}', messagesJson); // friendId로 저장
  }

  // 마지막 메시지와 시간 업데이트
  void _updateChatRoomLastMessageTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      int roomIndex = chatRoomsList.indexWhere((room) => room['id'] == widget.friendId); // ID로 찾기

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = _lastMessage;
        chatRoomsList[roomIndex]['lastMessageTime'] = DateTime.now().toIso8601String();

        String updatedChatRoomsJson = json.encode(chatRoomsList);
        await prefs.setString('chatRooms', updatedChatRoomsJson);
      }
    }
  }

  // 메시지 로드 및 친구 메시지 추출
  void _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('messages_${widget.friendId}');

    if (messagesJson != null) {
      List<dynamic> messagesList = json.decode(messagesJson);

      setState(() {
        //_messages.clear();
        //메시지 리스트를 처리할 때, 타입에 맞게 변환해줍니다.
        _messages.addAll(messagesList.map((message) {
          if (message is String) {
            // 만약 메시지가 String 형식이라면, 기존에 저장된 형식으로 처리
            return {
              'sender': 'friend', // 기본적으로 친구의 메시지로 간주 (필요시 수정 가능)
              'message': message,
            };
          } else if (message is Map<String, dynamic>) {
            // Map 형식의 메시지는 그대로 추가
            return message;
          } else {
            // 알 수 없는 형식이면 무시
            return {
              'sender': 'unknown',
              'message': '',
            };
          }
        }).toList());

        if (_messages.isNotEmpty) {
          _lastMessage = _messages.last['message'];
        }
      });

      // 저장된 친구 메시지를 로드
      _friendMessages = await _chatService.loadExtractedMessages(widget.friendId);
      _scrollToBottom();
    }
  }

  // 채팅 데이터에서 친구의 메시지만 추출하는 함수
  void _extractFriendMessages() {
    final friendNamePattern = RegExp(r'^\[' + widget.friendName + r'\]');
    for (var message in _messages) {
      if (friendNamePattern.hasMatch(message['message'])) {
        // 친구가 보낸 메시지로 간주하고 메시지 부분만 추출
        String friendMessage = message['message'].split(']').last.trim();
        _friendMessages.add(friendMessage);
      }
    }
  }

  // 글자 크기 변경 함수
  void _changeFontSize(double newSize) {
    setState(() {
      _fontSize = newSize;
    });
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
        // 뒤로 가기 버튼을 누르면 무조건 채팅방 목록 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavigationPage(initialIndex: 1), // 채팅방 목록 탭으로 이동
          ),
        );
        return Future.value(false); // 기본 뒤로 가기 동작 방지
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.friendName}'),
          actions: [
            PopupMenuButton<double>(
              onSelected: (newSize) => _changeFontSize(newSize),
              itemBuilder: (context) => [
                PopupMenuItem(value: 14.0, child: Text('Small')),
                PopupMenuItem(value: 16.0, child: Text('Medium')),
                PopupMenuItem(value: 20.0, child: Text('Large')),
              ],
              icon: Icon(Icons.text_fields),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isMyMessage = message['sender'] == 'me';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0), // 아래쪽에 약간의 패딩 추가
                    child: ListTile(
                      title: Align(
                        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (!isMyMessage)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4.0), // 이름과 프로필 사이에 간격 추가
                                child: Text(
                                  widget.friendName, // 친구 이름
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                if (!isMyMessage && widget.profileImagePath != null)
                                  CircleAvatar(
                                    backgroundImage: FileImage(File(widget.profileImagePath!)),
                                    radius: 20,
                                  ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMyMessage ? Colors.blueAccent : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      message['message'],
                                      style: TextStyle(
                                        color: isMyMessage ? Colors.white : Colors.black,
                                        fontSize: _fontSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
