import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../UserProfile/UserProfile_edit.dart'; // UserProfileEditPage import
import 'FinanceReport.dart'; // FinanceReportPage import

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

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 프로필 정보 로드
  }

  // 프로필 정보 로컬 저장소에서 불러오기
  void _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _jobTitle = prefs.getString('jobTitle') ?? _jobTitle;
      _email = prefs.getString('email') ?? _email;
      _gender = prefs.getString('gender') ?? _gender;
      _birthdate = prefs.getString('birthdate') ?? _birthdate;
      _phoneNumber = prefs.getString('phoneNumber') ?? _phoneNumber;
      _bankAccount = prefs.getString('bankAccount') ?? _bankAccount;
    });
  }

  // 프로필 수정 후 로컬 저장소에 저장하는 함수
  void _updateProfile(Map<String, String> updatedProfile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = updatedProfile['name']!;
      _jobTitle = updatedProfile['jobTitle']!;
      _email = updatedProfile['email']!;
      _gender = updatedProfile['gender']!;
      _birthdate = updatedProfile['birthdate']!;
      _phoneNumber = updatedProfile['phoneNumber']!;
      _bankAccount = updatedProfile['bankAccount']!;
    });
    await prefs.setString('name', _name);
    await prefs.setString('jobTitle', _jobTitle);
    await prefs.setString('email', _email);
    await prefs.setString('gender', _gender);
    await prefs.setString('birthdate', _birthdate);
    await prefs.setString('phoneNumber', _phoneNumber);
    await prefs.setString('bankAccount', _bankAccount);
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
                  backgroundImage: AssetImage('assets/profile_picture.png'),
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
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // 금융 분석 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FinanceReportPage()),
              );
            },
            child: Text('Go to Finance Report'),
          ),
        ],
      ),
    );
  }
}
