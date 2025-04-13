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
  } on Exception {
    throw const FormatException('Expected at least 1 section');
  }
}

// fetch movies
Future<Movie> fetchMovieData(
    String movieName, String year, String imdbID) async {
  final queryType = imdbID.isNotEmpty ? '&i=$imdbID' : '&t=$movieName';
  final yearQuery = year.isNotEmpty ? '&y=$year' : '';

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
    throw FormatException(e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Movie App',
        home: Scaffold(
            appBar: AppBar(title: const Text('Movie Database')),
            backgroundColor: const Color.fromARGB(255, 0, 7, 10),
            body: const SingleChildScrollView(
              child: MovieUI(),
            )));
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
      setState(() {
        movieObj = null; // Clear previous result
        movieObj = fetchMovieData(_searchController.text, _yearController.text,
            _imdbIDController.text);
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
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    style: const TextStyle(
                        color: Color.fromARGB(255, 254, 254, 255)),
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
                          style: const TextStyle(
                              color: Color.fromARGB(255, 254, 254, 255)),
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
                          style: const TextStyle(
                              color: Color.fromARGB(255, 254, 254, 255)),
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
                ],
              ),
            ),
            const SizedBox(height: 50.0),
            FutureBuilder(
                future: movieObj,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          "ERROR ${snapshot.error}",
                          style: TextStyle(
                              color: Color.fromARGB(255, 254, 254, 255)),
                        );
                      } else if (snapshot.hasData) {
                        final M = snapshot.data! as Movie;
                        Map<String, dynamic> movieData = M.toJson();

                        return Container(
                          padding: const EdgeInsets.all(19.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color.fromARGB(221, 85, 85, 100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Center(
                                  child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(13),
                                    bottom: Radius.circular(13)),
                                child: Image.network(
                                  M.poster ?? "",
                                  errorBuilder: (context, error, StackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 80.0,
                                    );
                                  },
                                  width: 150.0,
                                ),
                              )),
                              const SizedBox(height: 13.0),
                              Center(
                                  child: Text(
                                M.title ?? "N/A",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 254, 254, 255),
                                    fontSize: 20),
                              )),
                              const SizedBox(height: 13.0),
                              Text(
                                M.plot ?? "N/A",
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 254, 254, 255),
                                    fontSize: 15),
                              ),
                              const SizedBox(height: 25.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MovieData(
                                                  movieInfo: movieData,
                                                )),
                                      );
                                    },
                                    child: const Text(
                                      "Click to see more",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              219, 253, 254, 255),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.navigate_next,
                                    color: Color.fromARGB(255, 254, 254, 255),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      } else {
                        return const Text("NO DATA YET");
                      }
                  }
                })
          ],
        ));
  }
}

class MovieData extends StatelessWidget {
  final Map<String, dynamic> movieInfo;
  //final List<int> colorCodes = <int>[600, 500, 100];

  MovieData({super.key, required this.movieInfo});

  List<String> keys = [
    'imdbID',
    'Title',
    'Year',
    'Plot',
    'Released',
    'Genre',
    'Director',
    'Writer',
    'Actors',
    'Awards',
    'Metascore',
    'imdbRating',
    'BoxOffice'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Movie Database")),
        body: Container(
          color: Color.fromARGB(255, 0, 0, 0),
          padding: EdgeInsets.all(10.0),
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: keys.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                color: const Color.fromARGB(221, 85, 85, 100),
                constraints: const BoxConstraints(minHeight: 50.0),
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    '${keys[index]} : ${movieInfo[keys[index]] ?? "N/A"}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 236, 236, 240)),
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
          ),
        ));
  }
}
