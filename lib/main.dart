import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './style.dart';

final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await firestore.collection('product').get();
  for (var doc in result.docs) {
    print(doc['name']);
  }


  runApp(MaterialApp(
    home: login(),
    debugShowCheckedModeBanner: false,
    theme: theme
  ));
}

class login extends StatefulWidget {
  login({super.key});

  var loginState = Column(
    children: [

    ],
  );

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  var emailInput = TextEditingController();
  var pwInput = TextEditingController();
  var inputStyle = InputDecoration( border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),  );
  // var buttonStyle =

  loginProc(email, pw) async{

    try {
      await auth.signInWithEmailAndPassword(
          email: email,
          password: pw
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => index())
      );
    } catch (e) {
      print(e);
    }
  }

  enrollProc(email, pw) async{

    try {
      var result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );
      print(result.user);
      showDialog(context: context, builder: (context){
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("회원가입 완료!"),
              TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("닫기")
              )
            ],
          ),
        );
           // , addTwo : andTwo 하는 식으로 추가 가능
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인 테스트"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 50,),
          Text("Email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField( controller: emailInput, decoration: inputStyle),
          Container(height: 10,),
          Text("PW", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField( controller: pwInput, decoration: inputStyle),
          Container(height: 30,),
          Align(
            alignment: Alignment.center,
            child: TextButton(
                style: ButtonStyle(),
                onPressed: (){
                  loginProc(emailInput.text, pwInput.text);
                },
                child: Text("로그인")
            ),
          ),
            Align(
            alignment: Alignment.center,
            child: TextButton(
                style: ButtonStyle(),
                onPressed: (){
                  enrollProc(emailInput.text, pwInput.text);
                },
                child: Text("회원가입")
            )
          ),

        ],
      )
    );
  }
}


class index extends StatelessWidget {
  index({super.key});


  initState() {
    if(auth.currentUser?.uid == null){
      print('로그인 안된 상태군요');
    } else {
      print('로그인 하셨네');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              height: 50,
            ),
            Text("환영합니다! " + (auth.currentUser?.email).toString() + "님!"),
            TextButton(
                onPressed: () async {
                  await auth.signOut();
                },
                child: Text("로그아웃")
            ),
          ],
        ),
      )
    );
  }
}
