import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<http.Response> fetchDocument() async {
  final url = Uri.parse(
      "https://lsf.hs-worms.de/qisserver/rds?state=currentLectures&type=1&next=CurrentLectures.vm&nextdir=ressourcenManager&navigationPosition=lectures%2CcanceledLectures&breadcrumb=canceledLectures&topitem=lectures&subitem=canceledLectures&asi=");
  final response = await http.get(url);

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('Failed to fetch courses');
  }

  print("Hello World");

  return response;
}

class Course {
  // TODO: Fix data types
  final String start;
  final String finish;
  final String number;
  final String title;
  final String building;
  final String room;
  final String comment;

  const Course({
    required this.start,
    required this.finish,
    required this.number,
    required this.title,
    required this.building,
    required this.room,
    required this.comment,
  });
}

List<Course> parseDocument(String html) {
  final courses = <Course>[];
  final document = parse(html);
  // TODO: Error handling
  // TODO: Access tr's directly

  final rows = document.querySelectorAll("tr");
  // Use skip(1) to skip over table header
  for (final row in rows.skip(1)) {
    final cells = row.children;
    final start = cells[0].text.trim();
    final finish = cells[1].text.trim();
    final number = cells[2].text.trim();
    final title = cells[3].text.trim();
    final building = cells[4].text.trim();
    final room = cells[5].text.trim();
    final comment = cells[8].text.trim();

    final course = Course(
      start: start,
      finish: finish,
      number: number,
      title: title,
      building: building,
      room: room,
      comment: comment,
    );

    courses.add(course);
  }

  return courses;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<http.Response> futureResponse;
  ViewType _viewType = ViewType.list;

  @override
  void initState() {
    super.initState();
    futureResponse = fetchDocument();
  }

  @override
  Widget build(BuildContext context) {
    futureResponse = fetchDocument();
    return MaterialApp(
      title: 'LSF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('LSF'),
          actions: [
            IconButton(
              icon: determineIcon(),
              onPressed: () {
                setState(() {
                  _viewType = switch (_viewType) {
                    ViewType.list => ViewType.table,
                    ViewType.table => ViewType.list,
                  };
                });
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder<http.Response>(
            future: futureResponse,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              if (!snapshot.hasData) {
                // Show a loading spinner
                return const CircularProgressIndicator();
              }

              final courses = parseDocument(snapshot.data!.body);

              return RefreshIndicator(
                // key: _refreshIndicatorKey,
                onRefresh: () {
                  return Future(() { setState(() {}); });
                },
                child: switch (_viewType) {
                  ViewType.table => _CourseDataTable(courses),
                  ViewType.list => _CourseList(courses),
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Icon determineIcon() {
    switch (_viewType) {
      case ViewType.list:
        return const Icon(Icons.view_list);
      case ViewType.table:
        return const Icon(Icons.view_column_outlined);
    }
  }
}

enum ViewType { list, table }

class _CourseDataTable extends StatelessWidget {
  static const headers = [
    "Start",
    "Finish",
    "Number",
    "Title",
    "Building",
    "Room",
    "Comment",
  ];

  final List<Course> courses;

  const _CourseDataTable(this.courses);

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        for (final header in headers)
          DataColumn(
            // TODO: Try without Expanded
            label: Expanded(
              child: Text(header),
            ),
          )
      ],
      rows: [
        for (final course in courses)
          DataRow(
            cells: [
              DataCell(Text(course.start)),
              DataCell(Text(course.finish)),
              DataCell(Text(course.number)),
              DataCell(Text(course.title)),
              DataCell(Text(course.building)),
              DataCell(Text(course.room)),
              DataCell(Text(course.comment)),
            ],
          )
      ],
    );
  }
}

class _CourseList extends StatelessWidget {
  final List<Course> courses;

  const _CourseList(this.courses);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return ListTile(
          title: Text(course.title),
          subtitle: Text('${course.room}\n${course.comment}'),
          // Allow subtitle to contain 2 lines of text
          isThreeLine: true,
          leading: Text(course.start),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
