import 'package:flutter/material.dart';
import 'package:sample_app/models/todo.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

// fetch movies
Future<List<Todo>> fetchMovies() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/1'),
  );

  List<Map<String, dynamic>> decodedMoviesMap =
      (json.decode(response.body) as List<Map<String, dynamic>>);

  return decodedMoviesMap.map((movie) => Todo.fromJson(movie)).toList();
}

class MyApp extends StatelessWidget {
  late Future<List<Todo>> futureMovies;
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MaterialApp(title: 'Flutter Demo Home Page'),
    );
  }
}
