import 'package:flutter/material.dart';
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

  void _updateProfile(Map<String, String> updatedProfile) {
    setState(() {
      _name = updatedProfile['name']!;
      _jobTitle = updatedProfile['jobTitle']!;
      _email = updatedProfile['email']!;
      _gender = updatedProfile['gender']!;
      _birthdate = updatedProfile['birthdate']!;
      _phoneNumber = updatedProfile['phoneNumber']!;
      _bankAccount = updatedProfile['bankAccount']!;
    });
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
