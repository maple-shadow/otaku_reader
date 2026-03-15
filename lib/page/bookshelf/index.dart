import 'package:flutter/material.dart';
import 'package:otaku_reader/mod_books/mod_books.dart';
import 'package:otaku_reader/services/theme_service.dart';

class BookshelfPage extends StatefulWidget {
  BookshelfPage({Key? key}) : super(key: key);

  @override
  _BookshelfPageState createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  void _loadBooks() {
    setState(() {
      _books = BookManager.getAllBooks();
    });
  }

  void _navigateToReadPage(Book book) {
    Navigator.pushNamed(
      context, 
      '/read',
      arguments: book,
    );
  }

  Widget _buildBookCard(Book book, int index) {
    return GestureDetector(
      onTap: () => _navigateToReadPage(book),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeService.cardColor,
                ThemeService.cardColor.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                size: 40,
                color: ThemeService.getIconColor(ThemeService.cardColor),
              ),
              SizedBox(height: 8),
              Text(
                book.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.getTextColor(ThemeService.cardColor),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                book.author,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeService.getTextColor(ThemeService.cardColor),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: book.currentPage / book.totalPages,
                backgroundColor: ThemeService.primaryColor.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(ThemeService.primaryColor.withOpacity(0.8)),
              ),
              SizedBox(height: 4),
              Text(
                '${book.currentPage}/${book.totalPages}',
                style: TextStyle(
                  fontSize: 10,
                  color: ThemeService.getTextColor(ThemeService.cardColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeService.appBarColor,
        foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        title: Text('我的书架'),
      ),
      body: SafeArea(
        child: Container(
          color: ThemeService.lightBackground,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 200,
                maxCrossAxisExtent: 150,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(_books[index], index);
              },
            ),
          ),
        ),
      ),
    );
  }
}