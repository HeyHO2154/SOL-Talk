import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Talk_Room.dart';

class TalkListPage extends StatefulWidget {
  @override
  _TalkListPageState createState() => _TalkListPageState();
}

class _TalkListPageState extends State<TalkListPage> {
  List<Map<String, String>> _chatRooms = [];

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  // 채팅방 목록을 로컬 저장소에서 불러오는 함수
  void _loadChatRooms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      setState(() {
        _chatRooms = chatRoomsList
            .map((chatRoom) => Map<String, String>.from(chatRoom as Map))
            .toList();
      });
    }
  }

  // 채팅방 삭제 함수
  void _deleteChatRoom(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatRooms.removeAt(index);
    });
    String updatedChatRoomsJson = json.encode(_chatRooms);
    await prefs.setString('chatRooms', updatedChatRoomsJson);
  }

  // 마지막 메시지 업데이트 함수
  void _updateLastMessage(String roomName, String lastMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      int roomIndex = chatRoomsList.indexWhere((room) => room['name'] == roomName);

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = lastMessage;
        String updatedChatRoomsJson = json.encode(chatRoomsList);
        await prefs.setString('chatRooms', updatedChatRoomsJson);

        setState(() {
          _chatRooms[roomIndex]['lastMessage'] = lastMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk List'),
      ),
      body: ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Text(chatRoom['name']![0]),
            ),
            title: Text(chatRoom['name']!),
            subtitle: Text(chatRoom['lastMessage']!), // 마지막 메시지를 미리보기로 표시
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // 채팅방 삭제 확인 대화 상자 표시
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Chat Room'),
                      content: Text('Are you sure you want to delete this chat room?'),
                      actions: [
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () {
                            _deleteChatRoom(index); // 채팅방 삭제
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            onTap: () async {
              // TalkRoomPage에서 메시지를 보내고 마지막 메시지를 업데이트
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkRoomPage(friendName: chatRoom['name']!),
                ),
              );

              if (result != null) {
                _updateLastMessage(chatRoom['name']!, result); // 마지막 메시지 업데이트
              }
            },
          );
        },
      ),
    );
  }
}
