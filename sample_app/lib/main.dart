import 'package:flutter/material.dart';
import 'package:sample_app/models/todo.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// fetch movies
Future<Movie> fetchMovieData(
    String movieName, String? year, String? imdbID) async {
  final queryType = imdbID != null ? '&i=$imdbID' : '&t=$movieName';
  final yearQuery = year != null ? '&y=$year' : '';
  try {
    final response = await http.get(
      Uri.parse(
          'https://www.omdbapi.com/?$queryType$yearQuery&apikey=e56c123e'),
    );

    final movieInfo = (jsonDecode(response.body) as Map<String, dynamic>);

    return Movie.fromJson(movieInfo);
  } on Exception catch (e) {
    print('Exception details:\n $e');
    throw const FormatException('Expected at least 1 section');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Movie App',
        theme: ThemeData(
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 252, 251, 249)),
              ),
              labelStyle:
                  TextStyle(color: Color.fromRGBO(179, 179, 189, 0.678)),
              fillColor: Color.fromARGB(0, 152, 92, 111),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Color.fromARGB(255, 236, 226, 213)),
              ),
            ),
            textTheme:
                const TextTheme(bodyLarge: TextStyle(color: Colors.white))),
        home: Scaffold(
            appBar: AppBar(title: const Text('Movie Database')),
            backgroundColor: const Color.fromARGB(255, 0, 7, 10),
            body: const MovieUI()));
  }
}

class MovieUI extends StatefulWidget {
  const MovieUI({super.key});

  @override
  State<MovieUI> createState() {
    return MovieUIState();
  }
}

class MovieUIState extends State<MovieUI> {
  late Future<Movie> movieObj;
  final _formKey = GlobalKey<FormState>();
  final _SearchController = TextEditingController();
  final _yearController = TextEditingController();
  final _imdbIDController = TextEditingController();

  late final movieName, year, imdbID;

  @override
  void dispose() {
    _SearchController.dispose();
    _imdbIDController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      movieName = _SearchController.text;
      year = _yearController.text;
      imdbID = _imdbIDController.text;

      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _SearchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Movie ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter a Movie Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4)
                          ],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Year (optional)'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _imdbIDController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9)
                          ],
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter IMBD ID (optional)'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    child: const Text('Search'),
                  )
                ],
              ),
            ),
            //FutureBuilder(future: fetchMovieData(), builder: builder)
          ],
        ));
  }
}
