import 'package:flutter/material.dart';

class ThemeService {
  static Color _primaryColor = Color(0xFFFFE4E6); // 默认淡粉色
  
  static Color get primaryColor => _primaryColor;
  
  static Color get appBarColor => Color.fromRGBO(
    _primaryColor.red, 
    _primaryColor.green, 
    _primaryColor.blue, 
    0.8
  );
  
  static Color get buttonColor => Color.fromRGBO(
    _primaryColor.red, 
    _primaryColor.green, 
    _primaryColor.blue, 
    0.9
  );
  
  static Color get lightBackground => Color.fromRGBO(
    _primaryColor.red, 
    _primaryColor.green, 
    _primaryColor.blue, 
    0.1
  );
  
  static Color get cardColor => Color.fromRGBO(
    _primaryColor.red, 
    _primaryColor.green, 
    _primaryColor.blue, 
    0.05
  );
  
  // 根据背景色亮度自动计算文字颜色
  static Color getTextColor(Color backgroundColor) {
    // 计算背景色的亮度 (0-255)
    final brightness = backgroundColor.computeLuminance();
    
    // 如果背景色较亮，使用深色文字；如果较暗，使用浅色文字
    return brightness > 0.5 ? Colors.black : Colors.white;
  }
  
  // 根据背景色亮度自动计算图标颜色
  static Color getIconColor(Color backgroundColor) {
    return getTextColor(backgroundColor);
  }
  
  static void setPrimaryColor(Color color) {
    _primaryColor = color;
  }
  
  static void resetToDefault() {
    _primaryColor = Color(0xFFFFE4E6); // 重置为默认淡粉色
  }
  
  // 预定义主题色选项
  static final List<Color> predefinedColors = [
    Color(0xFFFFE4E6), // 淡粉色
    Color(0xFFE3F2FD), // 淡蓝色
    Color(0xFFE8F5E8), // 淡绿色
    Color(0xFFFFF3E0), // 淡橙色
    Color(0xFFF3E5F5), // 淡紫色
    Color(0xFFFFEBEE), // 淡红色
    Color(0xFFE0F2F1), // 淡青色
    Color(0xFFF5F5F5), // 淡灰色
  ];
  
  static final List<String> colorNames = [
    '淡粉色',
    '淡蓝色', 
    '淡绿色',
    '淡橙色',
    '淡紫色',
    '淡红色',
    '淡青色',
    '淡灰色',
  ];
}