import 'package:flutter/material.dart';
import 'Friends/Friends_List.dart';
import 'Gifts/GiftShop.dart';
import 'Setting.dart';
import 'Talk/Talk_List.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  // 각 페이지와 연결될 위젯 리스트
  static List<Widget> _pages = <Widget>[
    FriendsListPage(), // Friends_List.dart에 연결
    TalkListPage(),    // Talk_List.dart에 연결
    GiftShopPage(),    // GiftShop.dart에 연결
    SettingsPage(),    // Setting.dart에 연결
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 페이지를 표시
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends', // Friends_List.dart와 연결
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Talk',    // Talk_List.dart와 연결
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',    // GiftShop.dart와 연결
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings', // Setting.dart와 연결
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        onTap: _onItemTapped, // 탭 클릭 시 페이지 전환
      ),
    );
  }
}
