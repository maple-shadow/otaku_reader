import 'package:flutter/material.dart';
import 'package:otaku_reader/mod_books/mod_books.dart';
import 'package:otaku_reader/services/api_service.dart';
import 'package:otaku_reader/services/theme_service.dart';

class ReadPage extends StatefulWidget {
  final Book? book;

  const ReadPage({Key? key, this.book}) : super(key: key);

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  String _content = '';
  int _currentPage = 0;
  double _fontSize = 16.0;
  Color _backgroundColor = ThemeService.lightBackground;
  Color _textColor = ThemeService.getTextColor(ThemeService.lightBackground);
  bool _isOnlineMode = false;
  String? _novelId;
  String? _chapterId;
  Chapter? _currentChapter;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    // 检查是否为在线模式
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map && routeArgs['isOnline'] == true) {
      // 在线小说模式
      _isOnlineMode = true;
      _novelId = routeArgs['novelId'];
      _chapterId = routeArgs['chapterId'];
      
      if (_novelId != null && _chapterId != null) {
        await _loadOnlineChapter(_novelId!, _chapterId!);
      }
    } else {
      // 本地书籍模式
      final book = widget.book ?? (routeArgs is Book ? routeArgs : null);
      if (book != null) {
        _currentPage = book.currentPage;
        await _loadLocalBook(book);
      } else {
        setState(() {
          _content = '未找到书籍数据';
        });
      }
    }
  }

  Future<void> _loadLocalBook(Book book) async {
    try {
      final content = await BookManager.loadBookContent(book.contentPath);
      // 使用单个setState减少界面重绘
      setState(() {
        _content = content;
      });
    } catch (e) {
      setState(() {
        _content = '读取书籍内容失败: $e';
      });
    }
  }

  Future<void> _loadOnlineChapter(String novelId, String chapterId) async {
    if (_isLoading) return; // 防止重复加载
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final chapter = await ApiService.getChapter(novelId, chapterId);
      // 使用单个setState减少界面重绘
      setState(() {
        _isLoading = false;
        _currentChapter = chapter;
        _content = chapter.content;
        _currentPage = chapter.chapterNumber - 1;
      });
      // 延迟滚动操作，避免与setState冲突
      Future.delayed(Duration(milliseconds: 50), () {
        _scrollToTop();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _content = '加载章节失败: $e';
      });
    }
  }

  void _updateReadingProgress() {
    if (!_isOnlineMode && widget.book != null) {
      BookManager.updateReadingProgress(widget.book!.id, _currentPage);
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _nextPage() {
    if (_isOnlineMode) {
      // 在线模式：跳转到下一章
      if (_currentChapter?.nextChapterId != null) {
        _loadOnlineChapter(_novelId!, _currentChapter!.nextChapterId!);
      }
    } else {
      // 本地模式：翻页
      if (_currentPage < (widget.book?.totalPages ?? 1) - 1) {
        setState(() {
          _currentPage++;
          _updateReadingProgress();
        });
        // 延迟滚动操作，避免与setState冲突
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollToTop();
        });
      }
    }
  }

  void _previousPage() {
    if (_isOnlineMode) {
      // 在线模式：跳转到上一章
      if (_currentChapter?.prevChapterId != null) {
        _loadOnlineChapter(_novelId!, _currentChapter!.prevChapterId!);
      }
    } else {
      // 本地模式：翻页
      if (_currentPage > 0) {
        setState(() {
          _currentPage--;
          _updateReadingProgress();
        });
        // 延迟滚动操作，避免与setState冲突
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollToTop();
        });
      }
    }
  }

  void _toggleTheme() {
    setState(() {
      if (_backgroundColor == ThemeService.lightBackground) {
        _backgroundColor = Colors.black;
        _textColor = Colors.white;
      } else {
        _backgroundColor = ThemeService.lightBackground;
        _textColor = ThemeService.getTextColor(ThemeService.lightBackground);
      }
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_fontSize > 12.0) {
        _fontSize -= 2.0;
      }
    });
  }

  Widget _buildChapterNavigation() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _previousPage,
              icon: Icon(Icons.arrow_back),
              label: Text('上一章'),
              style: ElevatedButton.styleFrom(
                 backgroundColor: ThemeService.buttonColor,
                 foregroundColor: Colors.white,
                 padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
               ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              icon: Icon(Icons.arrow_forward),
              label: Text('下一章'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeService.buttonColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody() {
    if (_content.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isOnlineMode && _currentChapter != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentChapter!.title,
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Divider(color: _textColor.withOpacity(0.3)),
              SizedBox(height: 20),
            ],
          ),
        Text(
          _content,
          style: TextStyle(
            fontSize: _fontSize,
            color: _textColor,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        SizedBox(height: 20),
        Divider(color: _textColor.withOpacity(0.3)),
        SizedBox(height: 10),
        Text(
          _isOnlineMode
              ? '第 ${_currentChapter?.chapterNumber ?? 1} 章 / 共 ${_currentChapter?.totalChapters ?? 1} 章'
              : '第 ${_currentPage + 1} 页 / 共 ${widget.book?.totalPages ?? 1} 页',
          style: TextStyle(
            fontSize: 14,
            color: _textColor.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        _buildChapterNavigation(),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(24),
      child: _buildContentBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否为在线模式
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs is Map && routeArgs['isOnline'] == true) {
      // 在线模式：检查是否有章节数据
      if (_currentChapter == null && _content.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text('阅读'),
            backgroundColor: ThemeService.appBarColor,
            foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
          ),
          body: Container(
            color: ThemeService.lightBackground,
            child: Center(
              child: Text(
                '正在加载章节...',
                style: TextStyle(
                  color: ThemeService.getTextColor(ThemeService.lightBackground),
                ),
              ),
            ),
          ),
        );
      }
    } else {
      // 本地模式：检查是否有书籍数据
      final book = widget.book ?? (routeArgs is Book ? routeArgs : null);
      if (book == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('阅读'),
            backgroundColor: ThemeService.appBarColor,
            foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
          ),
          body: Container(
            color: ThemeService.lightBackground,
            child: Center(
              child: Text(
                '未选择书籍',
                style: TextStyle(
                  color: ThemeService.getTextColor(ThemeService.lightBackground),
                ),
              ),
            ),
          ),
        );
      }
    }

    String pageTitle = '阅读';
    if (_isOnlineMode && _currentChapter != null) {
      pageTitle = _currentChapter!.title;
    } else {
      final book = widget.book ?? (routeArgs is Book ? routeArgs : null);
      if (book != null) {
        pageTitle = book.title;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: ThemeService.appBarColor,
        foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        actions: [
          IconButton(
            icon: Icon(Icons.text_decrease, color: ThemeService.getTextColor(ThemeService.appBarColor)),
            onPressed: _decreaseFontSize,
            tooltip: '减小字体',
          ),
          IconButton(
            icon: Icon(Icons.text_increase, color: ThemeService.getTextColor(ThemeService.appBarColor)),
            onPressed: _increaseFontSize,
            tooltip: '增大字体',
          ),
          IconButton(
            icon: Icon(_backgroundColor == ThemeService.lightBackground ? Icons.dark_mode : Icons.light_mode, color: ThemeService.getTextColor(ThemeService.appBarColor)),
            onPressed: _toggleTheme,
            tooltip: '切换主题',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: _backgroundColor,
          child: _buildContent(),
        ),
      ),
    );
  }
}
