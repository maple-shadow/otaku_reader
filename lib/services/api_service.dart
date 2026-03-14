import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  static Future<List<Novel>> getNovels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/novels'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((novelJson) => Novel.fromJson(novelJson)).toList();
      } else {
        throw Exception('Failed to load novels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Novel> getNovel(String novelId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/novel/$novelId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Novel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Novel not found: $novelId');
      } else {
        throw Exception('Failed to load novel: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  static Future<Chapter> getChapter(String novelId, String chapterId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/novel/$novelId/$chapterId'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Chapter.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Chapter not found: $novelId/$chapterId');
      } else {
        throw Exception('Failed to load chapter: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class Novel {
  final String id;
  final String title;
  final String description;
  final int totalChapters;
  final List<ChapterInfo> chapters;
  
  Novel({
    required this.id,
    required this.title,
    required this.description,
    required this.totalChapters,
    required this.chapters,
  });
  
  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      totalChapters: json['totalChapters'],
      chapters: (json['chapters'] as List)
          .map((chapterJson) => ChapterInfo.fromJson(chapterJson))
          .toList(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'totalChapters': totalChapters,
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
    };
  }
}

class ChapterInfo {
  final String id;
  final String title;
  final int chapterNumber;
  
  ChapterInfo({
    required this.id,
    required this.title,
    required this.chapterNumber,
  });
  
  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'],
      title: json['title'],
      chapterNumber: json['chapterNumber'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chapterNumber': chapterNumber,
    };
  }
}

class Chapter {
  final String novelId;
  final String chapterId;
  final String title;
  final String content;
  final int chapterNumber;
  final String? nextChapterId;
  final String? prevChapterId;
  final int totalChapters;
  
  Chapter({
    required this.novelId,
    required this.chapterId,
    required this.title,
    required this.content,
    required this.chapterNumber,
    this.nextChapterId,
    this.prevChapterId,
    required this.totalChapters,
  });
  
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      novelId: json['novelId'],
      chapterId: json['chapterId'],
      title: json['title'],
      content: json['content'],
      chapterNumber: json['chapterNumber'],
      nextChapterId: json['nextChapterId'],
      prevChapterId: json['prevChapterId'],
      totalChapters: json['totalChapters'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'novelId': novelId,
      'chapterId': chapterId,
      'title': title,
      'content': content,
      'chapterNumber': chapterNumber,
      'nextChapterId': nextChapterId,
      'prevChapterId': prevChapterId,
      'totalChapters': totalChapters,
    };
  }
}