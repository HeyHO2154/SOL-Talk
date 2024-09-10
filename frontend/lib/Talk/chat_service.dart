import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 변환을 위해 추가

class ChatService {
  get message => null;

  // 지정된 경로에서 특정 상대방이 보낸 메시지만 추출하는 함수
  Future<List<String>> extractMessagesFromChatData(String filePath, String friendName) async {
    List<String> extractedMessages = [];

    try {
      if (filePath.isEmpty || !(await File(filePath).exists())) {
        throw 'Invalid file path';
      }

      File file = File(filePath); // 저장된 경로에서 파일 열기
      print("Extracting from path: $filePath");
      String chatData = await file.readAsString(); // 파일 내용 읽기

      // 로그로 전체 chatData 출력
      print('전체 chatData: $chatData');

      // 대화 기록을 줄 단위로 나눔
      List<String> chatLines = chatData.split('\n');

      // 친구 이름이 포함된 메시지만 필터링
      for (String line in chatLines) {
        print('현재 처리중인 줄: $line');
        if (line.contains('$friendName :')) {
          String message = line.split(':').last.trim(); // ':' 뒤의 메시지 부분만 추출
          extractedMessages.add(message);

          // 디버깅: 추출된 메시지 로그 출력
          print('추출된 메시지: $message');
        }
      }
    } catch (e) {
      print('Error reading chat data from file: $e');
    }

    print('전체 추출된 메시지: $extractedMessages');
    return extractedMessages;
  }


  // 추출한 메시지를 로컬 저장소에 저장하는 함수
  Future<void> saveExtractedMessages(String friendId, List<String> messages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String messagesJson = json.encode(messages); // 메시지를 JSON 형식으로 변환
    await prefs.setString('messages_$friendId', messagesJson); // 저장
  }

  // 저장된 메시지 로드
  Future<List<String>> loadExtractedMessages(String friendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? messagesJson = prefs.getString('messages_$friendId');
    if (messagesJson != null) {
      return List<String>.from(json.decode(messagesJson)); // JSON에서 리스트로 변환
    }
    return [];
  }
}
