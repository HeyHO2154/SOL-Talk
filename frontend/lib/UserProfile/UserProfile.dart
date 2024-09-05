import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_picture.png'), // 프로필 사진 경로 (로컬 이미지 사용)
              ),
              SizedBox(height: 16),
              Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Flutter Developer',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24),
              Divider(),
              ListTile(
                leading: Icon(Icons.cake),
                title: Text('Birthdate'),
                subtitle: Text('1990-01-01'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Gender'),
                subtitle: Text('Male'),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone Number'),
                subtitle: Text('+1 234 567 890'),
              ),
              ListTile(
                leading: Icon(Icons.account_balance),
                title: Text('Bank Account'),
                subtitle: Text('1234-5678-9012'),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text('johndoe@example.com'),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Address'),
                subtitle: Text('1234, Flutter St, Code City'),
              ),
              Divider(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 수정 버튼 클릭 시 동작 (예: 정보 수정 페이지로 이동)
                },
                child: Text('Edit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
