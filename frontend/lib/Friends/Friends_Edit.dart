import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../Talk/chat_service.dart'; // 파일 선택을 위한 패키지

class FriendsEditPage extends StatefulWidget {
  final String id;
  final String name;
  final String chatData;
  final String? profileImagePath;

  FriendsEditPage({
    required this.id, // UUID는 유지됨
    required this.name,
    required this.chatData,
    required this.profileImagePath,
  });

  @override
  _FriendsEditPageState createState() => _FriendsEditPageState();
}

class _FriendsEditPageState extends State<FriendsEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _chatData;
  String? _profileImagePath;
  File? _profileImage;
  String? _filePath; // 선택된 파일 경로 저장
  ChatService _chatService = ChatService(); // ChatService 인스턴스 생성

  final ImagePicker _picker = ImagePicker();
  final Uuid uuid = Uuid(); // UUID 생성기

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _chatData = widget.chatData;
    _profileImagePath = widget.profileImagePath;

    // SharedPreferences에서 저장된 파일 경로를 불러옴
    _loadSavedChatData();
  }

  // 프로필 이미지 선택 함수 (저장 기능 추가)
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 디바이스의 특정 경로에 복사본을 저장
      Directory appDocDir = await getApplicationDocumentsDirectory(); // 영구 저장소 경로
      String newFileName = '${Uuid().v4()}.png'; // 고유한 파일 이름 생성
      String newPath = '${appDocDir.path}/$newFileName'; // 새 경로 설정
      File newImage = await File(pickedFile.path).copy(newPath); // 파일 복사

      setState(() {
        _profileImage = newImage; // 복사된 이미지 파일 저장
      });

      // 프로필 이미지 경로를 SharedPreferences에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath', newPath); // 경로 저장
    }
  }

  // 캐시를 비우는 함수
  Future<void> _clearCache() async {
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  // 파일 선택 함수 (ChatData 파일 선택용)
  Future<void> _pickChatDataFile() async {
    try {

      await _clearCache(); // 캐시를 비우는 작업 추가

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt'], // txt 파일만 선택 가능
        type: FileType.custom,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        File selectedFile = File(file.path!);
        String fileContent = await selectedFile.readAsString();

        // 고유한 파일 이름을 생성 (예: "originalname-UUID.txt")
        String newFileName = '${file.name.split('.').first}-${uuid.v4()}.txt';

        // 디바이스의 특정 경로에 복사본을 저장
        Directory appDocDir = await getApplicationDocumentsDirectory(); // 로컬 앱 저장소 경로
        String newPath = '${appDocDir.path}/$newFileName'; // 새 경로 설정
        await selectedFile.copy(newPath); // 파일 복사

        // 선택한 파일 경로를 SharedPreferences에 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedFilePath', newPath); // 경로 저장

        setState(() {
          _chatData = fileContent; // 파일 내용을 chatData로 설정
          _filePath = newPath; // 복사된 파일 경로 저장
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected and saved: $newFileName')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _loadSavedChatData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedFilePath = prefs.getString('selectedFilePath');
    if (savedFilePath != null && await File(savedFilePath).exists()) {
      setState(() {
        _filePath = savedFilePath;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved file not found. Please select a new file.')),
      );
    }
  }


  // 친구 데이터를 로컬 저장소에 저장하는 함수
  Future<void> _saveFriendToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 저장된 친구 데이터를 업데이트
    await prefs.setString('friend_${_name}_profileImage', _profileImagePath ?? '');
    await prefs.setString('friend_${_name}_chatData', _chatData);
  }

  // 친구 데이터 저장 및 업데이트 함수
  void _saveFriend() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 채팅 데이터에서 친구의 메시지만 추출
      List<String> friendMessages = await _chatService.extractMessagesFromChatData(_chatData, _name);

      // 추출한 메시지 로컬 저장 (친구의 고유 ID로 저장)
      String friendId = widget.id; // 고유 ID 필요
      await _chatService.saveExtractedMessages(friendId, friendMessages);


      await _saveFriendToLocal(); // 로컬 저장소에 저장
      Navigator.pop(context, {
        'id': widget.id, // 수정해도 UUID는 그대로 유지
        'name': _name,
        'chatData': _chatData,
        'profileImage': _profileImagePath, // 수정된 프로필 이미지 경로 반환
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 프로필 사진 수정
              GestureDetector(
                onTap: _pickProfileImage, // 프로필 이미지 선택
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                  child: _profileImagePath == null
                      ? Icon(Icons.add_a_photo)
                      : null, // 기본 프로필 이미지가 없으면 아이콘 표시
                ),
              ),
              SizedBox(height: 16),
              // 친구 이름 수정
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Friend Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              // 친구 대화 데이터 수정
              TextFormField(
                initialValue: _filePath != null ? 'File: $_filePath' : widget.chatData,
                //decoration: InputDecoration(labelText: 'Chat Data'),
                readOnly: true, // 직접 입력하지 못하도록 설정
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickChatDataFile, // 파일 선택 버튼 추가
                child: Text('Select Chat Data File'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveFriend,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
