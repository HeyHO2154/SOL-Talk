import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();

  Future<void> _register() async {
    final url = Uri.parse('http://10.0.2.2:8081/api/register'); // 백엔드 엔드포인트
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _idController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'birthDate': _birthDateController.text,
        'email': _emailController.text,
      }),
    );

    if (response.statusCode == 201) {
      // 성공적으로 등록된 경우
      Navigator.pop(context);
    } else {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      // 등록 실패 처리
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('회원가입 실패'),
          content: Text('회원가입 중 오류가 발생했습니다. 다시 시도해주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 페이지'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _birthDateController,
              decoration: InputDecoration(labelText: '생년월일 (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: '이메일 주소'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
