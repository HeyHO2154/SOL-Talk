import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart'; // 파일 선택을 위한 패키지

class FriendsEditPage extends StatefulWidget {
  final String name;
  final String chatData;
  final String? profileImagePath;

  FriendsEditPage({
    required this.name,
    required this.chatData,
    required this.profileImagePath, required String id,
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

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _chatData = widget.chatData;
    _profileImagePath = widget.profileImagePath;
  }

  // 프로필 이미지 선택 함수
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // 선택한 이미지 파일 저장
        _profileImagePath = pickedFile.path; // 이미지 경로 저장
      });
    }
  }

  // 파일 선택 함수 (ChatData 파일 선택용)
  Future<void> _pickChatDataFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt'], // txt 파일만 선택 가능
        type: FileType.custom,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        File selectedFile = File(file.path!);
        String fileContent = await selectedFile.readAsString();

        setState(() {
          _chatData = fileContent; // 파일 내용을 chatData로 설정
          _filePath = file.path!;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File selected: ${file.name}')),
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
      await _saveFriendToLocal(); // 로컬 저장소에 저장
      Navigator.pop(context, {
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
                decoration: InputDecoration(labelText: 'Chat Data'),
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
