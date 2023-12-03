import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
final firestore = FirebaseFirestore.instance;


test() async {
  var result = await firestore.collection('product').doc('문서id').get();
  print(result);
}


class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


