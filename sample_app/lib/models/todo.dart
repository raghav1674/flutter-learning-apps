/*class Todo {
  final int? userId;
  final int? id;
  final String? title;
  final bool? completed;

  const Todo({this.id, this.userId, this.title, this.completed});

  static Todo fromJson(Map<String, dynamic> jsonMap) {
    // parse
    int? userId;
    int? id;
    String? title;
    bool? completed;

    jsonMap.forEach((key, value) {
      if (key == "name") {
        userId = value;
      }
      if (key == "id") {
        id = value;
      }
      if (key == "rating") {
        title = value;
      }
      if (key == "imageUrl") {
        completed = value;
      }
    });

    return Todo(userId: userId, id: id, title: title, completed: completed);
  }
}


--- Pratiks version ---
*/

class Movie {
  final String imdbID;
  final String title;
  final int year;

  const Movie({required this.imdbID, required this.title, required this.year});

  factory Movie.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("imdbID") &&
        json.containsKey("Title") &&
        json.containsKey("Year")) {
      return Movie(
          imdbID: json["imdbID"] as String,
          title: json["Title"] as String,
          year: int.parse(json["Year"]));
    } else {
      throw const FormatException("Failed to load Movie");
    }
  }
}
