import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      setState(() {
        _chatRooms = chatRoomsList
            .map((chatRoom) => Map<String, String>.from(
            (chatRoom as Map).map((key, value) {
              return MapEntry(key.toString(), value?.toString() ?? ''); // null 값을 빈 문자열로 처리
            })))
            .toList();
        _sortChatRoomsByLastMessageTime(); // 불러온 후 정렬
      });
      _updateChatRoomProfileImages(); // 프로필 이미지 경로 업데이트
    }
  }


  // 프로필 이미지를 최신으로 반영하는 함수
  void _updateChatRoomProfileImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var chatRoom in _chatRooms) {
      // 친구 ID 기반으로 최신 프로필 이미지와 이름을 가져옴
      String? friendId = chatRoom['id'];
      String? updatedProfileImage = prefs.getString('${friendId}_profileImagePath');
      String? updatedName = prefs.getString('${friendId}_name');

      setState(() {
        chatRoom['profileImage'] = (updatedProfileImage ?? chatRoom['profileImage'])!; // 최신 프로필 이미지 적용
        chatRoom['name'] = (updatedName ?? chatRoom['name'])!; // 최신 이름 적용
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
              child: profileImagePath == null || profileImagePath.isEmpty
                  ? Text(
                chatRoom['name'] != null && chatRoom['name']!.isNotEmpty
                    ? chatRoom['name']![0] // 이름 첫 글자 표시
                    : '?', // 이름이 없을 경우 기본값 설정 (예: '?')
                style: TextStyle(fontSize: 24), // 텍스트 크기 조정
              )
                  : null, // 프로필 이미지가 있으면 이미지를 표시하고, 없으면 첫 글자 표시
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
                  builder: (context) => TalkRoomPage(friendId: chatRoom['id']!, friendName: chatRoom['name']!, profileImagePath: chatRoom['profileImage']),
                ),
              );

              if (result != null) {
                _updateLastMessage(chatRoom['id']!, result); // 마지막 메시지 업데이트
              }
            },
          );
        },
      ),
    );
  }
}