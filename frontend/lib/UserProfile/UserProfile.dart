import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'UserProfile_edit.dart'; // UserProfileEditPage import

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _name = 'John Doe';
  String _jobTitle = 'Flutter Developer';
  String _email = 'johndoe@example.com';
  String _gender = 'Male';
  String _birthdate = '1990-01-01';
  String _phoneNumber = '123-456-7890';
  String _bankAccount = '1234-5678-9012';
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 프로필 정보 로드
  }

  // 프로필 정보 로컬 저장소에서 불러오기
  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
      _email = prefs.getString('email') ?? _email;
      _gender = prefs.getString('gender') ?? _gender;
      _birthdate = prefs.getString('birthdate') ?? _birthdate;
      _phoneNumber = prefs.getString('phoneNumber') ?? _phoneNumber;
      _bankAccount = prefs.getString('bankAccount') ?? _bankAccount;
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  // 수정된 프로필을 반영하는 함수
  void _updateProfile(Map<String, String?> updatedProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = updatedProfile['name'] ?? _name;
      _jobTitle = updatedProfile['jobTitle'] ?? _jobTitle;
      _email = updatedProfile['email'] ?? _email;
      _gender = updatedProfile['gender'] ?? _gender;
      _birthdate = updatedProfile['birthdate'] ?? _birthdate;
      _phoneNumber = updatedProfile['phoneNumber'] ?? _phoneNumber;
      _bankAccount = updatedProfile['bankAccount'] ?? _bankAccount;
      _profileImagePath = updatedProfile['profileImagePath'];
    });

    await prefs.setString('name', _name);
    await prefs.setString('jobTitle', _jobTitle);
    await prefs.setString('email', _email);
    await prefs.setString('gender', _gender);
    await prefs.setString('birthdate', _birthdate);
    await prefs.setString('phoneNumber', _phoneNumber);
    await prefs.setString('bankAccount', _bankAccount);
    // 프로필 수정 후 SharedPreferences에 프로필 이미지 경로 저장
    if (_profileImagePath != null) {
      await prefs.setString('profileImagePath', _profileImagePath!); // 경로 저장
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))  // 로컬 저장소에서 이미지 로드
                      : AssetImage('assets/profile_picture.png') as ImageProvider,  // 기본 이미지
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _jobTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(_email),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Gender'),
            subtitle: Text(_gender),
          ),
          ListTile(
            title: Text('Birthdate'),
            subtitle: Text(_birthdate),
          ),
          ListTile(
            title: Text('Phone Number'),
            subtitle: Text(_phoneNumber),
          ),
          ListTile(
            title: Text('Bank Account'),
            subtitle: Text(_bankAccount),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final updatedProfile = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileEditPage(
                    name: _name,
                    jobTitle: _jobTitle,
                    email: _email,
                    gender: _gender,
                    birthdate: _birthdate,
                    phoneNumber: _phoneNumber,
                    bankAccount: _bankAccount,
                  ),
                ),
              );

              if (updatedProfile != null) {
                _updateProfile(updatedProfile);
              }
            },
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
