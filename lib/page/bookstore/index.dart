
import 'package:flutter/material.dart';
import 'package:otaku_reader/services/api_service.dart';
import 'package:otaku_reader/services/theme_service.dart';

class BookstorePage extends StatefulWidget {
  BookstorePage({Key? key}) : super(key: key);

  @override
  _BookstorePageState createState() => _BookstorePageState();
}

class _BookstorePageState extends State<BookstorePage> {
  List<Novel> _novels = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadNovels();
  }

  Future<void> _loadNovels() async {
    try {
      final novels = await ApiService.getNovels();
      setState(() {
        _novels = novels;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '加载失败: $e';
      });
    }
  }

  void _navigateToNovelDetail(Novel novel) {
    Navigator.pushNamed(
      context,
      '/novel_detail',
      arguments: novel,
    );
  }

  Widget _buildNovelCard(Novel novel, int index) {
    return GestureDetector(
      onTap: () => _navigateToNovelDetail(novel),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 40,
                    color: ThemeService.getIconColor(ThemeService.cardColor),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          novel.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemeService.getTextColor(ThemeService.cardColor),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          novel.description.isEmpty ? '暂无描述' : novel.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeService.getTextColor(ThemeService.cardColor),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '共${novel.totalChapters}章',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeService.getTextColor(ThemeService.cardColor),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeService.primaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '在线阅读',
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeService.getTextColor(ThemeService.primaryColor.withOpacity(0.3)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在加载书籍...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNovels,
            child: Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelList() {
    if (_novels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '暂无书籍',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _novels.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: _buildNovelCard(_novels[index], index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('在线书城'),
        backgroundColor: ThemeService.appBarColor,
        foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadNovels,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Container(
        color: ThemeService.lightBackground,
        child: _isLoading
            ? _buildLoading()
            : _errorMessage.isNotEmpty
                ? _buildError()
                : _buildNovelList(),
      ),
    );
  }
}