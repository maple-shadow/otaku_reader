import 'package:flutter/material.dart';
import 'package:otaku_reader/services/theme_service.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Color _selectedColor = ThemeService.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeService.appBarColor,
        foregroundColor: ThemeService.getTextColor(ThemeService.appBarColor),
        title: Text('个人中心'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题设置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '选择主题色:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            _buildColorPicker(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetToDefault,
              child: Text('重置为默认'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeService.buttonColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(ThemeService.predefinedColors.length, (index) {
        final color = ThemeService.predefinedColors[index];
        final isSelected = color == _selectedColor;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
              ThemeService.setPrimaryColor(color);
            });
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: isSelected 
                ? Border.all(color: Colors.black, width: 3)
                : Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
               child: Text(
                 ThemeService.colorNames[index],
                 style: TextStyle(
                   fontSize: 10,
                   color: ThemeService.getTextColor(color),
                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                 ),
                 textAlign: TextAlign.center,
               ),
             ),
          ),
        );
      }),
    );
  }

  void _resetToDefault() {
    setState(() {
      ThemeService.resetToDefault();
      _selectedColor = ThemeService.primaryColor;
    });
  }
}