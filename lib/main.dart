/**
 *
 * Eddie, enguagns2@gmail.com
 *
 */

import 'demo_widget.dart';
import 'droppable_widget.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Droppable Cards',
      home: Scaffold(
        body: HomePager(),
      ),
    );
  }
}

class HomePager extends StatefulWidget {
  @override
  _HomePagerState createState() => _HomePagerState();
}

class _HomePagerState extends State<HomePager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Droppable Cards'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 48.0, 48.0),
        child: DroppableWidget(
          children: <Widget>[
            DemoWidget(assets: 'assets/cards/card_1.jpg'),
            DemoWidget(assets: 'assets/cards/card_2.jpg'),
            DemoWidget(assets: 'assets/cards/card_3.jpg'),
          ],
        ),
      ),
    );
  }
}
