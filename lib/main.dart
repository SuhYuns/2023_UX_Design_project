import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'feedback.dart';
import 'firebase_options.dart';
import 'users.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Main()));
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _Main();
}

class _Main extends State<Main> {
  var state = 0;
  var test = "";
  final auth = FirebaseAuth.instance;

  logout() async {
    await auth.signOut();
  }

  var user_name = "";
  user_name_change() {
    setState(() {
      user_name = "익명";
      var nullCheck = auth.currentUser!.email ?? 'none';
      if (nullCheck != null) {
        test = auth.currentUser!.email.toString();
        test = test.substring(0, test.indexOf('@'));
        user_name = test;
      }
      print("hello");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // user_name_change();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text("trace", style: TextStyle(color: Colors.indigo)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if(auth.currentUser?.uid == null)
            TextButton(
                onPressed: (){
                  showDialog(context: context, barrierDismissible: true, builder: (context) {
                    return Users_login(user_name_change: user_name_change);
                  });

                },
                child: Text("비회원 상태", style: TextStyle(fontSize: 12))
            ),
          if(auth.currentUser?.uid != null)
            TextButton(
                onPressed: (){
                  showDialog(context: context, barrierDismissible: true, builder: (context) {
                    return logout();
                  });
                },
                child: Text(user_name + " 님", style: TextStyle(fontSize: 12),)
            ),
          PopupMenuButton(
            // add icon, by default "3 dot" icon

              icon: Icon(Icons.list, color: Colors.black),
              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                    value: 0,
                    child: TextButton(
                      child: Text("백업/로드"),
                      onPressed: (){
                        showDialog(context: context, barrierDismissible: true, builder: (context) {
                          return Test();
                        });
                      },
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: TextButton(
                      child:Text("문의하기"),
                      onPressed: (){

                      },
                    )
                  ),
                ];
              },
              onSelected: (value) {
                if (value == 0) {
                  print("My account menu is selected.");
                } else if (value == 1) {
                  print("Settings menu is selected.");
                }
              }),
        ],
      ),
      body: [home(), record()][state],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.indigo,
        onTap: (i) {
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
        onPressed: () {
          showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) {
                return addLocation();
              });
        },
      ),
    );
  }
}

class addBlock extends StatefulWidget {
  addBlock({super.key, this.selectedDay, this.view_todo});
  final selectedDay;
  final view_todo;

  @override
  State<addBlock> createState() => _addBlockState();
}

class _addBlockState extends State<addBlock> {
  var todoInput = TextEditingController();
  var currentValue = '1 menu';
  var loc_list;

  var _valueList = ["미설정"];
  var _selectedValue = "미설정";

  save_todo(item) async {
    var storage = await SharedPreferences.getInstance();
    var nullCheck = storage.getStringList('todo_items') ?? 'none';
    var date = widget.selectedDay.year.toString() +
        widget.selectedDay.month.toString() +
        widget.selectedDay.day.toString();
    var location = _selectedValue;

    if (nullCheck == 'none') {
      storage.setStringList("todo_items", []);
    }

    var itemList = storage.getStringList("todo_items");
    itemList?.add(jsonEncode(
        {'date': date, "item": item, "done": false, "location": location}));
    storage.setStringList('todo_items', itemList!);
    print("저장 완료!");
  }

  @override
  void initState() {
    super.initState();
    _asyncMethod();

  }

  _asyncMethod() async {
    var storage = await SharedPreferences.getInstance();
    var nullCheck = storage.getStringList('locations') ?? 'none';

    if (nullCheck == 'none') {
      storage.setStringList("locations", ["미설정"]);
    }

    _valueList = storage.getStringList("locations")!.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade100,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 100,
      ),
      child: SizedBox(
        width: 100,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "${widget.selectedDay.year} ${widget.selectedDay.month} ${widget.selectedDay.day}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            _menuBtn(),
            TextField(
              controller: todoInput,
              decoration: InputDecoration(
                  labelText: "todo 추가",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            TextButton(
              child: Text("추가"),
              onPressed: () {
                save_todo(todoInput.text);
                widget.view_todo();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuBtn() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.indigo),
          color: Color.fromARGB(245, 245, 245, 245),
      ),
      child: DropdownButton(
        style: TextStyle(backgroundColor: Color.fromARGB(245, 245, 245, 245)),
        value: _selectedValue,
        // for(String str in loc_list!)
        //   DropdownMenuItem(value: str.toString(), child: Text(str)),
        items: _valueList.map((value) {
          return DropdownMenuItem(value: value, child: Text(value, style: TextStyle(color: Colors.black),));
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            _selectedValue = value!;
          });
        },
      ),
    );
  }
}

class addLocation extends StatelessWidget {
  addLocation({super.key});

  var LocInput = TextEditingController();

  addLoc() async {
    var storage = await SharedPreferences.getInstance();
    var nullCheck = storage.getStringList('locations') ?? 'none';

    if (nullCheck == 'none') {
      storage.setStringList("locations", ["미설정"]);
    }

    var locList = storage.getStringList("locations");
    locList?.add(LocInput.text);
    print(locList);
    storage.setStringList('locations', locList!);
    print("저장 완료!");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade100,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 100,
      ),
      child: SizedBox(
        width: 100,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "장소 추가하기",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: LocInput,
              decoration: InputDecoration(
                  labelText: "장소를 추가해 주세요",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            TextButton(
              child: Text("추가"),
              onPressed: () {
                addLoc();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}


class deL_check extends StatefulWidget {
  deL_check({super.key, this.target, this.view_todo});
  final target;
  final view_todo;

  @override
  State<deL_check> createState() => _deL_checkState();
}

class _deL_checkState extends State<deL_check> {
  del_item() async {

    // 수정 확인 버튼 만들기
    var storage = await SharedPreferences.getInstance();
    var item_list = storage.getStringList("todo_items");
    item_list!.removeAt(widget.target);
    storage.setStringList('todo_items', item_list!);
    var itemList = storage.getStringList("todo_items");
    var test = jsonDecode(itemList as String);

  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey.shade100,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 50,
        vertical: 100,
      ),
      child: SizedBox(
        width: 100,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "해당 목록을 삭제할까요?",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                TextButton(
                  child: Text("삭제", style: TextStyle(color: Colors.red),),
                  onPressed: () {
                    del_item();
                    Navigator.pop(context);
                    widget.view_todo();
                  },
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("취소")
                )

              ],
            ),

          ],
        ),
      ),
    );;;
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
  var items_count;
  var items_done;
  var percentage;

  clear() async {
    var storage = await SharedPreferences.getInstance();
    storage.remove("todo_items");
    print("삭제 완료!");
    view_todo();
  }

  view_todo() async {
    var storage = await SharedPreferences.getInstance();
    var nullCheck = storage.getStringList('todo_items') ?? 'none';
    var date = selectedDay.year.toString() +
        selectedDay.month.toString() +
        selectedDay.day.toString();

    if (nullCheck == 'none') {
      // 기존 요소 없을 시 초기화
      storage.setStringList("todo_items", []);
    }

    setState(() {
      current_todo_items = [];
      var itemList = storage.getStringList("todo_items");
      var counting = 0;
      items_count = 0;
      items_done = 0;
      itemList?.forEach((i) {
        if (jsonDecode(i)['date'] == date) {
          items_count += 1;
          var test = jsonDecode(i);
          test["number"] = counting;
          current_todo_items.add(test);
          if (test["done"] == true) {
            items_done += 1;
          }
        }
        counting += 1;
      });

      // percentage = ((items_done / items_count) * 100) as int;
      // if (items_count == 0) percentage = 0;
    });
  }

  change_state(target) async {
    var storage = await SharedPreferences.getInstance();
    var itemList = storage.getStringList("todo_items");

    if (itemList != null && itemList.length > 1) {
      var test = jsonDecode(itemList[target]);
      test["done"] = !test["done"];
      itemList[target] = jsonEncode(test);
      storage.setStringList('todo_items', itemList);
    } else {
      print(itemList);
      print("todo_items 키로 저장된 값이 없거나 인덱스가 올바르지 않습니다.");
    }
    view_todo();
  }

  del_item(target) async {

    // 수정 확인 버튼 만들기
    var storage = await SharedPreferences.getInstance();
    var item_list = storage.getStringList("todo_items");
    print(item_list);
    item_list!.removeAt(target);
    print(item_list);
    storage.setStringList('todo_items', item_list!);
    var itemList = storage.getStringList("todo_items");

    // var test = jsonDecode(itemList as String);

    // view_todo();
  }

  @override
  void initState() {
    super.initState();
    view_todo();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              // 캘린더 디자인 관련 부분
              headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(fontSize: 15)),
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
                setState(() {
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


            Row(
              children: [
                Text("    전체 목록 : " + items_count.toString()),
                Text("   완료한 목록 : " + items_done.toString() + "(" + (((items_done / items_count) * 100).isNaN ?  0 : (items_done / items_count) * 100).toStringAsFixed(2) + "%)"),
              ],

            ),

            Container(
              height: 20,
            ),

            ListView.builder(shrinkWrap: true,
                itemCount: current_todo_items.length,
                itemBuilder: (c, i) {
                  var done = TextDecoration.none;
                  if (current_todo_items[i]["done"] == true) {
                    done = TextDecoration.lineThrough;
                  }

                  return ListTile(
                    onTap: () {
                      print(current_todo_items[i]["item"].toString() + current_todo_items[i]["done"].toString());
                      change_state(current_todo_items[i]["number"]);
                    },
                    title: Container(
                      child: Row(
                        children: [
                          Text("[ " + current_todo_items[i]["location"] + " ]      " + current_todo_items[i]["item"],
                            style: TextStyle(
                                decoration: done
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel_outlined, size: 14),
                      onPressed: (){
                        {
                          showDialog(context: context, barrierDismissible: true, builder: (context) {
                            return deL_check(target : current_todo_items[i]["number"], view_todo: view_todo);
                          });
                        }
                      },
                    ),
                  );
                }
            ),
            Container(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  showDialog(context: context, barrierDismissible: true, builder: (context) {
                    return addBlock(selectedDay : selectedDay, view_todo: view_todo);
                  });
                },
                child: Text("todo 추가하기")
            ),
            TextButton(
                onPressed: (){
                  clear();
                },
                child: Text("초기화")
            )
          ],
        ),
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
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Container(
              height: 80,
            ),
            Text("장소별 통계", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            PieChartSample3(),
            Text("수행률", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            PieChartSample1(),
          ],
        )
      ),
    );
  }
}
