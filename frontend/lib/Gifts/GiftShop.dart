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
      appBar: AppBar(
        title: Text('Gift Shop Calendar'),
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
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
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
        child: Icon(Icons.add),
      ),
    );
  }

  // 일정 목록 출력
  Widget _buildEventList() {
    if (_selectedDay == null) {
      return Center(child: Text('Please select a day'));
    }

    final events = _events[_selectedDay!] ?? [];
    if (events.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'No events found',
            style: TextStyle(fontSize: 18),
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
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['event'],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gift: ${event['gift']}',
                      style: TextStyle(fontSize: 20, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Budget: \$${event['budget']}',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteEvent(index);
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

  // 일정 삭제 함수
  void _deleteEvent(int index) {
    setState(() {
      _events[_selectedDay!]!.removeAt(index);
      if (_events[_selectedDay!]!.isEmpty) {
        _events.remove(_selectedDay!);
      }
      _saveEvents();
    });
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
            title: Text('Add Event'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: eventController,
                  decoration: InputDecoration(hintText: 'Enter event name'),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _selectedGift,
                  hint: Text('Select a gift'),
                  items: _giftItems.map((gift) {
                    return DropdownMenuItem<String>(
                      value: gift,
                      child: Text(gift),
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
                  ),
                ),
                const SizedBox(height: 16.0),
                Text('Select Maximum Budget: \$${_selectedBudget.toInt()}'),
                Slider(
                  value: _selectedBudget,
                  min: 0,
                  max: 200,
                  divisions: 20,
                  label: '\$${_selectedBudget.toInt()}',
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
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text('Add'),
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
