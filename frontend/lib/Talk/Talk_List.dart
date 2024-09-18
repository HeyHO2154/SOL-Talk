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
            .map((chatRoom) =>
        Map<String, String>.from(
            (chatRoom as Map).map((key, value) {
              return MapEntry(
                  key.toString(), value?.toString() ?? ''); // null 값을 빈 문자열로 처리
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
      String? updatedProfileImage = prefs.getString(
          '${friendId}_profileImagePath');
      String? updatedName = prefs.getString('${friendId}_name');

      setState(() {
        chatRoom['profileImage'] =
        (updatedProfileImage ?? chatRoom['profileImage'])!; // 최신 프로필 이미지 적용
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
      int roomIndex = chatRoomsList.indexWhere((room) =>
      room['name'] == roomName);

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = lastMessage;
        chatRoomsList[roomIndex]['lastMessageTime'] =
            DateTime.now().toIso8601String(); // 메시지 보낼 때 시간 업데이트

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
        DateTime timeA = DateTime.parse(
            a['lastMessageTime'] ?? DateTime.now().toIso8601String());
        DateTime timeB = DateTime.parse(
            b['lastMessageTime'] ?? DateTime.now().toIso8601String());
        return timeB.compareTo(timeA); // 최근 메시지가 먼저 오도록 정렬
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // 어두운 푸른 계열 배경
      appBar: AppBar(
        title: Text(
          '채팅방 목록',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 흰색 텍스트로 대비
          ),
        ),
        backgroundColor: Colors.transparent, // 투명한 AppBar
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목을 중앙에 배치
      ),
      body: _chatRooms.isEmpty
          ? Center(
        child: Text(
          'No chat rooms available.',
          style: TextStyle(
            color: Colors.white70, // 흰색 계열 텍스트로 부드러운 느낌
            fontSize: 18,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (context, index) {
          final chatRoom = _chatRooms[index];
          String? profileImagePath = chatRoom['profileImage'];

          return Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2), // 반투명한 푸른 배경
              borderRadius: BorderRadius.circular(20), // 둥근 모서리
              border: Border.all(
                color: Colors.white.withOpacity(0.3), // 반투명한 흰색 테두리
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10), // 부드러운 그림자
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath))
                    : null,
                child: profileImagePath == null
                    ? Text(
                  chatRoom['name'] != null && chatRoom['name']!.isNotEmpty
                      ? chatRoom['name']![0]
                      : '?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white, // 흰색 텍스트
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
                backgroundColor: Colors.cyanAccent.withOpacity(
                    0.3), // 반투명한 푸른색 배경
              ),
              title: Text(
                chatRoom['name']!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 흰색 텍스트
                ),
              ),
              subtitle: Text(
                chatRoom['lastMessage']!,
                style: TextStyle(
                  color: Colors.white70, // 부드러운 흰색 텍스트
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.lightBlueAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.blueGrey[800],
                        title: Text(
                          'Delete Chat Room',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Are you sure you want to delete this chat room?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.white70)),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Delete', style: TextStyle(
                                color: Colors.lightBlueAccent)),
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TalkRoomPage(
                          friendId: chatRoom['id']!,
                          friendName: chatRoom['name']!,
                          profileImagePath: chatRoom['profileImage'],
                        ),
                  ),
                );

                if (result != null) {
                  _updateLastMessage(chatRoom['id']!, result); // 마지막 메시지 업데이트
                }
              },
            ),
          );
        },
      ),
    );
  }
}