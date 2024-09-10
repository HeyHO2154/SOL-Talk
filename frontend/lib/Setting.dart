import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // 파일 경로를 가져오기 위해 추가
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  // 모든 친구 및 일정과 관련된 데이터를 삭제하는 함수
  Future<void> _resetData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. 친구 목록 삭제
    await prefs.remove('friendsList');

    // 2. 채팅방 목록 삭제
    await prefs.remove('chatRooms');

    // 3. 개별 대화 메시지 삭제 (모든 친구와 관련된 메시지 삭제)
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('messages_')) {
        await prefs.remove(key);
      }
    }

    // 4. 파일 시스템에서 채팅 데이터와 이미지 삭제
    try {
      // 앱의 파일 저장 경로를 가져옴
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;

      // 파일 경로 목록 삭제
      for (String key in keys) {
        if (key.startsWith('selectedFilePath_')) {
          String? filePath = prefs.getString(key);
          if (filePath != null && await File(filePath).exists()) {
            await File(filePath).delete(); // 파일 삭제
          }
          await prefs.remove(key); // SharedPreferences에서도 제거
        }

        // 프로필 이미지 삭제
        if (key.startsWith('friend_') && key.endsWith('_profileImage')) {
          String? imagePath = prefs.getString(key);
          if (imagePath != null && await File(imagePath).exists()) {
            await File(imagePath).delete(); // 프로필 이미지 삭제
          }
          await prefs.remove(key); // SharedPreferences에서도 제거
        }
      }
    } catch (e) {
      print('Error deleting files: $e');
    }

    // 5. 일정 관련 데이터 삭제
    await prefs.remove('events'); // 일정 데이터 삭제

    // 초기화 완료 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('모든 친구 및 일정과 관련된 데이터가 삭제되었습니다.')),
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
                  content: Text('모든 친구 및 일정과 관련된 데이터를 삭제하시겠습니까?'),
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
