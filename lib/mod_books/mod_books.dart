
import 'package:flutter/services.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String contentPath;
  final String coverImage;
  final int totalPages;
  int currentPage;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.contentPath,
    this.coverImage = '',
    required this.totalPages,
    this.currentPage = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'contentPath': contentPath,
      'coverImage': coverImage,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      contentPath: json['contentPath'],
      coverImage: json['coverImage'] ?? '',
      totalPages: json['totalPages'],
      currentPage: json['currentPage'] ?? 0,
    );
  }
}

class BookManager {
  static final List<Book> _books = [
    Book(
      id: '1',
      title: '编程的艺术',
      author: '李明',
      contentPath: 'lib/mod_books/book_1.txt',
      totalPages: 5,
    ),
    Book(
      id: '2',
      title: 'Flutter开发指南',
      author: '张伟',
      contentPath: 'lib/mod_books/book_2.txt',
      totalPages: 6,
    ),
    Book(
      id: '3',
      title: '人工智能入门',
      author: '王芳',
      contentPath: 'lib/mod_books/book_3.txt',
      totalPages: 6,
    ),
    Book(
      id: '4',
      title: '数据科学实战',
      author: '陈强',
      contentPath: 'lib/mod_books/book_4.txt',
      totalPages: 6,
    ),
    Book(
      id: '5',
      title: '移动应用设计',
      author: '刘婷',
      contentPath: 'lib/mod_books/book_5.txt',
      totalPages: 6,
    ),
    Book(
      id: '6',
      title: '网络安全基础',
      author: '赵刚',
      contentPath: 'lib/mod_books/book_6.txt',
      totalPages: 6,
    ),
    Book(
      id: '7',
      title: '云计算技术',
      author: '孙明',
      contentPath: 'lib/mod_books/book_7.txt',
      totalPages: 6,
    ),
    Book(
      id: '8',
      title: '区块链原理与应用',
      author: '周华',
      contentPath: 'lib/mod_books/book_8.txt',
      totalPages: 6,
    ),
    Book(
      id: '9',
      title: '物联网技术',
      author: '吴磊',
      contentPath: 'lib/mod_books/book_9.txt',
      totalPages: 6,
    ),
    Book(
      id: '10',
      title: '软件工程实践',
      author: '郑晓',
      contentPath: 'lib/mod_books/book_10.txt',
      totalPages: 6,
    ),
  ];

  static Future<String> loadBookContent(String contentPath) async {
    try {
      // 直接使用完整的路径，因为已经在 pubspec.yaml 中声明了资源
      return await rootBundle.loadString(contentPath);
    } catch (e) {
      return '读取文件失败: $e';
    }
  }

   static List<Book> getAllBooks() {
     return List.from(_books);
   }

   static Book? getBookById(String id) {
     try {
       return _books.firstWhere((book) => book.id == id);
     } catch (e) {
       return null;
     }
   }

   static void updateReadingProgress(String bookId, int currentPage) {
     final book = getBookById(bookId);
     if (book != null) {
       book.currentPage = currentPage;
     }
   }

   static List<Book> searchBooks(String query) {
     if (query.isEmpty) return getAllBooks();
     
     final lowerQuery = query.toLowerCase();
     return _books.where((book) {
       return book.title.toLowerCase().contains(lowerQuery) ||
              book.author.toLowerCase().contains(lowerQuery);
     }).toList();
   }
 }