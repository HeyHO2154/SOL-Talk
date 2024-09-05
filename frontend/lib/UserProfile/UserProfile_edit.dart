import 'package:flutter/material.dart';

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
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.pop(context, {
        'name': _name,
        'jobTitle': _jobTitle,
        'email': _email,
        'gender': _gender,
        'birthdate': _birthdate,
        'phoneNumber': _phoneNumber,
        'bankAccount': _bankAccount,
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
