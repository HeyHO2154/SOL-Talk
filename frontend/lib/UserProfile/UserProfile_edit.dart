import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'dart:io';

class UserProfileEditPage extends StatefulWidget {
  final String name;
  final String jobTitle;
  final String email;
  final String gender;
  final String birthdate;
  final String phoneNumber;
  final String bankAccount;

  UserProfileEditPage({
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.gender,
    required this.birthdate,
    required this.phoneNumber,
    required this.bankAccount,
  });

  @override
  _UserProfileEditPageState createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _jobTitle;
  late String _email;
  late String _gender;
  late String _birthdate;
  late String _phoneNumber;
  late String _bankAccount;
  File? _profileImage; // 프로필 이미지 파일 변수

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _jobTitle = widget.jobTitle;
    _email = widget.email;
    _gender = widget.gender;
    _birthdate = widget.birthdate;
    _phoneNumber = widget.phoneNumber;
    _bankAccount = widget.bankAccount;
    _loadProfileImage(); // 저장된 프로필 이미지를 로드
  }

  // 프로필 이미지를 SharedPreferences에서 불러오는 함수
  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedImagePath = prefs.getString('profileImagePath'); // 저장된 프로필 이미지 경로 불러오기
    if (savedImagePath != null) {
      setState(() {
        _profileImage = File(savedImagePath); // 프로필 이미지가 있으면 _profileImage에 할당
      });
    }
  }

  // 갤러리에서 프로필 사진 선택하는 함수
  Future<void> _pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path); // 선택된 이미지 파일을 _profileImage에 저장
      });
    }
  }

  // 수정된 프로필 정보를 로컬 저장소에 저장하는 함수
  Future<void> _saveProfileToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('jobTitle', _jobTitle);
    await prefs.setString('email', _email);
    await prefs.setString('gender', _gender);
    await prefs.setString('birthdate', _birthdate);
    await prefs.setString('phoneNumber', _phoneNumber);
    await prefs.setString('bankAccount', _bankAccount);
    if (_profileImage != null) {
      await prefs.setString('profileImagePath', _profileImage!.path); // 프로필 이미지 경로 저장
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await _saveProfileToLocal(); // 로컬 저장소에 저장
      Navigator.pop(context, {
        'name': _name,
        'jobTitle': _jobTitle,
        'email': _email,
        'gender': _gender,
        'birthdate': _birthdate,
        'phoneNumber': _phoneNumber,
        'bankAccount': _bankAccount,
        'profileImagePath': _profileImage?.path, // 이미지 경로 추가
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage, // 프로필 사진 선택
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 40) // 기본 아이콘
                      : null, // 프로필 이미지가 없을 때 기본 아이콘 표시
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _jobTitle,
                decoration: InputDecoration(labelText: 'Job Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your job title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _jobTitle = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((label) => DropdownMenuItem(
                  child: Text(label),
                  value: label,
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _birthdate,
                decoration: InputDecoration(labelText: 'Birthdate (YYYY-MM-DD)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birthdate';
                  }
                  return null;
                },
                onSaved: (value) {
                  _birthdate = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _phoneNumber,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _phoneNumber = value!;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _bankAccount,
                decoration: InputDecoration(labelText: 'Bank Account Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank account number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _bankAccount = value!;
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
