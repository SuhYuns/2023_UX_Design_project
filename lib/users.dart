import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';



// test() async {
//   var result = await firestore.collection('product').doc('문서id').get();
//   print(result);
// }


class Users_login extends StatefulWidget {
  Users_login({super.key, this.user_name_change});
  final user_name_change;

  @override
  State<Users_login> createState() => _Users_loginState();
}

class _Users_loginState extends State<Users_login> {
  final firestore = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;

  var IdInput = TextEditingController();
  var PwInput = TextEditingController();

  login() async {
      try {
        await auth.signInWithEmailAndPassword(
            email: IdInput.text,
            password: PwInput.text
        );
        widget.user_name_change();
      } catch (e) {
        print(e);
      }
  }

  test() async {
    widget.user_name_change();
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
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("환영합니다!"),
            TextField(
              controller: IdInput,
              decoration: InputDecoration(
                  labelText: "ID",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            TextField(
              obscureText : true,
              controller: PwInput,
              decoration: InputDecoration(
                  labelText: "PASSWORD",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text("로그인", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  onPressed: () {
                    login();
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("회원가입", style: TextStyle(fontSize: 15)),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(context: context, barrierDismissible: true, builder: (context) {
                      return Users_register(user_name_change:test);
                    });
                  },
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}



class Users_register extends StatefulWidget {
  Users_register({super.key, this.user_name_change});
  final user_name_change;

  @override
  State<Users_register> createState() => _Users_registerState();
}

class _Users_registerState extends State<Users_register> {
  final firestore = FirebaseFirestore.instance;

  final auth = FirebaseAuth.instance;

  var IdInput = TextEditingController();
  var PwInput = TextEditingController();

  register() async {
    try {
      var result = await auth.createUserWithEmailAndPassword(
        email: IdInput.text,
        password: PwInput.text,
      );
      var test = IdInput.text;

      print(result.user);

    } catch (e) {
      print(e);
    }

    try {
      await auth.signInWithEmailAndPassword(
          email: IdInput.text,
          password: PwInput.text
      );
      widget.user_name_change();
    } catch (e) {
      print(e);
    }
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
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("가입하고 자료를 안전하게 보관하세요!"),
            TextField(
              controller: IdInput,
              decoration: InputDecoration(
                  labelText: "ID",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            TextField(
              obscureText : true,
              controller: PwInput,
              decoration: InputDecoration(
                  labelText: "PASSWORD",
                  filled: true,
                  fillColor: Colors.indigo.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none, // 테두리 선을 없애준다
                  )),
            ),
            TextButton(
              child: Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                register();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}


class Test extends StatelessWidget {
  Test({super.key});
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  view() async {
    var storage = await SharedPreferences.getInstance();

    var nullCheck = storage.getStringList('todo_items') ?? 'none';
    var nullCheck2 = storage.getStringList('locations') ?? 'none';

    if (nullCheck == 'none') {
      storage.setStringList("todo_items", []);
      nullCheck = storage.getStringList('todo_items') ?? 'none';
    }
    if (nullCheck2 == 'none') {
      storage.setStringList("locations", ["미설정"]);
      nullCheck2 = storage.getStringList('locations') ?? 'none';
    }

    var userCheck = auth.currentUser!.uid ?? 'none';
    if (userCheck != 'none') {
      await firestore.collection('storage').add({'items' : nullCheck, 'locations' : nullCheck2, "user" : userCheck});
    }

    print(nullCheck);
    print(nullCheck2);
    print(jsonEncode(nullCheck));
    print(jsonEncode(nullCheck2));
    // print(jsonDecode(nullCheck));
    // print(jsonDecode(nullCheck2));
    print(nullCheck.runtimeType);
    print(nullCheck2.runtimeType);


    // var itemList = storage.getStringList("todo_items");
    // itemList?.add(jsonEncode(
    //     {'date': date, "item": item, "done": false, "location": location}));

    // print("저장 완료!");

  }

  load() async {
    var storage = await SharedPreferences.getInstance();
    var userCheck = auth.currentUser!.uid ?? 'none';
    if (userCheck != 'none') {
      var result = await firestore.collection('storage').where("user", isEqualTo: userCheck).get();
      // print(jsonDecode(result));


      var nullCheck = storage.getStringList('todo_items') ?? 'none';
      if (nullCheck == 'none') {
        storage.setStringList("todo_items", []);
      }

      print(nullCheck);
      print(nullCheck.runtimeType);
      print("저장 완료!");

      var items_list = new List.empty(growable: true);
      var locs_list = new List.empty(growable: true);

      for (var doc in result.docs) {
        for (var doc2 in doc['items']) {
          items_list.add(doc2 as String);
        }
        for (var doc3 in doc['location']) {
          locs_list.add(doc3 as String);
        }
      }

      final List<String> strs = items_list.map((e) => e.toString()).toList();
      final List<String> locs2 = items_list.map((e) => e.toString()).toList();
      print(locs2);
      storage.remove("todo_items");
      // storage.remove("locations");
      storage.setStringList('todo_items', strs);
      // storage.setStringList('locations', locs2);
    }

      // print(result.docs[0]['items']);
      // var items_list = new List.empty(growable: true);
      // var locs_list = new List.empty(growable: true);
      // for (var doc in result.docs) {
      //   print(doc['items']);
      //
      //   for (var doc2 in doc['items']) {
      //     items_list.add(jsonEncode(doc2));
      //   }
      //   for (var doc3 in doc['location']) {
      //     locs_list.add(jsonEncode(doc3));
      //   }
      //
      //   print(items_list as String);
      //   // print(locs_list);
      //   storage.setStringList('todo_items', items_list);
        // storage.setStringList('locations', locs_list);
    //   }
    //   // var test = result['user'] ?? 'none';
    //
    // } else {
    //   print("오류 발생");
    // }



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
            Text("백업/로드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            TextButton(
              child: Text("백업", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                view();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("로드", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                load();
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}

