import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Account Settings'),
            subtitle: Text('Update your profile, password, etc.'),
            onTap: () {
              // 계정 설정 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification Settings'),
            subtitle: Text('Manage notification preferences'),
            onTap: () {
              // 알림 설정 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Privacy Settings'),
            subtitle: Text('Adjust your privacy settings'),
            onTap: () {
              // 개인정보 설정 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            subtitle: Text('Select language'),
            onTap: () {
              // 언어 설정 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About App'),
            subtitle: Text('Learn more about the app'),
            onTap: () {
              // 앱 정보 페이지로 이동
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out'),
            onTap: () {
              // 로그아웃 처리 로직 추가
            },
          ),
        ],
      ),
    );
  }
}
