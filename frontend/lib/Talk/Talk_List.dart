import 'package:flutter/material.dart';
import 'Talk_Room.dart'; // TalkRoomPage를 import

class TalkListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk List'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              //backgroundImage: AssetImage('assets/friend1.png'), // 상대방 프로필 사진
            ),
            title: Text('Jane Smith'),
            subtitle: Text('Hey, are you free to talk?'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('12:30 PM'),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '2', // 읽지 않은 메시지 개수
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              // 대화방 클릭 시 TalkRoomPage로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TalkRoomPage()),
              );
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}
