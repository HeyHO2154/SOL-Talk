import 'dart:math';
import 'chat_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIThinking {
  final ChatService _chatService = ChatService();
  final String _sollamaApiUrl = 'https://your-sollama-api-url/v1/categorize'; // Sollama 카테고리 API URL
  final String _sollamaApiKey = 'your_sollama_api_key'; // Sollama API 키

  // 추출된 메시지들을 카테고리로 분류하는 함수
  Future<Map<String, List<String>>> categorizeMessages(String friendId) async {
    List<String> friendMessages = await _chatService.loadExtractedMessages(friendId);

    if (friendMessages.isEmpty) {
      throw Exception("No messages found to categorize.");
    }

    // Sollama API로 메시지 카테고리화 요청
    final response = await _callSollamaApiForCategorization(friendMessages);

    if (response.statusCode == 200) {
      Map<String, dynamic> categorizedResponse = jsonDecode(response.body);
      Map<String, List<String>> categorizedMessages = {};

      // 카테고리별로 메시지를 묶음
      categorizedResponse.forEach((category, messages) {
        categorizedMessages[category] = List<String>.from(messages);
      });

      return categorizedMessages;
    } else {
      throw Exception("Failed to categorize messages.");
    }
  }

  // 사용자의 입력을 Sollama에 전달하고 적절한 카테고리를 추천받는 함수
  Future<String> getCategoryForUserInput(String userMessage, Map<String, List<String>> categorizedMessages) async {
    final response = await _callSollamaApiForCategorySelection(userMessage, categorizedMessages.keys.toList());

    if (response.statusCode == 200) {
      Map<String, dynamic> categoryResponse = jsonDecode(response.body);
      String selectedCategory = categoryResponse['selected_category'];
      return selectedCategory;
    } else {
      throw Exception("Failed to select category.");
    }
  }

  // Sollama API를 호출하여 메시지 카테고리를 추출하는 함수
  Future<http.Response> _callSollamaApiForCategorization(List<String> messages) async {
    return await http.post(
      Uri.parse(_sollamaApiUrl),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_sollamaApiKey',
      },
      body: jsonEncode({
        'messages': messages,
      }),
    );
  }

  // Sollama API를 호출하여 사용자 입력에 맞는 카테고리를 선택하는 함수
  Future<http.Response> _callSollamaApiForCategorySelection(String userMessage, List<String> categories) async {
    final String apiUrl = 'https://your-sollama-api-url/v1/select_category'; // Sollama 카테고리 선택 API URL

    return await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_sollamaApiKey',
      },
      body: jsonEncode({
        'user_message': userMessage,
        'categories': categories,
      }),
    );
  }

  // Flutter에서 적절한 응답을 선택하는 함수
  Future<String?> getBestResponse(String userMessage, String friendId) async {
    // 먼저 메시지를 카테고리로 분류
    Map<String, List<String>> categorizedMessages = await categorizeMessages(friendId);

    // 사용자 메시지에 적절한 카테고리를 Sollama로부터 받아옴
    String selectedCategory = await getCategoryForUserInput(userMessage, categorizedMessages);

    // 해당 카테고리의 메시지 중 하나를 랜덤하게 선택
    List<String>? selectedMessages = categorizedMessages[selectedCategory];
    final random = Random();
    String? response = selectedMessages?[random.nextInt(selectedMessages.length)];

    return response;
  }
}
