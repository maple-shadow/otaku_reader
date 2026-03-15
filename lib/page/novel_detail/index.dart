import 'package:flutter/material.dart';
import 'package:otaku_reader/services/api_service.dart';
import 'package:otaku_reader/services/theme_service.dart';

class NovelDetailPage extends StatefulWidget {
  NovelDetailPage({Key? key}) : super(key: key);

  @override
  _NovelDetailPageState createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  Novel? _novel;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNovelDetail();
    });
  }

  void _loadNovelDetail() async {
    final novel = ModalRoute.of(context)?.settings.arguments as Novel?;
    if (novel != null) {
      try {
        final novelDetail = await ApiService.getNovel(novel.id);
        setState(() {
          _novel = novelDetail;
          _isLoading = false;
          _errorMessage = '';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = '加载小说详情失败: $e';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = '未找到小说数据';
      });
    }
  }

  void _navigateToChapter(ChapterInfo chapter) {
    if (_novel != null) {
      Navigator.pushNamed(
        context,
        '/read',
        arguments: {
          'novelId': _novel!.id,
          'chapterId': chapter.id,
          'isOnline': true,
        },
      );
    }
  }

  Widget _buildChapterItem(ChapterInfo chapter, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ThemeService.cardColor,
        child: Text(
          '${chapter.chapterNumber}',
          style: TextStyle(
            color: ThemeService.getTextColor(ThemeService.cardColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chapter.title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ThemeService.getTextColor(ThemeService.cardColor),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ThemeService.getIconColor(ThemeService.cardColor),
      ),
      onTap: () => _navigateToChapter(chapter),
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
            '正在加载章节...',
            style: TextStyle(
              fontSize: 16, 
              color: ThemeService.getTextColor(ThemeService.lightBackground),
            ),
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
            color: ThemeService.getIconColor(ThemeService.lightBackground),
          ),
          SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16, 
              color: ThemeService.getTextColor(ThemeService.lightBackground),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNovelDetail,
            child: Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.buttonColor,
              foregroundColor: ThemeService.getTextColor(ThemeService.buttonColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeService.cardColor,
            ThemeService.cardColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                size: 48,
                color: ThemeService.getIconColor(ThemeService.cardColor),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _novel!.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.getTextColor(ThemeService.cardColor),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _novel!.description.isEmpty ? '暂无描述' : _novel!.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.getTextColor(ThemeService.cardColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共${_novel!.totalChapters}章',
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeService.getTextColor(ThemeService.cardColor),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ThemeService.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '开始阅读',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeService.getTextColor(ThemeService.primaryColor.withOpacity(0.3)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _novel!.chapters.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            elevation: 1,
            child: _buildChapterItem(_novel!.chapters[index], index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('小说详情'),
          backgroundColor: ThemeService.appBarColor,
          foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        ),
        body: Container(
          color: ThemeService.lightBackground,
          child: _buildLoading(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('小说详情'),
          backgroundColor: ThemeService.appBarColor,
          foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        ),
        body: Container(
          color: ThemeService.lightBackground,
          child: _buildError(),
        ),
      );
    }

    if (_novel == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('小说详情'),
          backgroundColor: ThemeService.appBarColor,
          foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        ),
        body: Container(
          color: ThemeService.lightBackground,
          child: Center(
            child: Text('小说数据不存在'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_novel!.title),
        backgroundColor: ThemeService.appBarColor,
        foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        elevation: 0,
      ),
      body: Container(
        color: ThemeService.lightBackground,
        child: Column(
          children: [
            _buildNovelHeader(),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.list,
                    color: ThemeService.getIconColor(ThemeService.lightBackground),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '章节列表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ThemeService.getTextColor(ThemeService.lightBackground),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            _buildChapterList(),
          ],
        ),
      ),
    );
  }
}