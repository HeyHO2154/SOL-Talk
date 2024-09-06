import 'package:flutter/material.dart';
import 'Account_Reset.dart'; // 비밀번호 재설정 페이지 import

class AccountFindPage extends StatefulWidget {
  @override
  _AccountFindPageState createState() => _AccountFindPageState();
}

class _AccountFindPageState extends State<AccountFindPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find Your Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Enter Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 이메일 입력 후 비밀번호 재설정 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountResetPage()),
                );
              },
              child: Text('Find Account'),
            ),
          ],
        ),
      ),
    );
  }
}
