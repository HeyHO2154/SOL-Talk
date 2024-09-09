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
            .map((friend) => Map<String, String?>.from(friend as Map)) // String? 타입으로 변환
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
      _profileImagePath = prefs.getString('profileImagePath'); // 프로필 이미지 경로 불러오기
    });
  }

  // 프로필 수정 후 프로필 동기화 함수 및 채팅방 정보 갱신
  Future<void> _updateProfileFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 프로필 정보 동기화
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
      _profileImagePath = prefs.getString('profileImagePath'); // 프로필 이미지 경로 불러오기
    });

    // 프로필에 해당하는 채팅방의 ID 가져오기
    String? myId = prefs.getString('myId'); // 고유한 ID 불러오기

    // 채팅방 리스트에서 내 프로필을 사용하는 방들 업데이트
    if (myId != null) {
      await _updateChatRoomProfile(myId, _name, _profileImagePath); // ID, 이름, 프로필 이미지 전달
    }
  }

  // 채팅방 리스트에 내 프로필 정보를 반영하는 함수
  Future<void> _updateChatRoomProfile(String friendId, String updatedName, String? updatedProfileImage) async {
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
    _saveFriends();  // 추가된 친구 목록 저장
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
  Future<void> _addChatRoom(String friendId, String friendName, String? profileImagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? chatRoomsJson = prefs.getString('chatRooms');
    List<dynamic> chatRoomsList = chatRoomsJson != null ? json.decode(chatRoomsJson) : [];

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
  Future<void> _openChatRoom(BuildContext context, String friendId, String friendName, String? profileImagePath) async {
    // 기존 채팅방이 있으면 새로운 채팅방을 만들지 않음 (ID를 기반으로)
    await _addChatRoom(friendId, friendName, profileImagePath);

    // 채팅방 페이지로 이동 시 ID와 프로필 이미지 경로도 전달
    final lastMessage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TalkRoomPage(friendId: friendId, friendName: friendName, profileImagePath: profileImagePath), // ID로 채팅방을 연결
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
      int roomIndex = chatRoomsList.indexWhere((room) => room['id'] == friendId); // ID로 찾음

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
            onTap: () async {
              // UserProfilePage로 이동 후, 수정된 프로필 정보 받기
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(), // UserProfilePage로 이동
                ),
              );
              // 수정된 프로필 정보를 동기화
              _updateProfileFromPreferences();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                    child: _profileImagePath == null ? Text(_name[0]) : null, // 프로필 이미지가 없으면 이니셜 표시
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
                  onTap: () {
                    // 친구 이름을 클릭했을 때도 채팅방으로 이동
                    _openChatRoom(
                      context,
                      friend['id']!, // 친구 고유 ID 전달
                      friend['name']!, // 친구 이름
                      friend['profileImage'] != null ? friend['profileImage'] : null, // 친구 프로필 이미지 경로
                    );
                  },
                  leading: GestureDetector(
                    onTap: () async {
                      final updatedFriend = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendsEditPage(
                            id: _friends[index]['id']!, // 고유 ID 유지
                            name: _friends[index]['name']!,
                            chatData: _friends[index]['chatData']!,
                            profileImagePath: _friends[index]['profileImage'],
                          ),
                        ),
                      );

                      if (updatedFriend != null) {
                        setState(() {
                          _friends[index] = {
                            'id': _friends[index]['id'], // 유지되는 고유 ID
                            'name': updatedFriend['name'],
                            'chatData': updatedFriend['chatData'],
                            'profileImage': updatedFriend['profileImage'],
                          };
                        });
                        _saveFriends(); // 수정된 데이터를 로컬 저장소에 저장

                        // 채팅방 정보도 함께 업데이트
                        _updateChatRoomProfile(
                            _friends[index]['id']!,      // 친구 ID
                            updatedFriend['name'],       // 새 이름
                            updatedFriend['profileImage'] // 새 프로필 이미지
                        );
                      }
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: friend['profileImage'] != null
                          ? FileImage(File(friend['profileImage']!))
                          : null,
                      child: friend['profileImage'] == null
                          ? Text(friend['name']![0])
                          : null, // 친구 이름의 첫 글자로 기본 프로필 표시
                    ),
                  ),
                  title: Text(friend['name']!),
                  trailing: Wrap(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black), // 수정 버튼
                        onPressed: () async {
                          final updatedFriend = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendsEditPage(
                                id: friend['id']!, // 고유 ID 유지
                                name: friend['name']!,
                                chatData: friend['chatData']!,
                                profileImagePath: friend['profileImage'],
                              ),
                            ),
                          );

                          if (updatedFriend != null) {
                            setState(() {
                              _friends[index] = {
                                'id': _friends[index]['id'], // 유지되는 고유 ID
                                'name': updatedFriend['name'],
                                'chatData': updatedFriend['chatData'],
                                'profileImage': updatedFriend['profileImage'],
                              };
                            });
                            _saveFriends(); // 수정된 데이터를 로컬 저장소에 저장

                            // 채팅방 정보도 함께 업데이트
                            _updateChatRoomProfile(
                              _friends[index]['id']!, // 친구 ID
                              updatedFriend['name'], // 새 이름
                              updatedFriend['profileImage'], // 새 프로필 이미지
                            );
                          }
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
                                content: Text('Are you sure you want to delete this friend and related chat room and data?'),
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
                                      _deleteFriendAndChatRoom(friend['name']!, index); // 친구 및 모든 관련 데이터 삭제
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
