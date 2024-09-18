import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GiftShopPage extends StatefulWidget {
  @override
  _GiftShopPageState createState() => _GiftShopPageState();
}

class _GiftShopPageState extends State<GiftShopPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  double _selectedBudget = 50;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  List<String> _giftItems = [
    'Chocolate Box',
    'Flower Bouquet',
    'Teddy Bear',
    'Coffee Gift Card',
    'Movie Ticket'
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  // 이벤트 로드
  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEvents = prefs.getString('events');
    if (savedEvents != null) {
      final decodedEvents = Map<DateTime, List<Map<String, dynamic>>>.from(
        json.decode(savedEvents).map(
              (key, value) => MapEntry(DateTime.parse(key), List<Map<String, dynamic>>.from(value)),
        ),
      );
      setState(() {
        _events = decodedEvents;
      });
    }
  }

  // 이벤트 저장
  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedEvents = _events.map(
          (key, value) => MapEntry(key.toIso8601String(), value),
    );
    await prefs.setString('events', json.encode(encodedEvents));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900], // 어두운 배경으로 세련된 느낌
      appBar: AppBar(
        title: Text(
          '기념일 캘린더',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // 흰색 텍스트로 대비
          ),
        ),
        backgroundColor: Colors.transparent, // 투명한 AppBar
        elevation: 0,
        centerTitle: true, // 제목을 중앙에 배치
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.5), // 오늘 날짜의 배경색을 더 세련되게 변경
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.lightBlueAccent, // 선택한 날짜의 배경색을 밝은 푸른색으로 변경
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.redAccent), // 주말 텍스트 색상 변경
              defaultTextStyle: TextStyle(color: Colors.white), // 일반 텍스트는 흰색
              selectedTextStyle: TextStyle(color: Colors.white), // 선택된 날짜의 텍스트 색상
            ),
          ),

          const SizedBox(height: 8.0),

          _buildEventList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addEventDialog();
        },
        backgroundColor: Colors.lightBlueAccent, // FAB 색상 변경
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventList() {
    if (_selectedDay == null) {
      return Center(
        child: Text(
          'Please select a day',
          style: TextStyle(color: Colors.white70), // 흰색 계열 텍스트
        ),
      );
    }

    final events = _events[_selectedDay!] ?? [];
    if (events.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No events found',
            style: TextStyle(fontSize: 18, color: Colors.white70), // 흰색 계열 텍스트
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              color: Colors.blueGrey[800], // 카드 배경색을 어두운 푸른색으로 변경
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['event'],
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gift: ${event['gift']}',
                      style: TextStyle(fontSize: 18, color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Budget: \$${event['budget']}',
                      style: TextStyle(fontSize: 18, color: Colors.greenAccent),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          //_deleteEvent(index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  // 일정 추가 다이얼로그
  void _addEventDialog() {
    final TextEditingController eventController = TextEditingController();
    String? _selectedGift;
    double _selectedBudget = 50;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey[800], // 다이얼로그 배경을 어두운 푸른색으로
            title: Text('Add Event', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: eventController,
                  style: TextStyle(color: Colors.white), // 입력 텍스트도 흰색으로
                  decoration: InputDecoration(
                    hintText: 'Enter event name',
                    hintStyle: TextStyle(color: Colors.white54), // 힌트 텍스트 색상
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1), // 반투명한 배경
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedGift,
                  dropdownColor: Colors.blueGrey[800], // 드롭다운 배경색 변경
                  hint: Text('Select a gift', style: TextStyle(color: Colors.white)),
                  items: _giftItems.map((gift) {
                    return DropdownMenuItem<String>(
                      value: gift,
                      child: Text(gift, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGift = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Choose Gift',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1), // 반투명한 배경
                  ),
                ),
                const SizedBox(height: 16.0),
                Text('Select Maximum Budget: \$${_selectedBudget.toInt()}', style: TextStyle(color: Colors.white)),
                Slider(
                  value: _selectedBudget,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  label: '\$${_selectedBudget.toInt()}',
                  activeColor: Colors.cyanAccent,
                  inactiveColor: Colors.white30,
                  onChanged: (value) {
                    setState(() {
                      _selectedBudget = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Add', style: TextStyle(color: Colors.lightBlueAccent)),
                onPressed: () {
                  if (_selectedDay != null &&
                      eventController.text.isNotEmpty &&
                      _selectedGift != null) {
                    setState(() {
                      if (_events[_selectedDay!] == null) {
                        _events[_selectedDay!] = [];
                      }
                      _events[_selectedDay!]!.add({
                        'event': eventController.text,
                        'gift': _selectedGift,
                        'budget': _selectedBudget.toInt()
                      });
                      _saveEvents(); // 저장
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
