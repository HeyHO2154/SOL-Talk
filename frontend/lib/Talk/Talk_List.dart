import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Talk_Room.dart';
import 'dart:developer'; // 로그 출력을 위해 사용(디버그용)

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
    log('불러온 채팅방 데이터: $chatRoomsJson'); // 불러온 데이터 로그 출력

    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      log('파싱된 채팅방 리스트: $chatRoomsList'); // 파싱된 리스트 출력

      setState(() {
        _chatRooms = chatRoomsList
            .map((chatRoom) => Map<String, String>.from(chatRoom as Map))
            .toList();
        _sortChatRoomsByLastMessageTime(); // 최근 메시지 순으로 정렬
      });
    } else {
      log('채팅방 데이터가 없습니다.');
    }
  }

  // 채팅방을 추가하는 함수
  Future<void> _addChatRoom(String friendName, String? profileImagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    List<dynamic> chatRoomsList = chatRoomsJson != null ? json.decode(chatRoomsJson) : [];

    bool roomExists = chatRoomsList.any((room) => room['name'] == friendName);

    // 새로운 채팅방 추가 시 현재 시간을 lastMessageTime으로 설정
    if (!roomExists) {
      chatRoomsList.add({
        'name': friendName,
        'lastMessage': 'Start chatting!',
        'lastMessageTime': DateTime.now().toIso8601String(), // 방 생성 시 현재 시간 설정
        'profileImage': profileImagePath, // 프로필 이미지 경로 저장
      });

      String updatedChatRoomsJson = json.encode(chatRoomsList);
      log('저장할 채팅방 데이터: $updatedChatRoomsJson'); // 저장 전 데이터 로그 출력
      await prefs.setString('chatRooms', updatedChatRoomsJson);

      setState(() {
        _chatRooms = chatRoomsList
            .map((chatRoom) => Map<String, String>.from(chatRoom as Map))
            .toList();
        _sortChatRoomsByLastMessageTime(); // 정렬
      });
    } else {
      log('채팅방이 이미 존재합니다.');
    }
  }

  // 채팅방 삭제 함수
  void _deleteChatRoom(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatRooms.removeAt(index);
    });

    String updatedChatRoomsJson = json.encode(_chatRooms);
    log('삭제 후 남은 채팅방 데이터: $updatedChatRoomsJson'); // 삭제 후 데이터 로그 출력
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
        chatRoomsList[roomIndex]['lastMessageTime'] = DateTime.now().toIso8601String(); // 메시지 보낼 때 시간 업데이트

        String updatedChatRoomsJson = json.encode(chatRoomsList);
        log('업데이트된 채팅방 데이터: $updatedChatRoomsJson'); // 업데이트 후 데이터 로그 출력
        await prefs.setString('chatRooms', updatedChatRoomsJson);

        setState(() {
          _chatRooms = chatRoomsList
              .map((chatRoom) => Map<String, String>.from(chatRoom as Map))
              .toList();
          _sortChatRoomsByLastMessageTime();
        });
      }
    }
  }

  // 채팅방 목록을 마지막 메시지 시간 기준으로 정렬하는 함수
  void _sortChatRoomsByLastMessageTime() {
    setState(() {
      _chatRooms.sort((a, b) {
        DateTime timeA = DateTime.parse(a['lastMessageTime'] ?? DateTime.now().toIso8601String());
        DateTime timeB = DateTime.parse(b['lastMessageTime'] ?? DateTime.now().toIso8601String());
        return timeB.compareTo(timeA); // 최근 메시지가 먼저 오도록 정렬
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk List'),
      ),
      body: _chatRooms.isEmpty
          ? Center(child: Text('No chat rooms available.'))
          : ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          String? profileImagePath = chatRoom['profileImage'];

          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: profileImagePath != null
                  ? FileImage(File(profileImagePath))
                  : null,
              child: profileImagePath == null
                  ? Text(chatRoom['name']![0]) // 프로필 이미지가 없을 때 이니셜 표시
                  : null,
            ),
            title: Text(chatRoom['name']!),
            subtitle: Text(chatRoom['lastMessage']!), // 마지막 메시지를 미리보기로 표시
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
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
                            _deleteChatRoom(index);
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
