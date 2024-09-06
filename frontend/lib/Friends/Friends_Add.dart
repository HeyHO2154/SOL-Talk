import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위해 추가
import 'package:device_info_plus/device_info_plus.dart'; // 디바이스 정보 가져오기

class FriendsAddPage extends StatefulWidget {
  @override
  _FriendsAddPageState createState() => _FriendsAddPageState();
}

class _FriendsAddPageState extends State<FriendsAddPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _chatData = '';
  String _filePath = ''; // 선택된 파일 경로
  File? _profileImage; // 프로필 이미지 파일 저장 변수

  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 객체

  // 외부 저장소 권한 요청 및 확인 함수
  Future<void> _checkAndRequestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Android 버전 확인
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      int sdkVersion = androidInfo.version.sdkInt;

      if (sdkVersion < 30) {
        // Android 10 이하
        status = await Permission.storage.status;

        if (status.isGranted) {
          _pickFile();
        } else {
          if (await Permission.storage.request().isGranted) {
            _pickFile();
          } else {
            _showPermissionDialog(); // 권한 부여가 실패하면 다이얼로그 표시
          }
        }
      } else {
        // Android 11 이상에서는 READ_MEDIA_* 권한을 요청
        if (await Permission.mediaLibrary.isGranted) {
          _pickFile(); // 권한이 있으면 바로 파일 탐색창 열기
        } else {
          if (await Permission.mediaLibrary.request().isGranted) {
            _pickFile(); // 권한 부여 후 파일 탐색창 열기
          } else {
            _showPermissionDialog(); // 권한 부여가 실패하면 다이얼로그 표시
          }
        }
      }
    } else {
      // iOS 및 다른 플랫폼에서는 기본 권한 요청 처리
      status = await Permission.storage.request();
      if (status.isGranted) {
        _pickFile();
      } else {
        _showPermissionDialog();
      }
    }
  }

  // 프로필 이미지 선택 함수
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // 선택한 이미지 파일 저장
      });
    }
  }

  // 파일 선택 함수
  Future<void> _pickFile() async {
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
          _chatData = fileContent; // 파일의 내용을 chatData로 설정
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

  // 권한이 없을 때 권한 설정으로 이동하는 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Storage Permission'),
        content: Text(
            'Storage permission is required to pick a file. Please enable it in the app settings.'),
        actions: <Widget>[
          TextButton(
            child: Text('Open Settings'),
            onPressed: () {
              openAppSettings(); // 앱 설정 화면으로 이동하여 권한 허용을 요청
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // 친구 추가 함수
  void _saveFriend() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'name': _name,
        'chatData': _chatData,
        'profileImage': _profileImage?.path, // 프로필 이미지 경로 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 프로필 사진 추가
              GestureDetector(
                onTap: _pickProfileImage, // 프로필 이미지 선택
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.add_a_photo)
                      : null, // 기본 프로필 이미지가 없으면 아이콘 표시
                ),
              ),
              SizedBox(height: 16),
              // 친구 이름 입력
              TextFormField(
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
              // 친구 대화 데이터 입력
              TextFormField(
                decoration: InputDecoration(labelText: 'Chat Data'),
                readOnly: true, // 직접 입력하지 못하도록 설정
                controller: TextEditingController(
                    text: _filePath.isNotEmpty ? 'File: $_filePath' : ''),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a chat data file';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkAndRequestStoragePermission, // 권한 확인 및 파일 선택 버튼
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
