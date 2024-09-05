import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UserProfile/UserProfile.dart';
import '../Friends/Friends_Add.dart'; // FriendsAddPage import

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, String>> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();  // 친구 목록 불러오기
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

  // 친구 목록을 로컬 저장소에 저장하는 함수
  void _saveFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String friendsJson = json.encode(_friends);
    await prefs.setString('friendsList', friendsJson);
  }

  // 모든 친구 데이터를 삭제하는 함수
  void _deleteAllFriends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('friendsList'); // 저장된 친구 목록 삭제
    setState(() {
      _friends.clear();  // UI에서 친구 목록 제거
    });
  }

  // 새로운 친구를 추가하고 저장하는 함수
  void _addFriend(Map<String, String> friend) {
    setState(() {
      _friends.add(friend);
    });
    _saveFriends();  // 추가 후 저장
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
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text('JD'),  // 기본 프로필: 이니셜 표시
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Flutter Developer',
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
                  trailing: Icon(Icons.chat),
                  onTap: () {
                    // 친구 클릭 시 동작 (예: 채팅 페이지로 이동)
                  },
                );
              },
            ),
          ),
          // 모든 친구 데이터 삭제 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _deleteAllFriends,
              child: Text('Delete All Friends'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // 삭제 버튼을 빨간색으로 표시
              ),
            ),
          ),
        ],
      ),
    );
  }
}
