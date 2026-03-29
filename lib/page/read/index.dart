import 'package:flutter/material.dart';
import 'package:otaku_reader/mod_books/mod_books.dart';
import 'package:otaku_reader/services/api_service.dart';
import 'package:otaku_reader/services/theme_service.dart';

class ReadPage extends StatefulWidget {
  final Book? book;

  const ReadPage({super.key, this.book});

  @override
  _ReadPageState createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _content = '';
  int _currentPage = 0;
  double _fontSize = 16.0;
  Color _backgroundColor = ThemeService.lightBackground;
  Color _textColor = ThemeService.getTextColor(ThemeService.lightBackground);
  bool _isOnlineMode = false;
  String? _novelId;
  String? _chapterId;
  Chapter? _currentChapter;
  List<ChapterInfo> _chapterList = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _showControls = false;
  bool _isAutoLoading = false;
  List<Map<String, dynamic>> _chapterContents = [];
  bool _hasMoreChapters = true;
  double _savedScrollPosition = 0;
  final List<GlobalKey> _chapterKeys = [];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
    // 延时加载，确保界面完全渲染后再开始数据加载
    Future.delayed(Duration(milliseconds: 100), () {
      _loadContent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (_showControls) {
      setState(() {
        _showControls = false;
      });
    }
    
    if (_isAutoLoading || _isLoading || !_hasMoreChapters) return;
    
    if (notification is ScrollUpdateNotification) {
      _savedScrollPosition = notification.metrics.pixels;
    }
    
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      final maxScroll = metrics.maxScrollExtent;
      final currentScroll = metrics.pixels;
      
      _savedScrollPosition = currentScroll;
      
      if (maxScroll > 0 && currentScroll >= maxScroll - 50) {
        _isAutoLoading = true;
        if (_isOnlineMode) {
          if (_chapterContents.isNotEmpty) {
            final lastChapter = _chapterContents.last['chapter'];
            if (lastChapter.nextChapterId != null && _hasMoreChapters) {
              _loadOnlineChapter(_novelId!, lastChapter.nextChapterId!, scrollToNewChapter: false);
            }
          } else if (_currentChapter?.nextChapterId != null && _hasMoreChapters) {
            _loadOnlineChapter(_novelId!, _currentChapter!.nextChapterId!, scrollToNewChapter: false);
          }
        }
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState != null) {
      if (_scaffoldKey.currentState!.isDrawerOpen) {
        Navigator.of(context).pop();
      } else {
        _scaffoldKey.currentState!.openDrawer();
      }
    }
  }

  void _jumpToChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= _chapterList.length) return;
    
    final chapterInfo = _chapterList[chapterIndex];
    
    // 清空当前内容
    setState(() {
      _chapterContents.clear();
      _chapterKeys.clear();
      _hasMoreChapters = true;
    });
    
    // 加载新章节
    _loadOnlineChapter(_novelId!, chapterInfo.id, scrollToNewChapter: true);
    
    // 关闭侧边栏
    if (_scaffoldKey.currentState != null && _scaffoldKey.currentState!.isDrawerOpen) {
      Navigator.of(context).pop();
    }
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
        // 先加载小说信息获取章节列表
        try {
          final novel = await ApiService.getNovel(_novelId!);
          setState(() {
            _chapterList = novel.chapters;
          });
        } catch (e) {
          print('Failed to load chapter list: $e');
        }
        // 再加载章节内容
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

  Future<void> _loadOnlineChapter(String novelId, String chapterId, {bool scrollToNewChapter = false}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final chapter = await ApiService.getChapter(novelId, chapterId);
      
      setState(() {
        _isLoading = false;
        _isAutoLoading = false;
        _currentChapter = chapter;
        
        if (_chapterContents.isEmpty) {
          _chapterContents.add({
            'chapter': chapter,
            'content': chapter.content,
          });
          _chapterKeys.add(GlobalKey());
          _content = chapter.content;
        } else {
          _chapterContents.add({
            'chapter': chapter,
            'content': chapter.content,
          });
          _chapterKeys.add(GlobalKey());
        }
        
        _currentPage = chapter.chapterNumber - 1;
        _hasMoreChapters = chapter.nextChapterId != null;
      });
      
      if (_chapterContents.length == 1) {
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollToTop();
        });
      } else if (scrollToNewChapter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToChapter(_chapterKeys.length - 1);
        });
      } else if (_chapterContents.length > 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && _savedScrollPosition > 0) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final targetPosition = _savedScrollPosition;
            if (targetPosition <= maxScroll) {
              _scrollController.jumpTo(targetPosition);
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isAutoLoading = false;
        if (_chapterContents.isEmpty) {
          _content = '加载章节失败: $e';
        }
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

  void _scrollToChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= _chapterKeys.length) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _chapterKeys[chapterIndex];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.0,
          duration: Duration(milliseconds: 300),
        );
      }
    });
  }

  void _nextPage() {
    if (_isOnlineMode) {
      if (_chapterContents.isNotEmpty) {
        final lastChapter = _chapterContents.last['chapter'];
        if (lastChapter.nextChapterId != null && _hasMoreChapters) {
          _loadOnlineChapter(_novelId!, lastChapter.nextChapterId!, scrollToNewChapter: true);
        }
      } else if (_currentChapter?.nextChapterId != null && _hasMoreChapters) {
        _loadOnlineChapter(_novelId!, _currentChapter!.nextChapterId!, scrollToNewChapter: true);
      }
    } else {
      if (_currentPage < (widget.book?.totalPages ?? 1) - 1) {
        setState(() {
          _currentPage++;
          _updateReadingProgress();
        });
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollToTop();
        });
      }
    }
  }

  void _previousPage() {
    if (_isOnlineMode) {
      if (_chapterContents.length > 1) {
        setState(() {
          _chapterContents.removeLast();
          _chapterKeys.removeLast();
          _hasMoreChapters = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToChapter(_chapterKeys.length - 1);
        });
      } else if (_currentChapter?.prevChapterId != null) {
        _loadOnlineChapter(_novelId!, _currentChapter!.prevChapterId!, scrollToNewChapter: true);
      }
    } else {
      if (_currentPage > 0) {
        setState(() {
          _currentPage--;
          _updateReadingProgress();
        });
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

  Widget _buildBottomMenu() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showControls ? 80 : 0,
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: ThemeService.getTextColor(ThemeService.appBarColor)),
              onPressed: _toggleDrawer,
              tooltip: '目录',
            ),
            Expanded(
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String pageTitle) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showControls ? kToolbarHeight + MediaQuery.of(context).padding.top : 0,
      decoration: BoxDecoration(
        color: ThemeService.appBarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _showControls ? SafeArea(
        bottom: false,
        child: Container(
          height: kToolbarHeight,
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: ThemeService.getTextColor(ThemeService.appBarColor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: ThemeService.getTextColor(ThemeService.appBarColor),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
        ),
      ) : SizedBox.shrink(),
    );
  }

  Widget _buildContentBody() {
    if (_content.isEmpty && _chapterContents.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _chapterContents.length; i++) ...[
          if (_isOnlineMode)
            Container(
              key: i < _chapterKeys.length ? _chapterKeys[i] : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chapterContents[i]['chapter'].title,
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
            ),
          Text(
            _chapterContents[i]['content'],
            style: TextStyle(
              fontSize: _fontSize,
              color: _textColor,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          if (i < _chapterContents.length - 1) ...[
            SizedBox(height: 20),
            Divider(color: _textColor.withOpacity(0.3)),
            SizedBox(height: 20),
          ],
        ],
        if (_chapterContents.isNotEmpty) ...[
          SizedBox(height: 20),
          Divider(color: _textColor.withOpacity(0.3)),
          SizedBox(height: 10),
          Text(
            _isOnlineMode
                ? '已加载 ${_chapterContents.length} 章${_hasMoreChapters ? '，继续滑动加载更多...' : '（已加载全部）'}'
                : '第 ${_currentPage + 1} 页 / 共 ${widget.book?.totalPages ?? 1} 页',
            style: TextStyle(
              fontSize: 14,
              color: _textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOnlineMode)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerItem(
                    height: (_fontSize + 4) * 1.6,
                    width: double.infinity,
                  ),
                  SizedBox(height: 20),
                  Divider(color: _textColor.withOpacity(0.3)),
                  SizedBox(height: 20),
                ],
              ),
            for (int i = 0; i < 10; i++)
              Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _buildShimmerItem(
                  height: _fontSize * 1.6,
                  width: i % 3 == 0 ? double.infinity * 0.9 : double.infinity * 0.7,
                ),
              ),
            SizedBox(height: 20),
            Divider(color: _textColor.withOpacity(0.3)),
            SizedBox(height: 10),
            _buildShimmerItem(
              height: 14,
              width: 150,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildShimmerItem(
                    height: 48,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildShimmerItem(
                    height: 48,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerItem({
    required double height,
    double? width,
    BorderRadius? borderRadius,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _textColor.withOpacity(0.1),
            _textColor.withOpacity(0.2),
            _textColor.withOpacity(0.1),
          ],
          stops: [
            0.0,
            _shimmerAnimation.value,
            1.0,
          ],
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildContent() {
    Widget content;
    
    if (_isLoading && _chapterContents.isEmpty) {
      content = _buildSkeleton();
    } else if (_content.isEmpty && _chapterContents.isEmpty) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (_isOnlineMode) {
        content = _buildSkeleton();
      } else {
        final book = widget.book ?? (routeArgs is Book ? routeArgs : null);
        if (book == null) {
          content = Center(
            child: Text(
              '未选择书籍',
              style: TextStyle(
                color: _textColor,
              ),
            ),
          );
        } else {
          content = _buildContentBody();
        }
      }
    } else {
      content = _buildContentBody();
    }
    
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScrollNotification(notification);
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(24),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String pageTitle = '阅读';
    
    if (_isOnlineMode) {
      if (_chapterContents.isNotEmpty) {
        pageTitle = _chapterContents.last['chapter'].title;
      } else if (_currentChapter != null) {
        pageTitle = _currentChapter!.title;
      }
    } else {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      final book = widget.book ?? (routeArgs is Book ? routeArgs : null);
      if (book != null) {
        pageTitle = book.title;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _isOnlineMode ? _buildDrawer() : null,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Container(
                color: _backgroundColor,
                child: _buildContent(),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: _buildTopBar(pageTitle),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _backgroundColor,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeService.appBarColor,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: ThemeService.getTextColor(ThemeService.appBarColor)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '目录',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.getTextColor(ThemeService.appBarColor),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _chapterList.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      itemCount: _chapterList.length,
                      itemBuilder: (context, index) {
                        if (index >= _chapterList.length) {
                          return SizedBox.shrink();
                        }
                        final chapter = _chapterList[index];
                        String chapterTitle = '';
                        String chapterId = '';
                        bool isCurrentChapter = false;
                        
                        try {
                          chapterTitle = chapter.title ?? '';
                          chapterId = chapter.id ?? '';
                        } catch (e) {
                          chapterTitle = '章节 ${index + 1}';
                          chapterId = '';
                        }
                        
                        if (_chapterContents.isNotEmpty &&
                            _chapterContents.last.containsKey('chapter') &&
                            _chapterContents.last['chapter'] != null) {
                          try {
                            isCurrentChapter = _chapterContents.last['chapter'].id == chapterId;
                          } catch (e) {
                            isCurrentChapter = false;
                          }
                        }
                        
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            chapterTitle,
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _jumpToChapter(index),
                          tileColor: isCurrentChapter
                              ? _textColor.withOpacity(0.1)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
