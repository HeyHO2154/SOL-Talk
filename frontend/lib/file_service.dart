import 'package:flutter/services.dart' show rootBundle;

class FileService {
  // 특정 사용자의 메시지 필터링 함수
  Future<List<String>> loadChatContext() async {
    try {
      final contents = await rootBundle.loadString('assets/chat.txt');
      List<String> lines = contents.split('\n'); // 줄 단위로 분할
      List<String> messagesFromSpecificUser = [];

      for (String line in lines) {
        if (line.contains('지히 :')) { // '싸피 이미림'의 메시지인지 확인
          // 타임스탬프와 이름을 제외한 메시지 부분 추출
          int startIndex = line.indexOf('지히 :') + '지히 :'.length;
          if (startIndex > -1 && startIndex < line.length) {
            String message = line.substring(startIndex).trim();
            messagesFromSpecificUser.add(message);
          }
        }
      }
      return messagesFromSpecificUser; // '싸피 이미림'의 메시지만 반환
    } catch (e) {
      print('Error loading chat file: $e');
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }
}
