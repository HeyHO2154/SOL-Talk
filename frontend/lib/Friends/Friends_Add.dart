import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위한 패키지
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위해 추가
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Talk/chat_service.dart'; // 디바이스 정보 가져오기

class FriendsAddPage extends StatefulWidget {
  get id => null;

  @override
  _FriendsAddPageState createState() => _FriendsAddPageState();
}

class _FriendsAddPageState extends State<FriendsAddPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _chatData = '';
  String _filePath = ''; // 선택된 파일 경로
  String? friendId; // friendId를 저장하는 변수
  File? _profileImage; // 프로필 이미지 파일 저장 변수
  ChatService _chatService = ChatService(); // ChatService 인스턴스 생성
  final Uuid uuid = Uuid(); // UUID 생성기
  final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 객체

  @override
  void initState() {
    super.initState();
    friendId = uuid.v4(); // friendId를 한 번만 생성
  }

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
          if (await Permission.storage
              .request()
              .isGranted) {
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
          if (await Permission.mediaLibrary
              .request()
              .isGranted) {
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

  // 파일 선택 함수
  Future<void> _pickFile() async {
    try {
      await _clearCache(); // 캐시를 비워서 이전 파일을 제거

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowedExtensions: ['txt'], // txt 파일만 선택 가능
        type: FileType.custom,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        File selectedFile = File(file.path!);
        String fileContent = await selectedFile.readAsString();

        // 고유한 파일 이름을 생성 (예: "originalname-UUID.txt")
        String newFileName = '${file.name
            .split('.')
            .first}-$friendId.txt';

        // 디바이스의 특정 경로에 복사본을 저장
        Directory appDocDir = await getApplicationDocumentsDirectory(); // 로컬 앱 저장소 경로
        String newPath = '${appDocDir.path}/$newFileName'; // 새 경로 설정
        await selectedFile.copy(newPath); // 파일 복사

        // SharedPreferences에 새 경로 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('selectedFilePath_$friendId', newPath);
        print('저장한 경로 : $newPath');
        print('저장한 friendId : $friendId'); // friendId 확인

        setState(() {
          _chatData = fileContent; // 파일의 내용을 chatData로 설정
          _filePath = newPath; // 복사된 파일의 새 경로 저장
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


  // 권한이 없을 때 권한 설정으로 이동하는 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
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
  Future<void> _saveFriend() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 채팅 데이터에서 친구의 메시지만 추출
      List<String> friendMessages = await _chatService
          .extractMessagesFromChatData(_filePath, _name);

      // 저장된 friendId를 SharedPreferences에 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('friendId_${widget.id}', friendId!);

      await _chatService.saveExtractedMessages(friendId!, friendMessages);

      Navigator.pop(context, {
        'id': friendId, // 생성된 UUID 전달
        'name': _name,
        'chatData': _chatData,
        'profileImage': _profileImage?.path, // 프로필 이미지 경로 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 밝은 배경색으로 설정
      appBar: AppBar(
        title: Text(
          '친구 추가',
          style: TextStyle(
            color: Colors.white, // 흰색 텍스트
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent, // 밝은 파스텔 톤의 배경색
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 프로필 사진 추가
              GestureDetector(
                onTap: _pickProfileImage, // 프로필 이미지 선택
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? FileImage(
                      _profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.add_a_photo, size: 40, color: Colors.white)
                      : null, // 기본 프로필 이미지가 없으면 아이콘 표시
                  backgroundColor: Colors.lightBlueAccent.withOpacity(
                      0.6), // 프로필 사진 배경 색상
                ),
              ),
              const SizedBox(height: 24),

              // 친구 이름 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '친구이름(카톡명 그대로)',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
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
              const SizedBox(height: 24),

              // 친구 대화 데이터 입력 필드
              TextFormField(
                decoration: InputDecoration(
                  labelText: '추출된 대화 내역',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.lightBlueAccent),
                  ),
                ),
                readOnly: true, // 직접 입력하지 못하도록 설정
                controller: TextEditingController(
                  text: _filePath.isNotEmpty ? 'File: $_filePath' : '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a chat data file';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 파일 선택 버튼
              ElevatedButton.icon(
                onPressed: _checkAndRequestStoragePermission,
                // 권한 확인 및 파일 선택 버튼
                icon: Icon(Icons.attach_file, color: Colors.white),
                label: Text('카카오톡 대화내역 불러오기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
              const SizedBox(height: 32),

              // 친구 추가 버튼
              ElevatedButton(
                onPressed: _saveFriend,
                child: Text('저장'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent, // 버튼 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
