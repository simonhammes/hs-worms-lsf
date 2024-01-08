import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

Future<http.Response> _fetchDocument() async {
  final url = Uri.parse(
      "https://lsf.hs-worms.de/qisserver/rds?state=currentLectures&type=0&next=CurrentLectures.vm&nextdir=ressourcenManager&navigationPosition=lectures%2CcurrentLectures&breadcrumb=currentLectures&topitem=lectures&subitem=currentLectures&noDBAction=y&init=y&asi=");
  final response = await http.get(url);

  if (response.statusCode != HttpStatus.ok) {
    throw Exception('Failed to fetch courses');
  }

  return response;
}

class Course {
  // TODO: Fix data types
  final String start;
  final String finish;
  // final String number;
  final String title;
  final String building;
  final String room;
  // final String comment;

  const Course({
    required this.start,
    required this.finish,
    // required this.number,
    required this.title,
    required this.building,
    required this.room,
    // required this.comment,
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
    final title = cells[2].text.trim();
    final building = cells[3].text.trim();
    final room = cells[4].text.trim();

    final course = Course(
      start: start,
      finish: finish,
      // number: number,
      title: title,
      building: building,
      room: room,
      // comment: comment,
    );

    courses.add(course);
  }

  return courses;
}

class AllLectures extends StatelessWidget {
  const AllLectures({super.key});

  @override
  Widget build(BuildContext context) {
    final future = _fetchDocument();

    return FutureBuilder<http.Response>(
      future: future,
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
            // TODO
            // return Future(() { setState(() {}); });
            return Future.delayed(const Duration(seconds: 1));
          },
          child: _CourseList(courses),
        );
      },
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
          subtitle: Text(course.room),
          // Allow subtitle to contain 2 lines of text
          isThreeLine: false,
          leading: Text(course.start),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
