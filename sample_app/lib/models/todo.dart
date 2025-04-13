class Movie {
  final String? imdbID;
  final String? title;
  final String? year;
  final String? poster;
  final String? plot;
  final String? releaseDate;
  final String? genre;
  final String? director;
  final String? writer;
  final String? actors;
  final String? awards;
  final String? metaScore;
  final String? imdbRating;
  final String? boxOffice;

  const Movie(
      {this.imdbID,
      this.title,
      this.year,
      this.poster,
      this.plot,
      this.releaseDate,
      this.genre,
      this.director,
      this.writer,
      this.actors,
      this.awards,
      this.metaScore,
      this.imdbRating,
      this.boxOffice});

  Map<String, dynamic> toJson() {
    return {
      'imdbID': imdbID,
      'Title': title,
      'Year': year,
      'Poster': poster,
      'Plot': plot,
      'Released': releaseDate,
      'Genre': genre,
      'Director': director,
      'Writer': writer,
      'Actors': actors,
      'Awards': awards,
      'Metascore': metaScore,
      'imdbRating': imdbRating,
      'BoxOffice': boxOffice,
    };
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json["imdbID"],
      title: json["Title"],
      year: json["Year"],
      poster: json["Poster"],
      plot: json["Plot"],
      releaseDate: json["Released"],
      genre: json["Genre"],
      director: json["Director"],
      writer: json["Writer"],
      actors: json["Actors"],
      awards: json["Awards"],
      metaScore: json["Metascore"],
      imdbRating: json["imdbRating"],
      boxOffice: json["BoxOffice"],
    );
  }
}
