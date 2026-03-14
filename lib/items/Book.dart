class Book {
  final String title;
  final String author;
  final String? coverUrl;
  final String contentPath;

  Book({
    required this.title,
    required this.author,
    required this.contentPath,
    this.coverUrl,
  });
}