
import 'package:flutter/material.dart';
import 'package:otaku_reader/page/bookshelf/index.dart' show BookshelfPage;
import 'package:otaku_reader/page/bookstore/index.dart' show BookstorePage;
import 'package:otaku_reader/page/mine/index.dart' show MinePage;
import 'package:otaku_reader/services/theme_service.dart';

class MainPageState extends StatefulWidget {
  MainPageState({Key? key}) : super(key: key);

  @override
  _MainPageStateState createState() => _MainPageStateState();
}

class _MainPageStateState extends State<MainPageState> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: ThemeService.lightBackground,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              BookshelfPage(),
              BookstorePage(),
              MinePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookshelf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: 'Bookstore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mine',
          ),
        ],
      ),
    );
  }
}