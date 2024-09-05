import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Talk/Talk_List.dart';
import '../Talk/Talk_Room.dart';
import '../UserProfile/UserProfile.dart'; // UserProfilePage import
import 'Friends_Add.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, String>> _friends = [];
  String _name = 'John Doe';
  String _jobTitle = 'Flutter Developer';

  @override
  void initState() {
    super.initState();
    _loadFriends();  // 친구 목록 불러오기
    _loadProfile();  // 본인 프로필 정보 불러오기
  }

  // 친구 목록을 로컬 저장소에서 불러오는 함수
  void _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? friendsJson = prefs.getString('friendsList');
    if (friendsJson != null) {
      List<dynamic> friendsList = json.decode(friendsJson);
      setState(() {
        _friends = friendsList
            .map((friend) => Map<String, String>.from(friend as Map))
            .toList();
      });
    }
  }

  // 본인 프로필을 로컬 저장소에서 불러오는 함수
  void _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
    });
  }

  // 친구 목록을 로컬 저장소에 저장하는 함수
  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String friendsJson = json.encode(_friends);
    await prefs.setString('friendsList', friendsJson);
  }

  // 새로운 친구를 추가하고 저장하는 함수
  void _addFriend(Map<String, String> friend) {
    setState(() {
      _friends.add(friend);
    });
    _saveFriends();  // 추가 후 저장
  }

  // 친구를 삭제하고 관련 채팅방도 삭제하는 함수
  void _deleteFriendAndChatRoom(String friendName, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 친구 삭제
    setState(() {
      _friends.removeAt(index);
    });
    _saveFriends();

    // 관련 채팅방 삭제
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      chatRoomsList.removeWhere((room) => room['name'] == friendName);
      String updatedChatRoomsJson = json.encode(chatRoomsList);
      await prefs.setString('chatRooms', updatedChatRoomsJson);
    }
  }

  // 채팅방 추가 함수 (TalkListPage에 채팅방 저장)
  void _addChatRoom(String friendName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    List<dynamic> chatRoomsList = chatRoomsJson != null ? json.decode(chatRoomsJson) : [];
    bool roomExists = chatRoomsList.any((room) => room['name'] == friendName);

    // 채팅방이 없을 경우 추가
    if (!roomExists) {
      chatRoomsList.add({'name': friendName, 'lastMessage': 'Start chatting!'});
      String updatedChatRoomsJson = json.encode(chatRoomsList);
      await prefs.setString('chatRooms', updatedChatRoomsJson);
    }
  }

  // 친구 클릭 시 TalkRoomPage로 이동 및 채팅방 생성
  void _openChatRoom(BuildContext context, String friendName) async {
    // 채팅방 목록에 추가
    _addChatRoom(friendName);

    // 채팅방 페이지로 이동
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalkRoomPage(friendName: friendName),
      ),
    );

    // TalkListPage로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalkListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // 친구 추가 페이지로 이동 후, 추가된 친구 정보 받기
              final newFriend = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsAddPage(),
                ),
              );
              if (newFriend != null) {
                _addFriend(newFriend);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 본인 프로필
          InkWell(
            onTap: () {
              // 본인 프로필 클릭 시 UserProfilePage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              ).then((_) => _loadProfile()); // 프로필 수정 후 다시 로드
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(_name[0]),  // 본인 이름의 이니셜 표시
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name, // 본인 이름
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _jobTitle, // 본인 직업 또는 상태 메시지
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          // 친구 목록
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    child: Text(friend['name']![0]),  // 친구 이름의 첫 글자로 기본 프로필 표시
                  ),
                  title: Text(friend['name']!),
                  subtitle: Text(friend['chatData']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chat),
                        onPressed: () {
                          // 친구 클릭 시 TalkRoomPage로 이동
                          _openChatRoom(context, friend['name']!);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // 친구 삭제 확인 대화 상자 표시
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Friend'),
                                content: Text('Are you sure you want to delete this friend and related chat room?'),
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
                                      _deleteFriendAndChatRoom(friend['name']!, index); // 친구 및 채팅방 삭제
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
