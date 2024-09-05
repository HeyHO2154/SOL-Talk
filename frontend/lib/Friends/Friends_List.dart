import 'package:flutter/material.dart';

class FriendsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: Column(
        children: [
          // 본인 프로필
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile_picture.png'), // 본인 프로필 사진 경로
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
          Divider(),
          // 친구 목록
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/friend1.png'), // 친구 프로필 사진 경로
                  ),
                  title: Text('Jane Smith'),
                  subtitle: Text('Hey, let\'s catch up soon!'),
                  trailing: Icon(Icons.chat),
                  onTap: () {
                    // 친구 클릭 시 동작 (예: 채팅 페이지로 이동)
                  },
                ),
                // 필요하면 더 많은 친구 추가 가능
              ],
            ),
          ),
        ],
      ),
    );
  }
}
