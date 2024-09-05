import 'package:flutter/material.dart';

class FriendsAddPage extends StatefulWidget {
  @override
  _FriendsAddPageState createState() => _FriendsAddPageState();
}

class _FriendsAddPageState extends State<FriendsAddPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _chatData = '';

  void _saveFriend() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'name': _name,
        'chatData': _chatData,
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some chat data';
                  }
                  return null;
                },
                onSaved: (value) {
                  _chatData = value!;
                },
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
