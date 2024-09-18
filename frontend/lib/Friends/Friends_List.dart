import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // 파일 관련 작업을 위해 추가

import 'package:uuid/uuid.dart';
import '../Talk/Talk_Room.dart';
import '../UserProfile/UserProfile.dart'; // UserProfilePage import
import '../navigation.dart';
import 'Friends_Add.dart';
import 'Friends_Edit.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, String?>> _friends = []; // String?으로 변경하여 null 허용
  final Uuid uuid = Uuid(); // UUID 생성기
  String _name = '사용자';
  String _jobTitle = '이곳을 클릭해서 입력하세요!';
  String? _profileImagePath; // 프로필 사진 경로

  @override
  void initState() {
    super.initState();
    _loadFriends(); // 친구 목록 불러오기
    _loadProfile(); // 본인 프로필 정보 불러오기
  }

  // 친구 목록을 로컬 저장소에서 불러오는 함수
  void _loadFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? friendsJson = prefs.getString('friendsList');
    if (friendsJson != null) {
      List<dynamic> friendsList = json.decode(friendsJson);
      setState(() {
        _friends = friendsList
            .map((friend) =>
        Map<String, String?>.from(friend as Map)) // String? 타입으로 변환
            .toList();
      });
    }
  }

  // 본인 프로필을 로컬 저장소에서 불러오는 함수
  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
      _profileImagePath =
          prefs.getString('userProfileImagePath'); // 프로필 이미지 경로 불러오기
    });
  }

  // 프로필 수정 후 프로필 동기화 함수 및 채팅방 정보 갱신
  Future<void> _updateProfileFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 프로필 정보 동기화
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
      _profileImagePath =
          prefs.getString('userProfileImagePath'); // 프로필 이미지 경로 불러오기
    });

    // 프로필에 해당하는 채팅방의 ID 가져오기
    String? myId = prefs.getString('myId'); // 고유한 ID 불러오기

    // 채팅방 리스트에서 내 프로필을 사용하는 방들 업데이트
    if (myId != null) {
      await _updateChatRoomProfile(
          myId, _name, _profileImagePath); // ID, 이름, 프로필 이미지 전달
    }
  }

  // 채팅방 리스트에 내 프로필 정보를 반영하는 함수
  Future<void> _updateChatRoomProfile(String friendId, String updatedName,
      String? updatedProfileImage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');

    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);

      // 채팅방 리스트에서 해당 친구의 프로필 정보를 사용하는 채팅방을 모두 업데이트
      for (var room in chatRoomsList) {
        if (room['id'] == friendId) { // ID를 기준으로 업데이트
          room['name'] = updatedName; // 이름 업데이트

          // 프로필 이미지가 null인 경우 기본값으로 빈 문자열을 설정
          room['profileImage'] = updatedProfileImage ?? '';
        }
      }

      // 업데이트된 채팅방 리스트 저장
      String updatedChatRoomsJson = json.encode(chatRoomsList);
      await prefs.setString('chatRooms', updatedChatRoomsJson); // 비동기 작업
    }
  }


  // 친구 목록을 로컬 저장소에 저장하는 함수
  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String friendsJson = json.encode(_friends);
    await prefs.setString('friendsList', friendsJson);
  }

  // 새로운 친구를 추가하고 저장하는 함수
  void _addFriend(Map<String, String?> friend) {
    setState(() {
      _friends.add(friend); // 친구 목록에 새로운 친구 추가
    });
    _saveFriends(); // 추가된 친구 목록 저장
  }

  // 친구를 삭제하고 관련 채팅방, 메시지 데이터를 삭제하는 함수
  void _deleteFriendAndChatRoom(String friendId, int index) async {
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
      chatRoomsList.removeWhere((room) => room['id'] == friendId); // ID로 채팅방 삭제
      String updatedChatRoomsJson = json.encode(chatRoomsList);
      await prefs.setString('chatRooms', updatedChatRoomsJson);
    }

    // 관련 메시지 데이터 삭제
    await prefs.remove('messages_$friendId'); // 저장된 메시지 삭제
  }


  // 채팅방 추가 함수 (TalkListPage에 채팅방 저장)
  Future<void> _addChatRoom(String friendId, String friendName,
      String? profileImagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    List<dynamic> chatRoomsList = chatRoomsJson != null ? json.decode(
        chatRoomsJson) : [];

    // 고유 ID를 사용하여 채팅방이 이미 존재하는지 확인
    bool roomExists = chatRoomsList.any((room) => room['id'] == friendId);

    // 채팅방이 없을 경우 추가, 프로필 이미지 경로도 함께 저장
    if (!roomExists) {
      chatRoomsList.add({
        'id': friendId, // 고유 ID로 채팅방 구분
        'name': friendName,
        'lastMessage': '',
        'profileImage': profileImagePath, // 프로필 이미지 경로 추가
        'lastMessageTime': DateTime.now().toIso8601String() // 채팅방 생성 시간 추가
      });

      String updatedChatRoomsJson = json.encode(chatRoomsList);
      await prefs.setString('chatRooms', updatedChatRoomsJson);
    }
  }


  // 친구 클릭 시 TalkRoomPage로 이동 및 채팅방 생성
  Future<void> _openChatRoom(BuildContext context, String friendId,
      String friendName, String? profileImagePath) async {
    // 기존 채팅방이 있으면 새로운 채팅방을 만들지 않음 (ID를 기반으로)
    await _addChatRoom(friendId, friendName, profileImagePath);

    // 채팅방 페이지로 이동 시 ID와 프로필 이미지 경로도 전달
    final lastMessage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TalkRoomPage(friendId: friendId,
                friendName: friendName,
                profileImagePath: profileImagePath), // ID로 채팅방을 연결
      ),
    );

    if (lastMessage != null) {
      _updateLastMessage(friendId, lastMessage); // 마지막 메시지 업데이트
    }

    // TalkListPage로 네비게이션 바를 가진 상태로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationPage(initialIndex: 1), // 채팅방 목록 탭으로 이동
      ),
    );
  }


  // 마지막 메시지 업데이트 함수
  void _updateLastMessage(String friendId, String lastMessage) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    if (chatRoomsJson != null) {
      List<dynamic> chatRoomsList = json.decode(chatRoomsJson);
      int roomIndex = chatRoomsList.indexWhere((room) =>
      room['id'] == friendId); // ID로 찾음

      if (roomIndex != -1) {
        chatRoomsList[roomIndex]['lastMessage'] = lastMessage;
        String updatedChatRoomsJson = json.encode(chatRoomsList);
        await prefs.setString('chatRooms', updatedChatRoomsJson);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // 어두운 푸른 계열 배경
      appBar: AppBar(
        title: Text(
          '친구 목록',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 흰색 텍스트로 푸른 배경과 대비
          ),
        ),
        backgroundColor: Colors.transparent, // 투명한 AppBar
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목을 중앙에 배치
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.white), // 흰색 아이콘
            onPressed: () async {
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
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(),
                ),
              );
              _updateProfileFromPreferences();
            },
            child: Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2), // 글래스모피즘 효과를 위한 반투명한 푸른색 배경
                borderRadius: BorderRadius.circular(20), // 둥근 모서리
                border: Border.all(
                  color: Colors.white.withOpacity(0.3), // 테두리 반투명한 흰색
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 부드러운 그림자
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null
                        ? Text(
                      _name[0],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                        : null,
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.3), // 반투명한 푸른색 배경
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _jobTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70, // 부드러운 흰색
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 친구 목록
          Expanded(
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2), // 반투명한 푸른 배경
                    borderRadius: BorderRadius.circular(20), // 둥근 모서리
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3), // 테두리 반투명
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      _openChatRoom(
                        context,
                        friend['id']!,
                        friend['name']!,
                        friend['profileImage'],
                      );
                    },
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: friend['profileImage'] != null
                          ? FileImage(File(friend['profileImage']!))
                          : null,
                      child: friend['profileImage'] == null
                          ? Text(
                        friend['name']![0],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          : null,
                      backgroundColor: Colors.cyanAccent.withOpacity(0.3), // 반투명한 푸른색 배경
                    ),
                    title: Text(
                      friend['name']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white70),
                          onPressed: () async {
                            final updatedFriend = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FriendsEditPage(
                                  id: friend['id']!,
                                  name: friend['name']!,
                                  chatData: friend['chatData']!,
                                  profileImagePath: friend['profileImage'],
                                ),
                              ),
                            );

                            if (updatedFriend != null) {
                              setState(() {
                                _friends[index] = {
                                  'id': _friends[index]['id'],
                                  'name': updatedFriend['name'],
                                  'chatData': updatedFriend['chatData'],
                                  'profileImage': updatedFriend['profileImage'],
                                };
                              });
                              _saveFriends();
                              _updateChatRoomProfile(
                                _friends[index]['id']!,
                                updatedFriend['name'],
                                updatedFriend['profileImage'],
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.lightBlueAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.blueGrey[900],
                                  title: Text('친구 삭제', style: TextStyle(color: Colors.white)),
                                  content: Text('정말로 이 친구를 삭제하시겠습니까?', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      child: Text('취소', style: TextStyle(color: Colors.white70)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('삭제', style: TextStyle(color: Colors.lightBlueAccent)),
                                      onPressed: () {
                                        _deleteFriendAndChatRoom(friend['id']!, index);
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
