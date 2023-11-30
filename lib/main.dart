
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await initializeDateFormatting();
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TableCalendarScreen()
      )
  );
}


class TableCalendarScreen extends StatefulWidget {
  const TableCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TableCalendarScreen> createState() => _TableCalendarScreenState();
}

class _TableCalendarScreenState extends State<TableCalendarScreen> {
  var state = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("trace", style: TextStyle(color: Colors.indigo)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.list), onPressed: null),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: null),
        ],
      ),

      body: [home(), record()][state],

      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.indigo,
        onTap: (i){
          setState(() {
            state = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dns), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "기록"),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        onPressed: (){
          {};
        },
      ),
    );
  }
}


class home extends StatefulWidget {
  home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

  CalendarFormat format = CalendarFormat.week;

  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  DateTime focusedDay = DateTime.now();

  var todoInput = TextEditingController();
  var current_todo_items = [];

  clear() async {
    var storage = await SharedPreferences.getInstance();
    storage.remove("todo_items");
    print("삭제 완료!");
  }

  save_todo(item) async {
    var storage = await SharedPreferences.getInstance();
    var null_check = storage.getStringList('todo_items') ?? 'none';
    var date = selectedDay.year.toString() + selectedDay.month.toString() + selectedDay.day.toString();

    if (null_check == 'none') {
      // 기존 요소 없을 시 초기화
      storage.setStringList("todo_items", []);
    }

    var item_list = storage.getStringList("todo_items");
    item_list?.add(jsonEncode({ 'date' : date, "item" :  item}));
    storage.setStringList('todo_items', item_list!);
    print("저장 완료!");

  }

  view_todo() async {
    var storage = await SharedPreferences.getInstance();
    var null_check = storage.getStringList('todo_items') ?? 'none';
    var date = selectedDay.year.toString() + selectedDay.month.toString() + selectedDay.day.toString();

    if (null_check == 'none') {
      // 기존 요소 없을 시 초기화
      storage.setStringList("todo_items", []);
    }

    setState(() {
      current_todo_items = [];
      var item_list = storage.getStringList("todo_items");
      item_list?.forEach((i) {
        print(jsonDecode(i)['item']);
        print(jsonDecode(i)['date']);
        if (jsonDecode(i)['date'] == date) {
          current_todo_items.add(jsonDecode(i)['item']);
        }
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    view_todo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          // 캘린더 디자인 관련 부분
          headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontSize: 15)
          ),
          // calendarStyle: const CalendarStyle(
          //
          // ),

          locale: 'ko_KR',
          firstDay: DateTime.utc(2021, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: focusedDay,

          calendarFormat: format,
          onFormatChanged: (CalendarFormat format) {
            setState(() {
              this.format = format;
            });
          },
          onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
            // 선택된 날짜의 상태를 갱신합니다.
            setState((){
              this.selectedDay = selectedDay;
              this.focusedDay = focusedDay;
              view_todo();
            });

          },
          selectedDayPredicate: (DateTime day) {
            // selectedDay 와 동일한 날짜의 모양을 바꿔줍니다.
            return isSameDay(selectedDay, day);
          },
        ),

        ListView.builder(shrinkWrap: true,
              itemCount: current_todo_items.length,
              itemBuilder: (c, i) {
                return ListTile(
                  leading: Icon(Icons.check_box_outline_blank),
                  title: Text(current_todo_items[i].toString()),
                );
          }
          ),
        Container(
          height: 50,
        ),
        TextField(
          controller: todoInput,
          decoration: InputDecoration(
            labelText: "todo 추가",
              filled: true,
              fillColor: Colors.indigo.shade100,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none, // 테두리 선을 없애준다
              )
          ),

        ),
        TextButton(
          child: Text("추가"),
          onPressed: () {
            save_todo(todoInput.text);
            view_todo();
          },
        ),
      ],
    );
  }
}



class record extends StatefulWidget {
  record({super.key});

  @override
  State<record> createState() => _recordState();
}

class _recordState extends State<record> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("hello"),
    );
  }
}
