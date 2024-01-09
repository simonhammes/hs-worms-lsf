import 'package:flutter/material.dart';
import 'package:flutter_lsf/lectures/all_lectures.dart';
import 'package:flutter_lsf/lectures/changed_lectures.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<StatefulWidget> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AllLectures(),
    ChangedLectures(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSF',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: AppBar(title: const Text('LSF')),
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.school),
              label: 'Lectures',
            ),
            NavigationDestination(
              icon: Icon(Icons.warning),
              label: 'Changes',
            ),
          ],
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
