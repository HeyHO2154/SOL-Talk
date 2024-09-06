import 'package:flutter/material.dart';
import '../Friends/Friends_List.dart';
import '../Talk/Talk_List.dart';
import '../Gifts/GiftShop.dart';
import '../Setting.dart';

class NavigationPage extends StatefulWidget {
  final int initialIndex;

  NavigationPage({this.initialIndex = 0});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 초기 인덱스를 받아서 설정
  }

  static List<Widget> _pages = <Widget>[
    FriendsListPage(),
    TalkListPage(),
    GiftShopPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // 선택된 페이지 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // 현재 선택된 인덱스
        onTap: _onItemTapped, // 탭 선택 시 페이지 전환
        selectedItemColor: Colors.blue, // 선택된 아이템 색상
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        backgroundColor: Colors.white, // 배경색 설정
        showUnselectedLabels: true, // 선택되지 않은 라벨도 보이도록 설정
        type: BottomNavigationBarType.fixed, // 아이템이 4개 이상일 경우 고정
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Talk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Gift Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
