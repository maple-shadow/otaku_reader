
import 'package:flutter/material.dart';
import 'package:otaku_reader/page/bookshelf/index.dart';
import 'package:otaku_reader/page/bookstore/index.dart';
import 'package:otaku_reader/page/index.dart';
import 'package:otaku_reader/page/novel_detail/index.dart';
import 'package:otaku_reader/page/read/index.dart';

Map<String, Widget Function(BuildContext)> getRoutes() {
  return {
    '/': (context) => MainPageState(),
    '/bookshelf': (context) => BookshelfPage(),
    '/bookstore': (context) => BookstorePage(),
    '/novel_detail': (context) => NovelDetailPage(),
    '/read': (context) => ReadPage(),
  };
}