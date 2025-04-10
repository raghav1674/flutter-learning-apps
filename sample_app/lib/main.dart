import 'package:flutter/material.dart';
import 'package:sample_app/models/todo.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

Future<Movie> fetchMovieDatatest(
    String movieName, String? year, String? imdbID) async {
  String url = "https://omdbapi.com/?apikey=e56c123e";

  url += '&t=$movieName';

  if (year != null) url += '&y=$year';
  if (imdbID != null) url += '&i=$imdbID';

  try {
    final response = await http.get(
      Uri.parse(url),
    );

    final movieInfo = (jsonDecode(response.body) as Map<String, dynamic>);

    return Movie.fromJson(movieInfo);
  } on Exception catch (e) {
    print('Exception details:\n $e');
    throw const FormatException('Expected at least 1 section');
  }
}

// fetch movies
Future<Movie> fetchMovieData(
    String movieName, String? year, String? imdbID) async {
  final queryType = imdbID != null ? '&i=$imdbID' : '&t=$movieName';
  final yearQuery = year != null ? '&y=$year' : '';
  try {
    final response = await http.get(
      Uri.parse('https://omdbapi.com/?$queryType$yearQuery&apikey=e56c123e'),
    );

    if (response.statusCode != 200) {
      throw const FormatException('Please provide valid input');
    }

    final movieInfo = (jsonDecode(response.body) as Map<String, dynamic>);

    return Movie.fromJson(movieInfo);
  } on Exception catch (e) {
    print('Exception details:\n $e');
    throw FormatException(e.toString());
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
            textTheme: ThemeData.light().textTheme.apply(
                  bodyColor: Colors.white,
                  displayColor: Colors.white,
                )),
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
  late Future<Movie>? movieObj;
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _yearController = TextEditingController();
  final _imdbIDController = TextEditingController();
  String errorMessage = '';

  String? movieName, imdbID, year;

  @override
  void initState() {
    super.initState();
    movieObj = null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _imdbIDController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      movieName = _searchController.text;

      if (_yearController.text.trim().isNotEmpty) {
        year = _yearController.text;
      }
      if (_imdbIDController.text.trim().isNotEmpty) {
        imdbID = _imdbIDController.text;
      }

      setState(() {
        movieObj = fetchMovieData(movieName!, year, imdbID);
        print(movieObj);
      });

      _formKey.currentState?.reset();
    }

    return;
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
                    controller: _searchController,
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
                  ),
                  Text(errorMessage)
                ],
              ),
            ),
            FutureBuilder(
                future: movieObj,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Text("WAITING");
                    default:
                      if (snapshot.hasError) {
                        return Text("ERROR");
                      } else if (snapshot.hasData) {
                        final M = snapshot.data! as Movie;

                        return Card(
                            child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(13),
                                  bottom: Radius.circular(13)),
                              child: Image.network(
                                M.poster,
                                //fit: BoxFit.cover,
                                width: 100.0,
                              ),
                            ),
                            ListTile(
                              title: Text("${M.title}"),
                              subtitle: Text("${M.plot}"),
                            ),
                          ],
                        ));
                      } else {
                        return Text("NO DATA YET");
                      }
                  }
                  // if (snapshot.hasError) {
                  //   return const Text(
                  //     "SOME ERROR OCCURED",
                  //     style:
                  //         TextStyle(color: Color.fromARGB(255, 238, 238, 238)),
                  //   );
                  // } else if (snapshot.hasData) {
                  //   return const Text(
                  //     "DATA RECEIVED",
                  //     style:
                  //         TextStyle(color: Color.fromARGB(255, 238, 238, 238)),
                  //   );
                  // } else {
                  //   return const Text(
                  //     "WAITING",
                  //     style:
                  //         TextStyle(color: Color.fromARGB(255, 246, 246, 250)),
                  //   );
                  // }
                })
          ],
        ));
  }
}
