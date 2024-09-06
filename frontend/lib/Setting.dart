import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  // 모든 친구와 관련된 데이터를 삭제하는 함수
  Future<void> _resetData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 친구 목록 삭제
    await prefs.remove('friendsList');

    // 채팅방 목록 삭제
    await prefs.remove('chatRooms');

    // 개별 대화 메시지 삭제 (모든 친구와 관련된 메시지 삭제)
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('messages_')) {
        await prefs.remove(key);
      }
    }

    // 초기화 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('모든 친구와 관련된 데이터가 삭제되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 초기화 버튼 클릭 시 데이터 삭제
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('초기화'),
                  content: Text('모든 친구와 관련된 데이터를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      child: Text('취소'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('삭제'),
                      onPressed: () {
                        _resetData(context); // 데이터 삭제 함수 호출
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Text('초기화 버튼'),
        ),
      ),
    );
  }
}
