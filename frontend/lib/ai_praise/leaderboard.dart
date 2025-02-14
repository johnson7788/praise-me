import 'package:flutter/material.dart';


class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('StatelessWidget Example'),
        ),
        body: Center(
          child: MyStatelessWidget(text: 'Hello, Stateless!'),
        ),
      ),
    );
  }
}

class MyStatelessWidget extends StatelessWidget {
  final String text;

  MyStatelessWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 24, color: Colors.blue),
    );
  }
}